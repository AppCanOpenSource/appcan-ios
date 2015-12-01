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

#import "ACUtility.h"
#import "MBProgressHUD.h"

@implementation ACUtility
+ (void)showNetworkActivityIndicator:(BOOL)isShow {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isShow];
}
+(NSString *)getNetData:(NSString*)requestStr urlString:(NSString*)urlString withView:(UIView*)rootView{
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:rootView];
    // Add HUD to screen
    [rootView addSubview:HUD];
	
    // Regisete for HUD callbacks so we can remove it from the window at the right time
    HUD.labelText = ACELocalized(@"请稍候");
	[HUD show:YES];
	NSURL *reqUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:reqUrl];
	NSHTTPURLResponse *response;
	NSData *recData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	[request release];
	[HUD hide:YES];
	[HUD release];
	HUD = nil;
	if (!recData) {
		return nil;
	}
	return [[[NSString alloc] initWithData:recData encoding:NSUTF8StringEncoding] autorelease];
}
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {  
    UIGraphicsBeginImageContext(image1.size);  
	
    // Draw image1  
    [image1 drawInRect:CGRectMake(0,0, image1.size.width, image1.size.height)];  
	
    // Draw image2  
    [image2 drawInRect:CGRectMake(4, 4, image2.size.width, image2.size.height)];  
	
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
	
    UIGraphicsEndImageContext();  
	
    return resultingImage;  
}
+ (UINavigationBar *)createNavigationBarWithBackgroundImage:(UIImage *)backgroundImage title:(NSString *)title {
	float height = backgroundImage.size.height;
	UINavigationBar *customNavigationBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
 	[customNavigationBar setTintColor:[UIColor clearColor]];
	UIImageView *navigationBarBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
	[navigationBarBackgroundImageView setImage:backgroundImage];
	[navigationBarBackgroundImageView setContentMode:UIViewContentModeScaleToFill];
	[customNavigationBar addSubview:navigationBarBackgroundImageView];
	UINavigationItem *navigationTitle = [[UINavigationItem alloc] init];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 160, 46)];
	titleLabel.backgroundColor = [UIColor clearColor];
	[titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:20]];
	[titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setText:title];
	[navigationTitle setTitleView:titleLabel];
	[titleLabel release];
	[customNavigationBar pushNavigationItem:navigationTitle animated:NO];
	[navigationTitle release];
	[navigationBarBackgroundImageView release];
	return customNavigationBar;
}
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
								 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, 10, 10);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *imageMask = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);  //cui 20130603
    return imageMask;
}

@end
