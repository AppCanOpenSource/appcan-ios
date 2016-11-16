//
//  JSArgumentConvertible.swift
//  JSArgument
//
//  Created by CeriNo on 16/9/29.
//  Copyright © 2016年 SDiC. All rights reserved.
//

import Foundation
import UIKit

public protocol JSArgummentConvertible {
    static func jsa_fromJSArgument(_ argument: JSArgumment) -> Self?
}

//MARK: - String
extension String: JSArgummentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgumment) -> String? {
        if argument.isString || argument.isNumber{
            return argument._value.toString()
        }
        return nil
    }
}

//MARK: - NSNumber
extension NSNumber: JSArgummentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgumment) -> Self? {
        if let number = argument.numberValue{
            return self.init(value: number.doubleValue)
        }
        return nil
    }
}


//MARK: - Basic Numeric Type
private protocol JSArgummentNumericConvertible: JSArgummentConvertible{}

extension JSArgummentNumericConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgumment) -> Self?{
        return argument.numberValue as? Self
    }
}
extension Int: JSArgummentNumericConvertible{}
extension UInt: JSArgummentNumericConvertible{}
extension Int64: JSArgummentNumericConvertible{}
extension UInt64: JSArgummentNumericConvertible{}
extension Float: JSArgummentNumericConvertible{}
extension CGFloat: JSArgummentNumericConvertible{}
extension Double: JSArgummentNumericConvertible{}


//MARK: - Boolean
extension Bool: JSArgummentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgumment) -> Bool? {
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
extension JSFunctionRef: JSArgummentConvertible{
    public static func jsa_fromJSArgument(_ argument: JSArgumment) -> JSFunctionRef? {
        return JSFunctionRef(argument)
    }
}
