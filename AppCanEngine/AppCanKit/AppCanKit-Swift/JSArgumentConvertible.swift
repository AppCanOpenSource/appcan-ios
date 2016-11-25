//
//  JSArgumentConvertible.swift
//  JSArgument
//
//  Created by CeriNo on 16/9/29.
//  Copyright © 2016年 SDiC. All rights reserved.
//

import Foundation
import UIKit

public protocol JSArgumentConvertible {
    static func jsa_fromJSArgument(_ argument: JSArgument) -> Self?
}

//MARK: - String
extension String: JSArgumentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgument) -> String? {
        if argument.isString || argument.isNumber{
            return argument._value.toString()
        }
        return nil
    }
}

//MARK: - NSNumber
extension NSNumber: JSArgumentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgument) -> Self? {
        if let number = argument.numberValue{
            return self.init(value: number.doubleValue)
        }
        return nil
    }
}


//MARK: - Basic Numeric Type
private protocol JSArgumentNumericConvertible: JSArgumentConvertible{}

extension JSArgumentNumericConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgument) -> Self?{
        return argument.numberValue as? Self
    }
}
extension Int: JSArgumentNumericConvertible{}
extension UInt: JSArgumentNumericConvertible{}
extension Int64: JSArgumentNumericConvertible{}
extension UInt64: JSArgumentNumericConvertible{}
extension Float: JSArgumentNumericConvertible{}
extension CGFloat: JSArgumentNumericConvertible{}
extension Double: JSArgumentNumericConvertible{}


//MARK: - Boolean
extension Bool: JSArgumentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgument) -> Bool? {
        if let str = argument.stringValue {
            if str == "true" {
                return true
            }
            if str == "false" {
                return false
            }
        }
        if let number = argument.numberValue{
            return number.boolValue
        }
        return nil
    }
}

//MARK: - Function
extension JSFunctionRef: JSArgumentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgument) -> JSFunctionRef? {
        return JSFunctionRef(argument)
    }
}
