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

#import "BToastView.h"
#import "BUtility.h"
#import <QuartzCore/CALayer.h>


@implementation BToastView

@synthesize mIndicatorView;
//@synthesize mIndicatorIpadView;
@synthesize mTextView;
@synthesize mPos;

+ (CGRect)viewRectWithPos:(int)inPos wndWidth:(float)inWndWidth wndHeight:(float)inWndHeight {
	CGRect toastViewRect;
	int width = 0;
	int height = 0;
	if ([BUtility isIpad]) {
		width = F_TOAST_VIEW_WIDTH_PAD;
		height = F_TOAST_VIEW_HEIGHT_PAD;
	} else {
		width = F_TOAST_VIEW_WIDTH_PHONE;
		height = F_TOAST_VIEW_HEIGHT_PHONE;
	}
	switch (inPos) {
		case 1:
			toastViewRect = CGRectMake(0, 0, width, height);
			break;
		case 2:
			toastViewRect = CGRectMake((inWndWidth-width)/2, 0, width, height);
			break;
		case 3:
			toastViewRect = CGRectMake(inWndWidth-width, 0, width, height);
			break;
		case 4:
			toastViewRect = CGRectMake(0, (inWndHeight-height)/2, width, height);
			break;
		case 5:
			toastViewRect = CGRectMake((inWndWidth-width)/2, (inWndHeight-height)/2, width, height);
			break;
		case 6:
			toastViewRect = CGRectMake(inWndWidth-width, (inWndHeight-height)/2, width, height);
			break;
		case 7:
			toastViewRect = CGRectMake(0, inWndHeight-height, width, height);
			break;
		case 8:
			toastViewRect = CGRectMake((inWndWidth-width)/2, inWndHeight-height, width, height);
			break;
		case 9:
			toastViewRect = CGRectMake(inWndWidth-width, inWndHeight-height, width, height);
			break;
		default:
			break;
	}
	return toastViewRect;
}

- (void)setSubviewsFrame:(CGRect)inRect {
	float textViewHeight = F_TEXTVIEW_POX_HEIGHT_PHONE;
	if ([BUtility isIpad]) {
		textViewHeight = F_TEXTVIEW_POX_HEIGHT_PAD;
	}
	if (mIndicatorView) {
		[mIndicatorView setFrame:CGRectMake((self.bounds.size.width-mIndicatorView.bounds.size.width)/2, (self.bounds.size.height-textViewHeight-mIndicatorView.bounds.size.height)/2+5, mIndicatorView.bounds.size.width, mIndicatorView.bounds.size.height)];
		[mTextView setFrame:CGRectMake(0, self.bounds.size.height-textViewHeight, self.bounds.size.width, textViewHeight)];
	} else {
		[mTextView setFrame:CGRectMake(0, textViewHeight/2, self.bounds.size.width, textViewHeight)];
	}

}

- (id)initWithFrame:(CGRect)frame Type:(int)inType Pos:(int)inPos{
    
    self = [super initWithFrame:frame];
    if (self) {
		mPos = inPos;
		float textViewHeight = F_TEXTVIEW_POX_HEIGHT_PHONE;
		if ([BUtility isIpad]) {
			textViewHeight = F_TEXTVIEW_POX_HEIGHT_PAD;
		}
		switch (inType) {
			case ToastTypeLoading:
				self.backgroundColor = [UIColor blackColor];
				self.alpha = 0.6;
				[self.layer setMasksToBounds:YES];	
				[self.layer setCornerRadius:6.0];
                 /*if ([BUtility isIpad]) {
                    CGRect ipadRect =CGRectMake(frame.size.width/2-21, (frame.size.height-textViewHeight)/2+5, 42, 42);
                    mIndicatorIpadView = [self createIndicatorImgWithFrame:ipadRect];
                    [mIndicatorIpadView retain];
                    [mIndicatorIpadView startAnimating];
                    [self addSubview:mIndicatorIpadView];
               }else{*/
                    mIndicatorView =  [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                    [mIndicatorView setFrame:CGRectMake((frame.size.width-mIndicatorView.bounds.size.width)/2, (frame.size.height-textViewHeight-mIndicatorView.bounds.size.height)/2+5, mIndicatorView.bounds.size.width, mIndicatorView.bounds.size.height)];
                    [mIndicatorView startAnimating];
                    [self addSubview:mIndicatorView];
                //}
				mTextView = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-textViewHeight, frame.size.width, textViewHeight)];
				//mTextView.editable = NO;
				mTextView.backgroundColor = [UIColor clearColor];
				mTextView.textAlignment = NSTextAlignmentCenter;
				mTextView.textColor = [UIColor whiteColor];
				mTextView.numberOfLines = 2;
				if ([BUtility isIpad]) {
					mTextView.font = [UIFont systemFontOfSize:F_TEXTVIEW_FONT_SIZE_PAD];
				} else {
					mTextView.font = [UIFont systemFontOfSize:F_TEXTVIEW_FONT_SIZE_PHONE];
				}
				[self addSubview:mTextView];
				break;
			case ToastTypePlainText:
				self.backgroundColor = [UIColor blackColor];
				self.alpha = 0.6;
				[self.layer setMasksToBounds:YES];	
				[self.layer setCornerRadius:6.0]; 
				mTextView = [[UILabel alloc]initWithFrame:CGRectMake(0, textViewHeight/2, frame.size.width, textViewHeight)];
				//mTextView.editable = NO;
				mTextView.backgroundColor = [UIColor clearColor];
				mTextView.textAlignment = NSTextAlignmentCenter;
				mTextView.numberOfLines = 2;
				mTextView.textColor = [UIColor whiteColor];
				//mTextView.lineBreakMode = UILineBreakModeWordWrap;
				mTextView.numberOfLines = 2;
				if ([BUtility isIpad]) {
					mTextView.font = [UIFont systemFontOfSize:F_TEXTVIEW_FONT_SIZE_PAD];
				} else {
					mTextView.font = [UIFont systemFontOfSize:F_TEXTVIEW_FONT_SIZE_PHONE];
				}
				[self addSubview:mTextView];
				break;
			default:
				break;
		}

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[mIndicatorView release];
	mIndicatorView = nil;
	[mTextView release];
	mTextView = nil;
    [super dealloc];
}
/*
-(UIImageView*)createIndicatorImgWithFrame:(CGRect)inFrame{
    UIImageView *imgView =[[[UIImageView alloc] initWithFrame:inFrame] autorelease];
    NSMutableArray *arrayImg =[[NSMutableArray alloc] initWithCapacity:12];
    for (int i=0; i<12; i++) {
        UIImage *image =[UIImage imageNamed:[NSString stringWithFormat:@"img/indicator/%d",i]];
        [arrayImg addObject:image];
    }
    //imgView.animationDuration = [arrayImg count];
    imgView.animationImages = arrayImg;
    imgView.animationRepeatCount = 0;
    return imgView;
}*/
@end
