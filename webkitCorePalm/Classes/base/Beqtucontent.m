//
//  Beqtucontent.m
//  WBPlam
//
//  Created by Leilei Xu on 12-7-23.
//  Copyright (c) 2012年 zywx. All rights reserved.
//

#import "Beqtucontent.h"

@implementation Beqtucontent

static NSString *html5appcandemo = @"2b58c018-7515-4072-a719-fcb826f2b874";

+(NSString*)getContentPath{
    if (!html5appcandemo) {
        return @"";
    }
return html5appcandemo;
}
@end
