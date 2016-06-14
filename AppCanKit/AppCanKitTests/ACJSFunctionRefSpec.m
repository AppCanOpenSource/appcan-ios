@import Quick;
@import Nimble;

#import <AppCanKit/AppCanKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ACJSFunctionRefInternal.h"

QuickSpecBegin(ACJSFunctionRefSpec)

describe(@"ACJSFunctionRef Test", ^{
    __block JSContext *ctx = nil;
    __block BOOL executed = NO;
    __block void (^exec)(void) = nil;
    __block JSValue *func = nil;
    __block ACJSFunctionRef *funcRef = nil;
    beforeEach(^{
        ctx = [[JSContext alloc]init];
        executed = NO;
        exec = ^{
            ACLogInfo(@"function executed!");
            executed = YES;
        };
        func = [JSValue valueWithObject:exec inContext:ctx];
        funcRef = [ACJSFunctionRef functionRefFromJSValue:func];
        
    });
    
    it(@"can execute the source JSFunction",^{
        [funcRef executeWithArguments:nil completionHandler:^(JSValue * _Nullable returnValue) {
            expect(returnValue).toNot(beNil());
            expect(@(executed)).to(beTrue());
        }];
        
    });

    
    
});

QuickSpecEnd
