@import Quick;
@import Nimble;
#import <AppCanKit/AppCanKit.h>
#import <AppCanKit/ACEXTScope.h>
@interface EXTScopeTestObject : NSObject
@property (nonatomic,strong)dispatch_block_t myBlock;
@end
@implementation EXTScopeTestObject
- (void)dealloc{
    ACLogInfo(@"DEALLOC!");
}
@end



QuickSpecBegin(EXTScopeSpec)



describe(@"onExitTest", ^{
    dispatch_queue_t testQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    it(@"should be executed when scope exited",^{
        __block NSNumber *num = @0;
        dispatch_async(testQueue, ^{
            @onExit{
                num = @1;
            };
            expect(num).to(equal(@0));
        });
        expect(num).withTimeout(0.1).toEventually(equal(@1));
    });
    
    it(@"should be executed in reverse",^{
        __block NSNumber *num = @0;
        
        dispatch_async(testQueue, ^{
            @onExit{
                expect(num).to(equal(@1));
                num = @2;
            };
            @onExit{
                num = @1;
            };
            expect(num).to(equal(@0));
        });
        expect(num).withTimeout(0.01).toEventually(equal(@2));
    });
});


describe(@"weakifyTest", ^{
    it(@"should avoid retain cycle",^{
        EXTScopeTestObject *obj = [EXTScopeTestObject new];
        __weak EXTScopeTestObject *weakObj = obj;
        @weakify(obj);
        obj.myBlock = ^{
            @strongify(obj);
            ACLogInfo(@"%@",obj.description);
        };
        obj.myBlock();
        obj = nil;
        expect(weakObj).to(beNil());
    });
});




QuickSpecEnd
