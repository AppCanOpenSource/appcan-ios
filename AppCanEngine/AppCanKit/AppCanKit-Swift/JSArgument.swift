//
//  JSArgument.swift
//  JSArgument
//
//  Created by CeriNo on 16/9/29.
//  Copyright © 2016年 SDiC. All rights reserved.
//

import Foundation
import JavaScriptCore

public struct JSArgumment{
    public let _value: JSValue
    public init(_ jsValue: JSValue) {
        _value = jsValue
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
            return JSArgumment(_value.objectAtIndexedSubscript(index))
        }
    }
    private subscript (key key: String) -> JSArgumment{
        get{
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
    internal var jsonValue: JSValue{
        get{
            return _value.context.objectForKeyedSubscript("JSON").invokeMethod("parse", withArguments: [_value])
        }
    }
    
}

// MARK: Possible Object Type
extension JSArgumment{
     internal var arrayLength: Int?{
        get{
            var value = _value
            if !isArray {
                value = jsonValue
            }
            guard JSValueHelper.jsValueIsArray(value) ,
                let length = value.forProperty("length"),
                length.isNumber else {
                    return nil
            }
            return Int(length.toUInt32())
        }
    }
    internal var objectKeys: [String]?{
        get{
            if isObject,let keys = _value.context.objectForKeyedSubscript("Object").invokeMethod("keys", withArguments: [_value]),JSValueHelper.jsValueIsArray(keys){
                return keys.toArray() as? [String]
            }
            if isString,
                let jsonData = stringValue?.data(using: .utf8),
                let obj = try? JSONSerialization.jsonObject(with: jsonData, options: []) ,
                let jsonObj = obj as? [String: Any]{
                return Array(jsonObj.keys)
            }
            return nil
        }
    }
}

//MARK: - Operator
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


