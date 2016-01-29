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

#import "AppItemView.h"
#import <QuartzCore/CALayer.h>
#import "ACUtility.h"
#import "BUtility.h"

#define kWobbleRadians 1.5
#define kWobbleTime 0.07
@implementation AppItemView
@synthesize delegate = _delegate;
@synthesize softwareId,appId,downloadUrl,appName,appIconUrl,appSize;
@synthesize downloadTag;
@synthesize progressView;
@synthesize isMyAppItem;
@synthesize appMode;
@synthesize btn;
@synthesize actView;
- (id)initWithFrame:(CGRect)frame image:(NSURL *)imgUrl title:(NSString *)titleText appTag:(NSString *)_appId{
		if (self = [super init]) {
			self.frame =frame;
			self.appId = _appId;
			// Initialization code.
		[self setUserInteractionEnabled:YES]; 
		 btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(0, 0, 65, 65)];
	    if (downloadTag==1) {
			[btn setEnabled:NO];
		}
		[btn addTarget:self action:@selector(iconBtnClick:) forControlEvents:UIControlEventTouchUpInside];		
		if (isMyAppItem==YES) {

			UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(iconLongPress:)];
 			longPressRecognizer.allowableMovement = 10;
			[longPressRecognizer setMinimumPressDuration:1.0];
			[btn addGestureRecognizer:longPressRecognizer];        
			[longPressRecognizer release];
			//progress
			 progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(4, 40, 57, 8)];
			[progressView setProgressViewStyle:UIProgressViewStyleDefault];
			[progressView setHidden:YES];
			[btn addSubview:progressView];
		}
			if (_appId) {
			 [btn setTag:[_appId intValue]];
			}else {
			 [btn setTag:0];
			}
			UIImage *btnImage = nil;
			if (btn.tag==9999997) {
				btnImage = [UIImage imageNamed:@"img/my_space_add.png"];
			}else {
				btnImage = [UIImage imageNamed:@"img/my_space_download.png"];
			}
			//把图片弄成圆角
	 		UIImage *roundRectImage = [ACUtility createRoundedRectImage:btnImage size:CGSizeMake(57, 57)];
 			[btn setImage:roundRectImage forState:UIControlStateNormal];
			if ([[imgUrl absoluteString] hasPrefix:@"http://"]) {
				actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[actView setFrame:CGRectMake(20, 20, 20, 20)];
				[actView startAnimating];
				[self addSubview:actView];
				[actView release];
				SDWebImageManager *IMgr = [SDWebImageManager sharedManager];
				[IMgr downloadWithURL:imgUrl delegate:self];
 
			}else {
				if (isMyAppItem==YES&&downloadTag!=3) {
					//加蒙版
					UIImage *image = [UIImage imageNamed:@"img/zhezhao.png"];
					UIImage *roundRectImage = [ACUtility createRoundedRectImage:image size:CGSizeMake(57, 57)];
					[btn setImage:roundRectImage forState:UIControlStateNormal];					
				}else {
					UIImage *nBtnImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
					UIImage *roundImage = [ACUtility createRoundedRectImage:nBtnImage size:CGSizeMake(57, 57)];
					[btn setImage:roundImage forState:UIControlStateNormal];
				}
		}
		UIImage *highImage = [ACUtility addImage:[UIImage imageNamed:@"img/my_space_blue_side.png"] toImage:roundRectImage];
		[btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
		//title
	 	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65+5, 65, 15)];
 		[label setBackgroundColor:[UIColor clearColor]];
		label.text = titleText;
		label.textAlignment = NSTextAlignmentCenter;
		[label setFont:[UIFont fontWithName:@"ArialMT" size:12]];
		[self addSubview:btn];
		[self addSubview:label];
		[label release];
		}
	return self;
}
-(void)iconLongPress:(UILongPressGestureRecognizer *)sender{
	
	NSString *appid = [NSString stringWithFormat:@"%ld",sender.view.tag];
	if ([_delegate respondsToSelector:@selector(sendAppIdForLongPress:)]) {
		[_delegate sendAppIdForLongPress:appid];
	}
}
-(void)iconBtnClick:(id)sender{
	UIButton *button = (UIButton *)sender;
	if ([_delegate respondsToSelector:@selector(iconItemClick:)]) {
		[_delegate iconItemClick:[NSString stringWithFormat:@"%ld",(long)button.tag]];
	}
}
- (void)setProgress:(float)newProgress{
	ACENSLog(@"new progress = %f",newProgress);
	self.progressView.progress = newProgress;
	
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    // Do something with the downloaded image
	ACENSLog(@"download image success");
	if (isMyAppItem==YES&&self.downloadTag!=3) {
		//加蒙版
		UIImage *image = [UIImage imageNamed:@"img/zhezhao.png"];
		UIImage *roundRectImage = [ACUtility createRoundedRectImage:image size:CGSizeMake(57, 57)];
		[btn setImage:roundRectImage forState:UIControlStateNormal];
	}else {
		UIImage *roundRectImage = [ACUtility createRoundedRectImage:image size:CGSizeMake(57, 57)];
		[btn setImage:roundRectImage forState:UIControlStateNormal];
	}
	if (actView) {
		[actView stopAnimating];
	}
	[self setNeedsDisplay];
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error{
	UIImage *btnImage = [UIImage imageNamed:@"img/my_space_download.png"];
	UIImage *roundRectImage = [ACUtility createRoundedRectImage:btnImage size:CGSizeMake(57, 57)];
	[btn setImage:roundRectImage forState:UIControlStateNormal];
	if (actView) {
		[actView stopAnimating];
	}
}
-(void)updateImage{
	SDWebImageManager *IMgr = [SDWebImageManager sharedManager];
	[IMgr downloadWithURL:self.appIconUrl delegate:self];
}
- (void)dealloc {
	[progressView release];
    [super dealloc];
}
@end
