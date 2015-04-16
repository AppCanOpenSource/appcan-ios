/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
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

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ACEWebWindowType) {
    ACEWebWindowTypeNormal, //普通类型
    ACEWebWindowTypeNavigation, //具有手势导航功能
    ACEWebWindowTypePresent, //present
    ACEWebWindowTypeOther
};

#define ACE_USERAGENT @"AppCanUserAgent"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define isSysVersionBelow7_0 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
#define isSysVersionAbove7_0 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define isSysVersionAbove8_0 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define COEFFICIENT ([UIScreen mainScreen].bounds.size.width/320.0)


@interface ACEUtils : NSObject


+ (void)setNavigationBarColor:(UINavigationController *)navController color:(UIColor *)color;

@end
