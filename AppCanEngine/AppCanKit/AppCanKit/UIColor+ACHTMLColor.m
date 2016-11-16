/**
 *
 *	@file   	: UIColor+ACHTMLColor.m  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/31.
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "UIColor+ACHTMLColor.h"

@implementation UIColor (ACHTMLColor)

+ (nullable instancetype)ac_ColorWithHTMLColorString:(nonnull NSString *)htmlColorStr{
    NSString *colorString = [htmlColorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    UIColor *resultColor = nil;
    if([self ac_parseColor:&resultColor fromHexString:colorString]){
        return resultColor;
    }
    if([self ac_parseColor:&resultColor fromRGBString:colorString]){
        return resultColor;
    }
    return nil;
}

+ (BOOL)ac_parseColor:(UIColor **)color fromHexString:(NSString *)colorString{
    if(![colorString hasPrefix:@"#"]){
        return NO;
    }
    NSRange range;
    NSMutableArray *colorArray=[NSMutableArray arrayWithCapacity:4];
    switch ([colorString length]) {
        case 4:{//"#123"型字符串
            [colorArray addObject:@"ff"];
            for(int k=0;k<3;k++){
                range.location=k+1;
                range.length=1;
                NSMutableString *tmp=[[colorString substringWithRange:range] mutableCopy];
                [tmp  appendString:tmp];
                [colorArray addObject:tmp];
                
            }
            break;
        }
        case 7:{//"#112233"型字符串
            [colorArray addObject:@"ff"];
            for(int k=0;k<3;k++){
                range.location=2*k+1;
                range.length=2;
                [colorArray addObject:[colorString substringWithRange:range]];
                
            }
            break;
        }
        case 9:{//"#11223344"型字符串
            for(int k=0;k<4;k++){
                range.location=2*k+1;
                range.length=2;
                [colorArray addObject:[colorString substringWithRange:range]];
            }
            break;
        }
        default:{
            return NO;
            break;
        }
    }
    unsigned int r,g,b,a;
    [[NSScanner scannerWithString:colorArray[0]] scanHexInt:&a];
    [[NSScanner scannerWithString:colorArray[1]] scanHexInt:&r];
    [[NSScanner scannerWithString:colorArray[2]] scanHexInt:&g];
    [[NSScanner scannerWithString:colorArray[3]] scanHexInt:&b];
    *color = [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:(float)a/255.0];
    if(!*color){
        return NO;
    }
    return YES;
}

+ (BOOL)ac_parseColor:(UIColor **)color fromRGBString:(NSString *)colorString{
    NSArray *rgbArray = nil;
    if ([colorString hasPrefix:@"rgb("]&&[colorString hasSuffix:@")"]){
        colorString = [colorString substringWithRange:NSMakeRange(4, [colorString length] -5)];
        rgbArray = [colorString componentsSeparatedByString:@","];
    }
    if ([colorString hasPrefix:@"rgba("]&&[colorString hasSuffix:@")"]){
        colorString = [colorString substringWithRange:NSMakeRange(5, [colorString length] -6)];
        rgbArray = [colorString componentsSeparatedByString:@","];
    }
    if(!rgbArray|| [rgbArray count]<3){
        return NO;
    }
    
    CGFloat (^rgbValue)(NSString *) = ^CGFloat(NSString *colorInfo){
        colorInfo = [colorInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        CGFloat value = 0;
        if([colorInfo hasSuffix:@"%"]){
            colorInfo = [colorInfo substringWithRange:NSMakeRange(0, [colorInfo length] - 1)];
            return [colorInfo floatValue]/100.0;
        }
        value = [colorInfo floatValue];
        if(value>0 && value <1){
            return value;
        }
        return value/255.0;
    };
    
    CGFloat alpha = 1;
    if([rgbArray count]>3 && [rgbArray[3] isKindOfClass:[NSString class]]){
        alpha = rgbValue(rgbArray[3]);
    }
    *color = [UIColor colorWithRed:rgbValue(rgbArray[0])
                             green:rgbValue(rgbArray[1])
                              blue:rgbValue(rgbArray[2])
                             alpha:alpha];
    if(!*color){
        return NO;
    }
    return YES;
    
}

@end
