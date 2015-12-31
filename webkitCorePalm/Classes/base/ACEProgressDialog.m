/**
 *
 *	@file   	: ACEProgressDialog.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/12/30.
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
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

#import "ACEProgressDialog.h"
#import "MBProgressHUD.h"

@interface ACEProgressDialog()
@property (nonatomic,strong)MBProgressHUD *HUD;
@property (nonatomic,strong)UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic,assign)BOOL canCancel;
@end




@implementation ACEProgressDialog


+ (instancetype)sharedDialog{
    static ACEProgressDialog *dialog=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dialog=[[self alloc] init];
    });
    return dialog;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIWindow *window=[[UIApplication sharedApplication].delegate window];
        _HUD=[[MBProgressHUD alloc]initWithWindow:window];
        _HUD.dimBackground=YES;
        [window addSubview:_HUD];
        _tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [_HUD addGestureRecognizer:_tapGestureRecognizer];
        
        _canCancel=YES;
    }
    return self;
}

- (void)showWithTitle:(NSString *)title text:(NSString *)text canCancel:(BOOL)canCancel{
    self.HUD.labelText=title?:@"";
    self.HUD.detailsLabelText=text?:@"";
    self.canCancel=canCancel;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.HUD show:YES];
    });
}

- (void)hide{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD hide:YES];
        
    });
}

- (void)onTap:(UIGestureRecognizer *)gestureRecognizer{
    if(!self.canCancel || gestureRecognizer != self.tapGestureRecognizer){
        return;
    }
    CGPoint tapPoint=[gestureRecognizer locationInView:nil];
    CGRect rect=[self indicatorRect];
    if(!CGRectContainsPoint(rect, tapPoint)){
        [self hide];
    }
}

- (CGRect)indicatorRect{
    CGFloat w = self.HUD.size.width;
    CGFloat h = self.HUD.size.height;
    CGFloat x = self.HUD.center.x - w/2;
    CGFloat y = self.HUD.center.y - h/2;
    CGRect HUDRect = CGRectMake(x, y, w, h);
    return HUDRect;
}
@end
