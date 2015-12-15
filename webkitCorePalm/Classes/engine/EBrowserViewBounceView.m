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

#import "EBrowserViewBounceView.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat defaultTransitionDuration      = 0.3f;
const CGFloat defaultFastTransitionDuration  = 0.2f;
const CGFloat defaultFlipTransitionDuration  = 0.7f;

@implementation EBrowserViewBounceView
@synthesize projectID;

double radians(float degrees){
    return (degrees*3.14159265)/180.0;
}

- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
  if (shouldShow) {
    [mActivityView startAnimating];
      
      CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
      animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
      //      CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
      animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
      if (self.isImgCenter) {
          animation.toValue = [ NSValue valueWithCATransform3D:CATransform3DMakeRotation(radians(-270.0), 0, 0, 1.0) ];
          
          animation.duration = 0.2;
      } else {
          animation.toValue = [ NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 1.0, 0) ];
          
          animation.duration = 1;
      }
      animation.cumulative = YES;
      animation.repeatCount = HUGE_VALF;
      [mActivityImageView.layer addAnimation:animation forKey:@"active"];
      mActivityImageView.hidden=NO;
  } else {
    [mActivityView stopAnimating];
      [mActivityImageView.layer removeAnimationForKey:@"active"];
      mActivityImageView.hidden=YES;
  }
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:(animated ? defaultFastTransitionDuration : 0.0)];
  mArrowImage.alpha = (shouldShow ? 0.0 : 1.0);
  [UIView commitAnimations];
}

- (void)setImageFlipped:(BOOL)flipped {
    float x=0.0,y=0.0,z=1.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:defaultFlipTransitionDuration];
    CATransform3D transform;
    if (mType == EBounceViewTypeTop) {
        if (flipped) {
            transform = CATransform3DMakeRotation(0, x, y, z);
        } else {
            transform = CATransform3DMakeRotation(M_PI, x, y, z);
        }
        [mArrowImage layer].transform = transform;
    } else if (mType == EBounceViewTypeBottom) {
        if (flipped) {
            transform = CATransform3DMakeRotation(M_PI, x, y, z);
        } else {
            transform = CATransform3DMakeRotation(M_PI * 2.0, x, y, z);
        }
        [mArrowImage layer].transform = transform;
    }
    [UIView commitAnimations];
}

