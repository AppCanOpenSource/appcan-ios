//
//  JSFunctionRef.swift
//  JSArgument
//
//  Created by CeriNo on 16/9/29.
//  Copyright © 2016年 SDiC. All rights reserved.
//

import Foundation
import JavaScriptCore



public final class JSFunctionRef{
    private static let GlobalContainerKeyPath: NSString = "__jsa_functionContainer"
    public weak var ctx: JSContext?
    private var _func: JSManagedValue?
    private var jsFunc: JSValue?{
        get{ return _func?.value }
    }
    
    internal init?(_ argument: JSArgumment){
        guard argument.isFunction else{
            return nil
        }
        ACLogVerbose("JSFunctionRef<\(String(ObjectIdentifier(self).hashValue))> init")
        let jsFunction = argument._value
        _func = JSManagedValue(value: jsFunction)
        ctx = jsFunction.context
        jsFunction.context.virtualMachine.addManagedReference(_func, withOwner: container(inContext: ctx))
    }
    
    deinit {
        if let ctx = ctx{
            ctx.virtualMachine.removeManagedReference(_func, withOwner: container(inContext: ctx))
        }
        ACLogVerbose("JSFunctionRef<\(String(ObjectIdentifier(self).hashValue))> deinit")
    }
    
    private func container(inContext ctx: JSContext?) -> JSValue?{
        guard let ctx = ctx else{
            return nil
        }
        var container = ctx.objectForKeyedSubscript(JSFunctionRef.GlobalContainerKeyPath)!
        if container.isUndefined {
            container = JSValue(newObjectIn: ctx);
            ctx.setObject(container, forKeyedSubscript: JSFunctionRef.GlobalContainerKeyPath)
        }
        return container
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
