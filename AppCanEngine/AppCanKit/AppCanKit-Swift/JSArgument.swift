//
//  JSArgument.swift
//  JSArgument
//
//  Created by CeriNo on 16/9/29.
//  Copyright © 2016年 SDiC. All rights reserved.
//

import Foundation
import JavaScriptCore

fileprivate final class JSONBox{

    enum LazyValue {
        case notYetComputed
        case null
        case object(object: [String: Any])
        case array(array: [Any])
    }
    private var _value: LazyValue
    private let jsValue: JSValue
    
    init(jsValue: JSValue){
        _value = .notYetComputed
        self.jsValue = jsValue
    }
    
    
    func compute(){
        guard case .notYetComputed = _value else{
            return
        }
        if jsValue.isString,
            let jsonData = jsValue.toString().data(using: .utf8),
            let value = try? JSONSerialization.jsonObject(with: jsonData, options: []){
            if let object = value as? [String: Any]{
                _value = .object(object: object)
                return
            }
            if let array = value as? [Any]{
                _value = .array(array: array)
                return
            }
        }
        _value = .null
    }
    public var isJSON: Bool{
        get{
            compute()
            switch _value {
            case .object,.array:
                return true
            default:
                return false
            }
        }
    }
    
    public var object: [String: Any]?{
        get{
            compute()
            if case .object(let obj) = _value{
                return obj
            }
            return nil
        }
    }
    public var array: [Any]?{
        get{
            compute()
            if case .array(let array) = _value{
                return array
            }
            return nil
        }
    }
    
    
}



public struct JSArgumment{
    public let _value: JSValue
    fileprivate let _json: JSONBox
    public init(_ jsValue: JSValue) {
        _value = jsValue
        _json = JSONBox(jsValue: jsValue)
    }
}


extension JSArgumment{
    public var isNull: Bool{
        get{ return _value.isNull}
    }
    public var isUndefined: Bool{
        get{ return _value.isUndefined}
    }
    public var isString: Bool{
        get{ return _value.isString}
    }
    public var isNumber: Bool{
        get{ return _value.isNumber}
    }
    public var isBoolean: Bool{
        get{ return _value.isBoolean}
    }
    public var isObject: Bool{
        get{ return _value.isObject}
    }
    public var isArray: Bool{
        get{ return JSValueHelper.jsValueIsArray(_value) }
    }
    public var isDate: Bool{
        get{ return JSValueHelper.jsValueIsDate(_value) }
    }
    public var isFunction: Bool{
        get{ return JSValueHelper.jsValueIsFunction(_value) }
    }
}



struct JSValueHelper{
    static func jsValueIsFunction(_ jsValue: JSValue) -> Bool{
        let valueRef = jsValue.jsValueRef,ctxRef = jsValue.context.jsGlobalContextRef
        guard JSValueIsObject(ctxRef, valueRef) else {
            return false
        }
        return JSObjectIsFunction(ctxRef, valueRef)
    }
    static func jsValueIsArray(_ jsValue: JSValue) -> Bool{
        if #available(iOS 9.0, *) {
            return jsValue.isArray
        } else {
            return jsValue.toArray() != nil
        }
    }
    static func jsValueIsDate(_ jsValue: JSValue) -> Bool{
        if #available(iOS 9.0, *) {
            return jsValue.isDate
        } else {
            return jsValue.toDate() != nil
        }
    }
}




// MARK: Subscript
public enum JSArgummentKey{
    case index(Int)
    case key(String)
}

public protocol JSArgummentSubscriptType {
    var jsa_argumentKey: JSArgummentKey { get }
}

extension Int: JSArgummentSubscriptType{
    public var jsa_argumentKey: JSArgummentKey{
        get{ return JSArgummentKey.index(self) }
    }
}

extension String: JSArgummentSubscriptType{
    public var jsa_argumentKey: JSArgummentKey{
        get{ return JSArgummentKey.key(self) }
    }
}

extension JSArgumment{
    private subscript (index index: Int) -> JSArgumment{
        get{
            if
                isString,
                let array = _json.array,
                let js = JSValue(object: array, in: _value.context){
                return JSArgumment(js.objectAtIndexedSubscript(index))
            }
            return JSArgumment(_value.objectAtIndexedSubscript(index))
        }
    }
    private subscript (key key: String) -> JSArgumment{
        get{
            if
                isString,
                let object = _json.object,
                let js = JSValue(object: object, in: _value.context){
                return JSArgumment(js.objectForKeyedSubscript(key))
            }
            
            return JSArgumment(_value.objectForKeyedSubscript(key))
        }
    }
    private subscript (sub sub: JSArgummentSubscriptType) -> JSArgumment{
        get{
            switch sub.jsa_argumentKey{
            case .index(let idx): return self[index: idx]
            case .key(let str): return self[key: str]
            }
        }
    }
    public subscript (keypath: [JSArgummentSubscriptType]) -> JSArgumment{
        get{
            return keypath.reduce(self){$0[sub: $1]}
        }
    }
    public subscript (keypath: JSArgummentSubscriptType...) -> JSArgumment{
        get{
            return self[keypath]
        }
    }
}

