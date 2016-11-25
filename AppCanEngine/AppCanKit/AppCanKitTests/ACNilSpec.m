@import Quick;
@import Nimble;
#import <AppCanKit/AppCanKit.h>
QuickSpecBegin(ACNilSpec)

describe(@"ACNilTest", ^{
    __block ACNil *aNil = nil;
    beforeEach(^{
        aNil = [ACNil null];
    });
    
    it(@"should be equal to nil,NSNull",^{
        expect(@([aNil isEqual:nil])).to(beTrue());
        expect(@([aNil isEqual:[NSNull null]])).to(beTrue());
    });
    
    it(@"should be a kind of class NSNull,but not any other class",^{
        expect(@([aNil isKindOfClass:[NSNull class]])).to(beTrue());
        expect(@([aNil isKindOfClass:[NSObject class]])).to(beFalse());
    });
    
    it(@"should be singleton",^{
        ACNil *anotherNil = [ACNil null];
        expect(aNil).to(beIdenticalTo(anotherNil));
    });
    
    it(@"should not respond to any selector",^{
        expect(@([aNil respondsToSelector:@selector(length)])).to(beFalse());
        expect(@([aNil respondsToSelector:@selector(stringValue)])).to(beFalse());
        expect(@([aNil respondsToSelector:@selector(setObject:forKey:)])).to(beFalse());

    });
    it(@"should not crash when sending wrong selectors,and return empty value if needed",^{
        expect(@([(id)aNil length])).notTo(raiseException());
        expect(@([(id)aNil length])).to(equal(@0));
        expect([(id)aNil stringValue]).notTo(raiseException());
        expect([(id)aNil stringValue]).to(beNil());
        expectAction(^{
            [(id)aNil setObject:@"1" forKey:@"2"];
        }).notTo(raiseException());
    });

    
});

QuickSpecEnd
