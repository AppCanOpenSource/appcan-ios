//
//  ACLog.swift
//  AppCanKit
//
//  Created by CeriNo on 16/9/30.
//  Copyright © 2016年 AppCan. All rights reserved.
//

import Foundation
import AppCanKit


public func ACLogSetGlobalLogMode(_ mode: ACLogMode){
    ACLog.setGlobalLogMode(mode)
}

public func ACLogSetLogModeForThisFile(_ mode: ACLogMode){
    ACLog.setLogMode(mode, forFileNamed: String(describing: #file))
}


public func ACLogSetAsyncLogEnabled(_ isEnabled: Bool){
    ACLog.setAsyncLogEnabled(isEnabled)
}

private func _ACLogMessage(_ message: @autoclosure () -> String, isAsynchronous: Bool, level: ACLogLevel, file: StaticString, function: StaticString, line: UInt){
    ACLog.log(isAsynchronous, level: level, file: String(describing: file), function: String(describing: function), line: line, message: message())
}

public func ACLogError(_ message: @autoclosure () -> String, isAsynchronous: Bool = false, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    _ACLogMessage(message, isAsynchronous: isAsynchronous, level: .error, file: file, function: function, line: line)
}
public func ACLogWarning(_ message: @autoclosure () -> String, isAsynchronous: Bool = true, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    _ACLogMessage(message, isAsynchronous: isAsynchronous, level: .warning, file: file, function: function, line: line)
}
public func ACLogInfo(_ message: @autoclosure () -> String, isAsynchronous: Bool = true, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    _ACLogMessage(message, isAsynchronous: isAsynchronous, level: .info, file: file, function: function, line: line)
}
public func ACLogDebug(_ message: @autoclosure () -> String, isAsynchronous: Bool = true, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    _ACLogMessage(message, isAsynchronous: isAsynchronous, level: .debug, file: file, function: function, line: line)
}
public func ACLogVerbose(_ message: @autoclosure () -> String, isAsynchronous: Bool = true, file: StaticString = #file, function: StaticString = #function, line: UInt = #line){
    _ACLogMessage(message, isAsynchronous: isAsynchronous, level: .verbose, file: file, function: function, line: line)
}
