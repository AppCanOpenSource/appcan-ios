@import Quick;
@import Nimble;
#import <AppCanKit/AppCanKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface ACJSONTestHelper : NSObject
@end
@implementation ACJSONTestHelper
+ (JSContext *)ctx{
    static JSContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[JSContext alloc]init];
        [context evaluateScript:@"var parse = function(json){return JSON.parse(json);};"];
        [context evaluateScript:@"var stringify = function(obj){return JSON.stringify(obj);};"];
    });
    return context;
}

+ (id)JS_JSON_Parse:(NSString *)jsonStr{
    JSValue *parse = self.ctx[@"parse"];
    if (!jsonStr) {
        return nil;
    }
    id obj =[parse callWithArguments:@[jsonStr]].toObject;
    return obj;
}

+ (NSString *)JS_JSON_Stringify:(id)jsonObj{
    JSValue *stringify = self.ctx[@"stringify"];
    if (!jsonObj) {
        return nil;
    }
    return [stringify callWithArguments:@[jsonObj]].toObject;
}

@end




QuickSpecBegin(ACJSONSpec)

describe(@"ACJSONTest", ^{
    NSString *str = @"abcd1234\r\n\\\\t\'\"\b\f!@#$%^&*()_+-=|/";
    NSArray *arr = @[str,str,str];
    NSDictionary *dict = @{str:arr};

    it(@"should make NSString NSArray NSDictionary serializable",^{
        NSString *strJSON,*recursiveStrJSON,*arrJSON,*dictJSON;
        strJSON = str.ac_JSONFragment;
        expect(strJSON).notTo(beNil());
        recursiveStrJSON = str.ac_JSONFragment.ac_JSONFragment.ac_JSONFragment;
        expect(recursiveStrJSON).notTo(beNil());
        arrJSON = arr.ac_JSONFragment;
        expect(arrJSON).notTo(beNil());
        dictJSON = dict.ac_JSONFragment;
        expect(dictJSON).notTo(beNil());
        
        id newStr = strJSON.ac_JSONValue;
        expect(newStr).to(equal(str));
        id recursiveNewStr = [[[recursiveStrJSON ac_JSONValue] ac_JSONValue] ac_JSONValue];
        expect(recursiveNewStr).to(equal(str));
        id newArr = arrJSON.ac_JSONValue;
        expect(newArr).to(equal(arr));
        id newDict = dictJSON.ac_JSONValue;
        expect(newDict).to(equal(dict));
    });

    it(@"should work together with JavaScrpt Function JSON.parse & JSON.stringify",^{
        id newStr1 = [ACJSONTestHelper JS_JSON_Parse:str.ac_JSONFragment];
        expect(newStr1).to(equal(str));
        id newArr1 = [ACJSONTestHelper JS_JSON_Parse:arr.ac_JSONFragment];
        expect(newArr1).to(equal(arr));
        id newDict1 = [ACJSONTestHelper JS_JSON_Parse:dict.ac_JSONFragment];
        expect(newDict1).to(equal(dict));
        
        id newStr2 = [ACJSONTestHelper JS_JSON_Stringify:str].ac_JSONValue;
        expect(newStr2).to(equal(str));
        id newArr2 = [ACJSONTestHelper JS_JSON_Stringify:arr].ac_JSONValue;
        expect(newArr2).to(equal(arr));
        id newDict2 = [ACJSONTestHelper JS_JSON_Stringify:dict].ac_JSONValue;
        expect(newDict2).to(equal(dict));
    });
    
    it(@"should be quick enough",^{
        __block BOOL comeplete = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(NSInteger i = 0 ; i < 10000 ; i++){
                (void)dict.ac_JSONFragment.ac_JSONValue;
            }
            comeplete = YES;
        });
        expect(@(comeplete)).withTimeout(1).toEventually(beTrue());
    });

});


QuickSpecEnd
