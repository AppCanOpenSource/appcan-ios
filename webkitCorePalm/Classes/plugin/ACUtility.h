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


@interface ACUtility : NSObject {

}
+ (UINavigationBar *)createNavigationBarWithBackgroundImage:(UIImage *)backgroundImage title:(NSString *)title;
+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size;
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
+(NSString *)getNetData:(NSString*)requestStr urlString:(NSString*)urlString withView:(UIView*)rootView;
+ (void)showNetworkActivityIndicator:(BOOL)isShow;
@end