-(void)resetDataWithType:(int)inType andParams:(NSMutableDictionary *)dict {
    
    self.isImgCenter = NO;
    if ([[dict objectForKey:@"levelText"] length] == 0 && [[dict objectForKey:@"loadingText"] length] == 0 && [[dict objectForKey:@"pullToReloadText"] length] == 0 && [[dict objectForKey:@"releaseToReloadText"] length] == 0 && [[dict objectForKey:@"textColor"] length] == 0) {
        if ([[dict allKeys] count] > 0) {
            self.isImgCenter = YES;
        }
    }
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (bounceParamsDict) {
        [bounceParamsDict removeAllObjects];
        [bounceParamsDict release];
    }
    id colorObj = nil;
    id imgObj = nil;
    id levelObj = nil;
    id imgInObj = nil;
    if (dict) {
        
        bounceParamsDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        id typeStr = [bounceParamsDict objectForKey:@"type"];
        
        if (typeStr && [typeStr intValue] == inType) {
            
            colorObj = [bounceParamsDict objectForKey:@"textColor"];
            imgObj = [bounceParamsDict objectForKey:@"imagePath"];
            levelObj = [bounceParamsDict objectForKey:@"levelText"];
            imgInObj = [bounceParamsDict objectForKey:@"loadingImagePath"];
            
        }
    }
    mType = inType;
    if (inType == EBounceViewTypeTop)
    {
        
        mLastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        mLastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
        if (levelObj) {
            mLastUpdatedLabel.text = [NSString stringWithString:(NSString*)levelObj];
        }
        mLastUpdatedLabel.textColor = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mLastUpdatedLabel.textColor = (UIColor*)colorObj;
        }
        //
        mLastUpdatedLabel.backgroundColor = [UIColor clearColor];
        mLastUpdatedLabel.textAlignment   = NSTextAlignmentCenter;
        
        mStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        mStatusLabel.font             = [UIFont boldSystemFontOfSize:14.0f];
        mStatusLabel.textColor        = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mStatusLabel.textColor = (UIColor*)colorObj;
        }
        
        mStatusLabel.backgroundColor  = [UIColor clearColor];
        mStatusLabel.textAlignment    = NSTextAlignmentCenter;
        [self setStatus:EBounceViewStatusPullToReload];
        
        UIImage* arrowImage = [UIImage imageNamed:@"img/blueArrow.png"];
        if (imgObj) {
            UIImage * tempImg = [UIImage imageWithContentsOfFile:(NSString*)imgObj];
            if (tempImg) {
                arrowImage = tempImg;
            }
            
        }
        mArrowImage.frame = CGRectMake(25.0f, self.frame.size.height - 52.0f, arrowImage.size.width, arrowImage.size.height);
        if (self.isImgCenter) {
            CGRect tempRect = mArrowImage.frame;
            tempRect.origin.x = (self.frame.size.width - arrowImage.size.width)*0.5;
            mArrowImage.frame = tempRect;
        }
        
        mArrowImage.image = arrowImage;
        [mArrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
        
        
        NSString * pjID =  [bounceParamsDict objectForKey:@"projectID"];
        if ([pjID isKindOfClass:[NSString class]] && pjID.length>0)
        {
            if ([pjID isEqualToString:@"donghang"])
            {
                UIImage* arrowImage = nil;
                if (imgInObj) {
                    arrowImage =[UIImage imageWithContentsOfFile:(NSString*)imgInObj];
                }
                
                
                
                mActivityImageView.image = arrowImage;
                mActivityImageView.hidden=YES;
                
            }
        }else
        {
            
            if (self.isImgCenter) {
                mActivityView.frame = mArrowImage.frame;
            } else {
                mActivityView.frame = CGRectMake( 30.0f, self.frame.size.height - 48.0f, 20.0f, 20.0f );
            }
            
            mActivityView.hidesWhenStopped  = YES;
            
        }
        
    }
    else if (inType == EBounceViewTypeBottom)
    {
        //mLastUpdatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 28.0f, frame.size.width, 20.0f)];
        mLastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        mLastUpdatedLabel.font            = [UIFont systemFontOfSize:12.0f];
        if (levelObj) {
            mLastUpdatedLabel.text =[NSString stringWithString:(NSString*)levelObj];
        }
        mLastUpdatedLabel.textColor       = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mLastUpdatedLabel.textColor = (UIColor*)colorObj;
        }
        //mLastUpdatedLabel.shadowColor     = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        //mLastUpdatedLabel.shadowOffset    = CGSizeMake(0.0f, 1.0f);
        mLastUpdatedLabel.backgroundColor = [UIColor clearColor];
        mLastUpdatedLabel.textAlignment   = NSTextAlignmentCenter;
        //            [self addSubview:mLastUpdatedLabel];
        
        //mStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 10.0f, frame.size.width, 20.0f )];
        mStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        mStatusLabel.font             = [UIFont boldSystemFontOfSize:14.0f];
        mStatusLabel.textColor        = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mStatusLabel.textColor = (UIColor*)colorObj;
        }
        //mStatusLabel.shadowColor      = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        //mStatusLabel.shadowOffset     = CGSizeMake(0.0f, 1.0f);
        mStatusLabel.backgroundColor  = [UIColor clearColor];
        mStatusLabel.textAlignment    = NSTextAlignmentCenter;
        [self setStatus:EBounceViewStatusPullToReload];
        //            [self addSubview:mStatusLabel];
        
        UIImage* arrowImage = [UIImage imageNamed:@"img/blueArrow.png"];
        if (imgObj) {
            UIImage * tempImg = [UIImage imageWithContentsOfFile:(NSString*)imgObj];
            if (tempImg) {
                arrowImage = tempImg;
            }
            
        }
        
        if (self.isImgCenter) {
            //mArrowImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - arrowImage.size.width)*0.5, 20.0f, arrowImage.size.width, arrowImage.size.height)];
        } else {
            mArrowImage.frame = CGRectMake(25.0f, 20.0f, arrowImage.size.width, arrowImage.size.height);
        }
        
        mArrowImage.image = arrowImage;
        [mArrowImage layer].transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
        //            [self addSubview:mArrowImage];
        
        NSString * pjID =  [bounceParamsDict objectForKey:@"projectID"];
        if ([pjID isKindOfClass:[NSString class]] && pjID.length>0)
        {
            if ([pjID isEqualToString:@"donghang"])
            {
                UIImage* arrowImage = nil;
                if (imgInObj) {
                    arrowImage =[UIImage imageWithContentsOfFile:(NSString*)imgInObj];
                }
                if (self.isImgCenter) {
                    mActivityImageView = [[UIImageView alloc] initWithFrame:mArrowImage.frame];
                } else {
                    mActivityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 5.0f, arrowImage.size.width, arrowImage.size.height)];
                }
                
                mActivityImageView.image = arrowImage;
                mActivityImageView.hidden=YES;
                //                    [self addSubview:mActivityImageView];
                
            }
        }else
        {
            //mActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            if (self.isImgCenter) {
                mActivityView.frame = mArrowImage.frame;
            } else {
                mActivityView.frame = CGRectMake( 30.0f, 15.0f, 20.0f, 20.0f );
            }
            mActivityView.hidesWhenStopped  = YES;
            //                [self addSubview:mActivityView];
            
        }
        
    }
    
    CGSize sizeMstatu = [mStatusLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
    CGSize sizeMlast = [mLastUpdatedLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
    CGSize size = (sizeMstatu.width>sizeMlast.width)?sizeMstatu:sizeMlast;
    if (size.width<70)
    {
        size.width=70;
    }
    CGRect temRect = mStatusLabel.frame;
    float widthLabel = temRect.size.width;
    CGRect imageFrame = mArrowImage.frame;
    imageFrame.origin.x=widthLabel/2-size.width/2-imageFrame.size.width-10;
    if (self.isImgCenter) {
        CGRect tempRect = imageFrame;
        tempRect.origin.x = (self.frame.size.width - imageFrame.size.width)*0.5;
        mArrowImage.frame = tempRect;
    } else {
        [mArrowImage setFrame:imageFrame];
    }
    
    
    NSString * loading =[bounceParamsDict objectForKey:@"loadingText"];
    CGSize sizeLoad = [loading sizeWithFont:[UIFont systemFontOfSize:12.0f]];
    CGRect acimageFrame = mActivityImageView.frame;
    acimageFrame.origin.x=[UIScreen mainScreen].bounds.size.width/2-sizeLoad.width/2-imageFrame.size.width-35;
    if (self.isImgCenter) {
        mActivityImageView.frame = mArrowImage.frame;
    } else {
        [mActivityImageView setFrame:acimageFrame];
    }
    
    CGRect acviewFrame = mActivityView.frame;
    acviewFrame.origin.x= mArrowImage.frame.origin.x;
    if (self.isImgCenter) {
        mActivityView.frame = mArrowImage.frame;
    } else {
        [mActivityView setFrame:acviewFrame];
    }
    
    
}


- (id)initWithFrame:(CGRect)frame andType:(int)inType params:(NSMutableDictionary*)dict{
  if (self = [super initWithFrame:frame]) {
      self.isImgCenter = NO;
      if ([[dict objectForKey:@"levelText"] length] == 0 && [[dict objectForKey:@"loadingText"] length] == 0 && [[dict objectForKey:@"pullToReloadText"] length] == 0 && [[dict objectForKey:@"releaseToReloadText"] length] == 0 && [[dict objectForKey:@"textColor"] length] == 0) {
          if ([[dict allKeys] count] > 0) {
              self.isImgCenter = YES;
          }
      }
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	    if (bounceParamsDict) {
        [bounceParamsDict release];
    }
    id colorObj = nil;
    id imgObj = nil;
    id levelObj = nil;
    id imgInObj = nil;
    if (dict) {
        
        bounceParamsDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        id typeStr = [bounceParamsDict objectForKey:@"type"];
        
        if (typeStr && [typeStr intValue] == inType) {
            
            colorObj = [bounceParamsDict objectForKey:@"textColor"];
            imgObj = [bounceParamsDict objectForKey:@"imagePath"];
            levelObj = [bounceParamsDict objectForKey:@"levelText"];
            imgInObj = [bounceParamsDict objectForKey:@"loadingImagePath"];
            
        }
    }
    mType = inType;
	if (inType == EBounceViewTypeTop)
    {
        mLastUpdatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, frame.size.width, 20.0f)];
		mLastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		mLastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
        if (levelObj) {
            mLastUpdatedLabel.text = [NSString stringWithString:(NSString*)levelObj];
        }
        mLastUpdatedLabel.textColor = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mLastUpdatedLabel.textColor = (UIColor*)colorObj; 
        }
		//mLastUpdatedLabel.shadowColor     = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
		//mLastUpdatedLabel.shadowOffset    = CGSizeMake(0.0f, 1.0f);
		mLastUpdatedLabel.backgroundColor = [UIColor clearColor];
		mLastUpdatedLabel.textAlignment   = NSTextAlignmentCenter;
		[self addSubview:mLastUpdatedLabel];

		mStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, frame.size.width, 20.0f )];
		mStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		mStatusLabel.font             = [UIFont boldSystemFontOfSize:14.0f];
		mStatusLabel.textColor        = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mStatusLabel.textColor = (UIColor*)colorObj; 
        }
		//mStatusLabel.shadowColor      = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
		//mStatusLabel.shadowOffset     = CGSizeMake(0.0f, 1.0f);
		mStatusLabel.backgroundColor  = [UIColor clearColor];
		mStatusLabel.textAlignment    = NSTextAlignmentCenter;
		[self setStatus:EBounceViewStatusPullToReload];
		[self addSubview:mStatusLabel];

		UIImage* arrowImage = [UIImage imageNamed:@"img/blueArrow.png"];
        if (imgObj) {
            UIImage * tempImg = [UIImage imageWithContentsOfFile:(NSString*)imgObj];
            if (tempImg) {
                arrowImage = tempImg;
            }
            
        }
		mArrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(25.0f, frame.size.height - 52.0f, arrowImage.size.width, arrowImage.size.height)];
        if (self.isImgCenter) {
            CGRect tempRect = mArrowImage.frame;
            tempRect.origin.x = (frame.size.width - arrowImage.size.width)*0.5;
            mArrowImage.frame = tempRect;
        }
        
        
		mArrowImage.image = arrowImage;
		[mArrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
		[self addSubview:mArrowImage];

        NSString * pjID =  [bounceParamsDict objectForKey:@"projectID"];
        if ([pjID isKindOfClass:[NSString class]] && pjID.length>0)
        {
            if ([pjID isEqualToString:@"donghang"])
            {
                UIImage* arrowImage = nil;
                if (imgInObj) {
                    arrowImage =[UIImage imageWithContentsOfFile:(NSString*)imgInObj];
                }
                if (self.isImgCenter) {
                    mActivityImageView = [[UIImageView alloc] initWithFrame:mArrowImage.frame];
                } else {
                    mActivityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 60.0f, arrowImage.size.width, arrowImage.size.height)];
                }
                
                mActivityImageView.image = arrowImage;
                mActivityImageView.hidden=YES;
                [self addSubview:mActivityImageView];
                

//                CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
//                animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//                
//                //围绕Z轴旋转，垂直与屏幕
//                animation.toValue = [ NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 1.0, 0) ];
//                animation.duration = 1;
//                //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
//                animation.cumulative = YES;
//                animation.repeatCount = HUGE_VALF;//foever
//                 [mActivityImageView.layer addAnimation:animation forKey:nil];
            }
        }else
        {
            mActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            if (self.isImgCenter) {
                mActivityView.frame = mArrowImage.frame;
            } else {
                mActivityView.frame = CGRectMake( 30.0f, frame.size.height - 48.0f, 20.0f, 20.0f );
            }
            
            mActivityView.hidesWhenStopped  = YES;
            [self addSubview:mActivityView];
            
        }
        
	}
    else if (inType == EBounceViewTypeBottom)
    {
		mLastUpdatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 28.0f, frame.size.width, 20.0f)];
		mLastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		mLastUpdatedLabel.font            = [UIFont systemFontOfSize:12.0f];
        if (levelObj) {
            mLastUpdatedLabel.text =[NSString stringWithString:(NSString*)levelObj];
        }
		mLastUpdatedLabel.textColor       = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mLastUpdatedLabel.textColor = (UIColor*)colorObj; 
        }
		//mLastUpdatedLabel.shadowColor     = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
		//mLastUpdatedLabel.shadowOffset    = CGSizeMake(0.0f, 1.0f);
		mLastUpdatedLabel.backgroundColor = [UIColor clearColor];
		mLastUpdatedLabel.textAlignment   = NSTextAlignmentCenter;
		[self addSubview:mLastUpdatedLabel];
		
		mStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 10.0f, frame.size.width, 20.0f )];
		mStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		mStatusLabel.font             = [UIFont boldSystemFontOfSize:14.0f];
		mStatusLabel.textColor        = RGBCOLOR(109, 128, 153);
        if (colorObj) {
            mStatusLabel.textColor = (UIColor*)colorObj; 
        }
		//mStatusLabel.shadowColor      = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
		//mStatusLabel.shadowOffset     = CGSizeMake(0.0f, 1.0f);
		mStatusLabel.backgroundColor  = [UIColor clearColor];
		mStatusLabel.textAlignment    = NSTextAlignmentCenter;
		[self setStatus:EBounceViewStatusPullToReload];
		[self addSubview:mStatusLabel];
		
		UIImage* arrowImage = [UIImage imageNamed:@"img/blueArrow.png"];
        if (imgObj) {
            UIImage * tempImg = [UIImage imageWithContentsOfFile:(NSString*)imgObj];
            if (tempImg) {
                arrowImage = tempImg;
            }
            
        }
        if (self.isImgCenter) {
            mArrowImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - arrowImage.size.width)*0.5, 20.0f, arrowImage.size.width, arrowImage.size.height)];
        } else {
            mArrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(25.0f, 20.0f, arrowImage.size.width, arrowImage.size.height)];
        }
        
		mArrowImage.image = arrowImage;
		[mArrowImage layer].transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
		[self addSubview:mArrowImage];
		
        NSString * pjID =  [bounceParamsDict objectForKey:@"projectID"];
        if ([pjID isKindOfClass:[NSString class]] && pjID.length>0)
        {
            if ([pjID isEqualToString:@"donghang"])
            {
                UIImage* arrowImage = nil;
                if (imgInObj) {
                    arrowImage =[UIImage imageWithContentsOfFile:(NSString*)imgInObj];
                }
                if (self.isImgCenter) {
                    mActivityImageView = [[UIImageView alloc] initWithFrame:mArrowImage.frame];
                } else {
                    mActivityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 5.0f, arrowImage.size.width, arrowImage.size.height)];
                }
                
                mActivityImageView.image = arrowImage;
                mActivityImageView.hidden=YES;
                [self addSubview:mActivityImageView];
                
            }
        }else
        {
            mActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            if (self.isImgCenter) {
                mActivityView.frame = mArrowImage.frame;
            } else {
                mActivityView.frame = CGRectMake( 30.0f, 15.0f, 20.0f, 20.0f );
            }
            mActivityView.hidesWhenStopped  = YES;
            [self addSubview:mActivityView];
            
        }

	}
      
      CGSize sizeMstatu = [mStatusLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
      CGSize sizeMlast = [mLastUpdatedLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
      CGSize size = (sizeMstatu.width>sizeMlast.width)?sizeMstatu:sizeMlast;
      if (size.width<70)
      {
          size.width=70;
      }
      CGRect temRect = mStatusLabel.frame;
      float widthLabel = temRect.size.width;
      CGRect imageFrame = mArrowImage.frame;
      imageFrame.origin.x=widthLabel/2-size.width/2-imageFrame.size.width-10;
      if (self.isImgCenter) {
          CGRect tempRect = imageFrame;
          tempRect.origin.x = (frame.size.width - imageFrame.size.width)*0.5;
          mArrowImage.frame = tempRect;
      } else {
          [mArrowImage setFrame:imageFrame];
      }
      
      
      NSString * loading =[bounceParamsDict objectForKey:@"loadingText"];
      CGSize sizeLoad = [loading sizeWithFont:[UIFont systemFontOfSize:12.0f]];
      CGRect acimageFrame = mActivityImageView.frame;
      acimageFrame.origin.x=[UIScreen mainScreen].bounds.size.width/2-sizeLoad.width/2-imageFrame.size.width-35;
      if (self.isImgCenter) {
          mActivityImageView.frame = mArrowImage.frame;
      } else {
          [mActivityImageView setFrame:acimageFrame];
      }
      
      CGRect acviewFrame = mActivityView.frame;
      acviewFrame.origin.x= mArrowImage.frame.origin.x;
      if (self.isImgCenter) {
          mActivityView.frame = mArrowImage.frame;
      } else {
          [mActivityView setFrame:acviewFrame];
      }
      
  }
  return self;
}

