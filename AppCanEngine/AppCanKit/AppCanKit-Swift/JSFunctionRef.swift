//
//  JSFunctionRef.swift
//  JSArgument
//
//  Created by CeriNo on 16/9/29.
//  Copyright © 2016年 SDiC. All rights reserved.
//

import Foundation
import JavaScriptCore
import AppCanKit



public final class JSFunctionRef{
    private static let GlobalContainerKeyPath: NSString = "__jsa_functionContainer"
    private static let GlobalContainer = NSObject()
    let uuid = UUID().uuidString
    weak var ctx: JSContext?
    private var managedValue: JSManagedValue
    
    private var jsFunc: JSValue?{
        get{
            if let jsfunc = managedValue.value{
                return jsfunc
            }
            if let globalContainerJS = ctx?.objectForKeyedSubscript(JSFunctionRef.GlobalContainerKeyPath),globalContainerJS.hasProperty(uuid){
                return globalContainerJS.forProperty(uuid)
            }
            return nil
        }
    }
    
    init?(_ argument: JSArgument){
        guard argument.isFunction else{
            return nil
        }
        
        let jsFunction = argument._value
        managedValue = JSManagedValue(value: jsFunction)
        ctx = jsFunction.context
        container(inContext: ctx)?.setObject(jsFunction, forKeyedSubscript: uuid as NSString)
        ctx?.virtualMachine.addManagedReference(managedValue, withOwner: JSFunctionRef.GlobalContainer)
        ACLogVerbose("JSFunctionRef<\(String(ObjectIdentifier(self).hashValue))> init")
    }
    
    deinit {
        if let ctx = ctx{
            ctx.virtualMachine.removeManagedReference(managedValue, withOwner: JSFunctionRef.GlobalContainer)
            container(inContext: ctx)?.setObject(ACNil.null(), forKeyedSubscript: uuid as NSString)
        }
        ACLogVerbose("JSFunctionRef<\(String(ObjectIdentifier(self).hashValue))> deinit")
    }
    
    private func container(inContext ctx: JSContext?) -> JSValue?{
        if
            let ctx = ctx,
            let container = ctx.objectForKeyedSubscript(JSFunctionRef.GlobalContainerKeyPath),
            container.isUndefined{
                    ctx.setObject(JSFunctionRef.GlobalContainer, forKeyedSubscript: JSFunctionRef.GlobalContainerKeyPath)
                }
        
        
        return ctx?.objectForKeyedSubscript(JSFunctionRef.GlobalContainerKeyPath)
    }
    
    @discardableResult
    public func executeSync(withArguments args: [Any]?,inQueue: DispatchQueue? = nil) -> JSValue?{
        if let inQueue = inQueue{
            var returnValue: JSValue? = nil;
            inQueue.sync {
                returnValue = jsFunc?.call(withArguments: args)
            }
            return returnValue
        }else{
            return jsFunc?.call(withArguments: args)
        }
    }
    
    public func execute(withArguments args: [Any]?,
                        inQueue queue: DispatchQueue = DispatchQueue.main,
                        waitingUntilNextRunLoop: Bool = true,
                        completionHandler: ((JSValue?) -> Void)? = nil){
        func callback(_ value: JSValue?){
            if let completionHandler = completionHandler{
                completionHandler(value)
            }
        }
        queue.async {
            let exec: @convention(block)() -> Void = {[unowned self] in
                if let jsFunc = self.jsFunc{
                    let returnValue = jsFunc.call(withArguments: args)
                    callback(returnValue)
                }else{
                    callback(nil)
                }
            }
            if waitingUntilNextRunLoop,
                let setTimeout = self.ctx?.objectForKeyedSubscript("setTimeout"),
                JSValueHelper.jsValueIsFunction(setTimeout){
                setTimeout.call(withArguments: [unsafeBitCast(exec, to: AnyObject.self),0])
            }else{
                exec()
            }
        }
    }
}
