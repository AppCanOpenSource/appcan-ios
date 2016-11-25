@import Quick;
@import Nimble;
#import <JavaScriptCore/JavaScriptCore.h>
#import <AppCanKit/AppCanKit.h>
#import "ACJSFunctionRefInternal.h"
QuickSpecBegin(ACArgumentsSpec)

describe(@"Arg Function Test", ^{
    JSContext *ctx = [[JSContext alloc]init];

    context(@"stringArg Test", ^{
        expect(stringArg(@"123")).to(equal(@"123"));
        expect(stringArg(@123)).to(equal(@"123"));
        expect(stringArg([JSValue valueWithInt32:123 inContext:ctx])).to(equal(@"123"));
        expect(stringArg([JSValue valueWithObject:@"123" inContext:ctx])).to(equal(@"123"));
        expect(stringArg([JSValue valueWithObject:@123 inContext:ctx])).to(equal(@"123"));
        expect(stringArg(@[])).to(beNil());
        expect(stringArg([JSValue valueWithObject:@{} inContext:ctx])).to(beNil());
        
    });
    
    context(@"numberArg Test", ^{
        expect(numberArg(@123)).to(equal(@123));
        expect(numberArg(@"123")).to(equal(@123));
        expect(numberArg([JSValue valueWithInt32:123 inContext:ctx])).to(equal(@123));
        expect(numberArg([JSValue valueWithObject:@123 inContext:ctx])).to(equal(@123));
        expect(numberArg([JSValue valueWithObject:@"123" inContext:ctx])).to(equal(@123));
        expect(numberArg([JSValue valueWithObject:@{} inContext:ctx])).to(beNil());
        expect(numberArg(@[])).to(beNil());
        expect(numberArg(@"")).to(beNil());
    });
    
    context(@"arrayArg Test", ^{
        NSArray *array = @[@1,@2,@"3"];
        expect(arrayArg(array)).to(equal(array));
        expect(arrayArg(array.ac_JSONFragment)).to(equal(array));//assume that ac_JSONFragment works fine,see ACJSONSepc.m
        expect(arrayArg([JSValue valueWithObject:array inContext:ctx])).to(equal(array));
        expect(arrayArg(@[@1,@2,@3])).toNot(equal(array));
        expect(arrayArg(@"1,2,3")).to(beNil());
        expect(arrayArg(@{})).to(beNil());
        expect(arrayArg([JSValue valueWithObject:@{} inContext:ctx])).to(beNil());
    });
    
    context(@"dictionaryArg Test", ^{
        NSDictionary *dict = @{
                               @"text":@"textValue",
                               @"array":@[@"arr1",@"arr2",@3],
                               @"bool":@(YES),
                               @"num":@(123.456)
                               };
        expect(dictionaryArg(dict)).to(equal(dict));
        expect(dictionaryArg(dict.ac_JSONFragment)).to(equal(dict));
        expect(dictionaryArg([JSValue valueWithObject:dict inContext:ctx])).to(equal(dict));
        expect(dictionaryArg(@[])).to(beNil());
        expect(dictionaryArg([JSValue valueWithObject:@[] inContext:ctx])).to(beNil());
    });
    
    context(@"JSFunctionRefArg Test",^{

        void (^exec)(void) = ^{};
        JSValue *func = [JSValue valueWithObject:exec inContext:ctx];
        ACJSFunctionRef *funcRef = [ACJSFunctionRef functionRefFromJSValue:func];
        expect(JSFunctionArg(func)).notTo(beNil());
        expect(JSFunctionArg(funcRef)).notTo(beNil());
        expect(JSFunctionArg([JSValue valueWithObject:@{} inContext:ctx])).to(beNil());
        
    });
    
    
});


describe(@"ACArgsPack Test", ^{
    it(@"should not crash  and get an ACNil with nil value",^{
        id obj1 = [UIView new];
        id obj2 = nil;
        id obj3 = [UIView new];
        __block NSArray *array = nil;
        expectAction(^{
            array = ACArgsPack(obj1,obj2,obj3);
        }).notTo(raiseException());
        expect(@(array.count)).to(equal(@3));
        expect(array[0]).to(beIdenticalTo(obj1));
        expect(array[1]).to(beIdenticalTo([ACNil null]));
        expect(array[2]).to(beIdenticalTo(obj3));
    });
    it(@"should work with only one values",^{
        __block NSArray *array = nil;
        expectAction(^{
            array = ACArgsPack(@0);
        }).notTo(raiseException());
        expect(array).to(equal(@[@0]));
    });
    
    it(@"should work with <=10 values",^{
        __block NSArray *array = nil;
        array = nil;
        expectAction(^{
            array = ACArgsPack(@0,@1,@2,@3,@4,@5,@6,@7,@8,@9);
        }).notTo(raiseException());
        expect(array).to(equal(@[@0,@1,@2,@3,@4,@5,@6,@7,@8,@9]));
    });
    
});

describe(@"ACArgsUnpack Test", ^{
    NSNumber *num = @1;
    NSString *str = @"2";
    NSArray *array = @[@3];
    NSDictionary *dict = @{@"4":@5};
    
    it(@"should unpack values(s)",^{

        ACArgsUnpack(id obj) = @[num];
        expect(obj).to(beIdenticalTo(num));
        
        ACArgsUnpack(id obj1,id obj2,id obj3) = @[num,str,array];
        expect(obj1).to(beIdenticalTo(num));
        expect(obj2).to(beIdenticalTo(str));
        expect(obj3).to(beIdenticalTo(array));
    });
    
    it(@"should translate ACNil to nil",^{
        ACArgsUnpack(id obj) = @[[ACNil null]];
        expect(obj).to(beNil());
    });
    
    it(@"should fill in missing values with nil",^{
        ACArgsUnpack(id obj1,id obj2) = @[@1];
        expect(obj1).to(equal(@1));
        expect(obj2).to(beNil());
    });
    it(@"should skip values not assigned to",^{
        ACArgsUnpack(id obj1) = @[@1,@2,@3];
        expect(obj1).to(equal(@1));
    });
    it(@"should auto translate NSString NSNumber NSArray NSDictionary",^{
        ACArgsUnpack(NSNumber *num1,NSString *str1,NSArray *array1,NSDictionary *dict1) = @[stringArg(num),numberArg(str),array.ac_JSONFragment,dict.ac_JSONFragment];
        expect(num1).to(equal(num));
        expect(str1).to(equal(str));
        expect(array1).to(equal(array));
        expect(dict1).to(equal(dict));
    });
    
    
});




QuickSpecEnd