- (void)dealloc {
    [bounceParamsDict release];
    bounceParamsDict =nil;
	if (mActivityView) {
		[mActivityView removeFromSuperview];
	}
	[mActivityView release];
	mActivityView = NULL;
	if (mStatusLabel) {
		[mStatusLabel removeFromSuperview];
	}
	[mStatusLabel release];
	mStatusLabel = NULL;
	if (mArrowImage) {
		[mArrowImage removeFromSuperview];
	}
	[mArrowImage release];
	mArrowImage = NULL;
	if (mLastUpdatedLabel) {
		[mLastUpdatedLabel removeFromSuperview];
	}
	[mLastUpdatedLabel release];
	mLastUpdatedLabel = NULL;
	[mLastUpdatedDate release];
	mLastUpdatedDate = NULL;
    self.projectID=nil;
    if (mActivityImageView) {
        [mActivityImageView release];
    }
	[super dealloc];
}


- (void)setUpdateDate:(NSDate*)newDate {
  if (newDate) {
    if (mLastUpdatedDate != newDate) {
      [mLastUpdatedDate release];
    }

    mLastUpdatedDate = [newDate retain];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    mLastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:mLastUpdatedDate]];
    [formatter release];

  } else {
    mLastUpdatedDate = nil;
    mLastUpdatedLabel.text = @"Last updated: never";
  }
}
-(void)setLevelText:(NSString*)inText{
    mLastUpdatedLabel.text = [NSString stringWithString:inText];
    CGSize sizeMstatu = [mStatusLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
    CGSize sizeMlast = [mLastUpdatedLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
    CGSize size = (sizeMstatu.width>sizeMlast.width)?sizeMstatu:sizeMlast;
    CGRect temRect = mStatusLabel.frame;
   float widthLabel = temRect.size.width;
    CGRect imageFrame = mArrowImage.frame;
    imageFrame.origin.x=widthLabel/2-size.width/2-imageFrame.size.width-10;
    if (self.isImgCenter) {
        CGRect tempRect = imageFrame;
        tempRect.origin.x = (self.frame.size.width - imageFrame.size.width)*0.5;
        mArrowImage.frame = tempRect;
    } else {
        [mArrowImage setFrame:imageFrame];
    }
//    CGRect acimageFrame = mActivityImageView.frame;
//    acimageFrame.origin.x=[UIScreen mainScreen].bounds.size.width/2-size.width/2-imageFrame.size.width-20;
//    [mActivityImageView setFrame:acimageFrame];
//    
    
    CGRect acviewFrame = mActivityView.frame;
    acviewFrame.origin.x= mArrowImage.frame.origin.x;
    if (self.isImgCenter) {
        mActivityView.frame = mArrowImage.frame;
    } else {
        [mActivityView setFrame:acviewFrame];
    }
    
}
- (void)setCurrentDate {
  [self setUpdateDate:[NSDate date]];
}

- (void)setStatus:(EBounceViewStatus)status {
    id pullReload = nil;
    id releaseReload = nil;
    id loading = nil;
    if (bounceParamsDict) {
        pullReload =[bounceParamsDict objectForKey:@"pullToReloadText"];
        releaseReload =[bounceParamsDict objectForKey:@"releaseToReloadText"];
        loading =[bounceParamsDict objectForKey:@"loadingText"];
    }
  switch (status) {
    case EBounceViewStatusReleaseToReload: {
      [self showActivity:NO animated:NO];
      [self setImageFlipped:YES];
      mStatusLabel.text = ACELocalized(@"释放刷新");
      if (releaseReload) {
         mStatusLabel.text =(NSString*)releaseReload;
      }
      break;
    }

    case EBounceViewStatusPullToReload: {
      [self showActivity:NO animated:NO];
      [self setImageFlipped:NO];
      mStatusLabel.text =ACELocalized(@"拖动刷新");
      if (pullReload) {
        mStatusLabel.text =(NSString*)pullReload;
      }
      break;
    }

    case EBounceViewStatusLoading: {
      [self showActivity:YES animated:YES];
      [self setImageFlipped:NO];
      mStatusLabel.text = ACELocalized(@"加载中");
      if (loading) {
            mStatusLabel.text =(NSString*)loading;
      }
      break;
    }

    default: {
      break;
    }
  }
    //下拉刷新时图标自适应提示文字大小
    {
        CGSize sizeMstatu = [mStatusLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
        CGSize sizeMlast = [mLastUpdatedLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]];
        CGSize size = (sizeMstatu.width>sizeMlast.width)?sizeMstatu:sizeMlast;
        if (size.width<70)
        {
            size.width=70;
        }
        CGRect temRect = mStatusLabel.frame;
        float widthLabel = temRect.size.width;
        CGRect imageFrame = mArrowImage.frame;
        imageFrame.origin.x=widthLabel/2-size.width/2-imageFrame.size.width-10;
        if (self.isImgCenter) {
            CGRect tempRect = imageFrame;
            tempRect.origin.x = (self.frame.size.width - imageFrame.size.width)*0.5;
            mArrowImage.frame = tempRect;
        } else {
            [mArrowImage setFrame:imageFrame];
        }
        
//        CGRect acimageFrame = mActivityImageView.frame;
//        acimageFrame.origin.x=[UIScreen mainScreen].bounds.size.width/2-size.width/2-imageFrame.size.width-30;
////        [mActivityImageView setFrame:acimageFrame];
//        
        
        CGRect acviewFrame = mActivityView.frame;
        acviewFrame.origin.x= mArrowImage.frame.origin.x;
        if (self.isImgCenter) {
            mActivityView.frame = mArrowImage.frame;
        } else {
            [mActivityView setFrame:acviewFrame];
        }
        
    }
}

@end