// MARK: Possible Inner Value
extension JSArgumment{
    internal var stringValue: String?{
        get{
            return self.isString || self.isNumber ? self._value.toString() : nil
        }
    }
    internal var numberValue: NSNumber?{
        get{
            if self.isNumber || self.isBoolean {
                return self._value.toNumber()
            }
            if let str = self.stringValue{
                return NSDecimalNumber(string: str)
            }
            return nil
        }
    }

    
}

// MARK: Possible Object Type
extension JSArgumment{
     internal var arrayLength: Int?{
        get{
            if isArray,let length = _value.forProperty("length"),length.isNumber{
                return Int(length.toInt32())
            }
            if let array = _json.array{
                return array.count
            }
            return nil
        }
    }
    internal var objectKeys: [String]?{
        get{
            if isObject,let keys = _value.context.objectForKeyedSubscript("Object").invokeMethod("keys", withArguments: [_value]),JSValueHelper.jsValueIsArray(keys){
                return keys.toArray() as? [String]
            }
            if let obj = _json.object{
                return Array(obj.keys)
            }
            return nil
        }
    }
}

//MARK: - Operator ~
prefix operator ~

public prefix func ~<T: JSArgummentConvertible> (_ argument: JSArgumment) -> T?{
    return T.jsa_fromJSArgument(argument)
}
public prefix func ~<T: JSArgummentConvertible> (_ argument: JSArgumment) -> [T]?{
    guard let count = argument.arrayLength else{
        return nil
    }
    var array = [T]()
    
    for index in 0..<count{
        let subArg = argument[index]
        if let element: T = ~subArg{
            array.append(element)
        }
    }
    return array
}

public prefix func ~<T: JSArgummentConvertible> (_ argument: JSArgumment) -> Set<T>?{
    if let array: [T] = ~argument{
        return Set(array)
    }
    return nil
}


public prefix func ~(_ argument: JSArgumment) -> [Any]?{
    guard let count = argument.arrayLength else{
        return nil
    }
    var array = [Any]()
    
    for index in 0..<count{
        let subArg = argument[index]
        array.append(subArg._value.toObject())
    }
    return array
}
public prefix func ~<T: JSArgummentConvertible>(_ argument: JSArgumment) -> [String: T]?{
    guard let keys = argument.objectKeys else{
        return nil
    }
    var dict = [String: T]()
    for key in keys{
        if let obj: T = ~argument[key]{
            dict[key] = obj
        }
    }
    return dict
}
public prefix func ~(_ argument: JSArgumment) -> [String: Any]?{
    guard let keys = argument.objectKeys else{
        return nil
    }
    var dict = [String: Any]()
    for key in keys{
        dict[key] = argument[key]._value.toObject()
    }
    return dict
}

infix operator <~

public func <~<T: JSArgummentConvertible>(_ left: inout T?,_ right: JSArgumment){
    left = ~right
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout T!,_ right: JSArgumment) -> Bool{
    if let obj: T = ~right{
        left = obj
        return true
    }
    return false
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout T,_ right: JSArgumment) -> Bool{
    if let obj: T = ~right{
        left = obj
        return true
    }
    return false
}

public func <~<T: JSArgummentConvertible>(_ left: inout [T]?,_ right: JSArgumment){
    left = ~right
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout [T]!,_ right: JSArgumment) -> Bool{
    if let obj: [T] = ~right{
        left = obj
        return true
    }
    return false
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout [T],_ right: JSArgumment) -> Bool{
    if let obj: [T] = ~right{
        left = obj
        return true
    }
    return false
}

public func <~<T: JSArgummentConvertible>(_ left: inout Set<T>?,_ right: JSArgumment){
    left = ~right
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout Set<T>!,_ right: JSArgumment) -> Bool{
    if let obj: Set<T> = ~right{
        left = obj
        return true
    }
    return false
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout Set<T>,_ right: JSArgumment) -> Bool{
    if let obj: Set<T> = ~right{
        left = obj
        return true
    }
    return false
}

public func <~<T: JSArgummentConvertible>(_ left: inout [String: T]?,_ right: JSArgumment){
    left = ~right
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout [String: T]!,_ right: JSArgumment) -> Bool{
    if let obj: [String: T] = ~right{
        left = obj
        return true
    }
    return false
}

@discardableResult
public func <~<T: JSArgummentConvertible>(_ left: inout [String: T],_ right: JSArgumment) -> Bool{
    if let obj: [String: T] = ~right{
        left = obj
        return true
    }
    return false
}


