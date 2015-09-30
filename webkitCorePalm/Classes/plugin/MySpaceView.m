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

#import "MySpaceView.h"
#import <QuartzCore/CALayer.h>
#import "AppItemView.h"
#import "ACUtility.h"
#import "BUtility.h"
#import "UIButton+WebCache.h"
#define TOPVIEW_H 198
#define BOTTOMVIEW_H 99
#define FIRST_VIEW_H 260
#define SEC_VIEW_H 149
#define NAV_H 46
#define LABEL_H 20
#define SIDE_H  15
#define SCREEN_W  [BUtility getScreenWidth]
#define SCREEN_H  [BUtility getScreenHeight]
#define SIDE_L 10
#define ITEM_H  84
#define BUTTON_H 58
@implementation MySpaceView

@synthesize delegate = _delegate;
@synthesize actionShowed,moreDisplay;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
 		[self setUserInteractionEnabled:YES];
		UIImage *barImage = [UIImage imageNamed:@"img/my_space_title.png"];
		UINavigationBar *customNavigationBar = [ACUtility createNavigationBarWithBackgroundImage:barImage title:ACELocalized(@"应用中心")];;
		//back 
		UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 52.0, 32.0)];
		[backButton setImage:[UIImage imageNamed:@"img/my_space_back.png"] forState:UIControlStateNormal];
		[backButton setImage:[UIImage imageNamed:@"img/my_space_back_hov.png"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(backButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
		customNavigationBar.topItem.leftBarButtonItem = backBarButton;
		[backButton release];
		[backBarButton release];
		//setting
		UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(270, 0, 45, 32)];
		[settingBtn setImage:[UIImage imageNamed:@"img/my_space_setting.png"] forState:UIControlStateNormal];
		[settingBtn setImage:[UIImage imageNamed:@"img/my_space_setting_hov.png"] forState:UIControlStateHighlighted];
		[settingBtn addTarget:self action:@selector(settingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
		customNavigationBar.topItem.rightBarButtonItem = settingBarButton;
		[settingBtn release];
		[settingBarButton release];
		[self addSubview:customNavigationBar];
		//mainview
		mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAV_H-1,SCREEN_W, SCREEN_H-NAV_H+1)];
		[mainView setBackgroundColor:[UIColor colorWithRed:241/255.0 green:245/255.0 blue:248/255.0 alpha:1.0]];
		[mainView setContentSize:CGSizeMake(320, SCREEN_H-NAV_H+1)];
		[mainView setDelegate:self];
		if (_refreshHeaderView == nil) {
			
			PullDownRefreshHeaderView *pView = [[PullDownRefreshHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
			pView.delegate = self;
			[mainView addSubview:pView];
			_refreshHeaderView = pView;
			[pView release];
			
		}
		
		//  update the last update date
		[_refreshHeaderView refreshLastUpdatedDate];
		//top view
		topView = [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_W, FIRST_VIEW_H)];
		[topView setUserInteractionEnabled:YES];
		UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, SCREEN_W, LABEL_H)];
		[firstLabel setBackgroundColor:[UIColor clearColor]];
		firstLabel.text = ACELocalized(@"推荐应用");
		[topView addSubview:firstLabel];
		[firstLabel release];
		//popview
		popAppView = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_L,LABEL_H+SIDE_H+15, SCREEN_W-2*SIDE_L,TOPVIEW_H)];
		[popAppView setUserInteractionEnabled:YES];
		[popAppView setImage:[UIImage imageNamed:@"img/my_space_bg.png"]];
		[topView addSubview:popAppView];
		
		//bottom view
		bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,FIRST_VIEW_H,SCREEN_W,SEC_VIEW_H)];
		[bottomView setUserInteractionEnabled:YES];
		UILabel *secLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0, SCREEN_W, LABEL_H)];
		[secLabel setBackgroundColor:[UIColor clearColor]];
		[secLabel setText:ACELocalized(@"我的应用")];
		[bottomView addSubview:secLabel];
		[secLabel release];
		//MYAPP VIEW
		myAppView = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_L,10+LABEL_H, SCREEN_W-2*SIDE_L, BOTTOMVIEW_H)];
		[myAppView setImage:[UIImage imageNamed:@"img/my_space_bg.png"]];
		[myAppView setUserInteractionEnabled:YES];
		[bottomView addSubview:myAppView];
		
		[mainView addSubview:bottomView];
		[mainView addSubview:topView];
		[self addSubview:mainView];
    }
    return self;
}
- (void)reloadDataSource{

	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	if (_delegate&&[_delegate respondsToSelector:@selector(notifyAppCenterReloadData)]) {
		[_delegate notifyAppCenterReloadData];
	}
	_reloading = YES;
	
}

- (void)doneLoadingData{
	
	//  model should call this when its done loading
	_reloading = NO;
 	[_refreshHeaderView refreshScrollViewDataSourceDidFinishedLoading:mainView];
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView refreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView refreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark PullDownRefreshHeaderDelegate Methods

- (void)refreshHeaderDidTriggerRefresh:(PullDownRefreshHeaderView*)view{
	
	[self reloadDataSource];
	[self performSelector:@selector(doneLoadingData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)refreshHeaderDataSourceIsLoading:(PullDownRefreshHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)refreshHeaderDataSourceLastUpdated:(PullDownRefreshHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

-(void)widgetStartDownload:(NSMutableDictionary *)newItemDict{
	//重绘myappview
	[self drawMyAppView:[newItemDict allValues]];
}
-(void)widgetFinishDld:(AppItemView *)dItem{
	dItem.downloadTag = 3;
	[dItem.btn setEnabled:YES];
	[dItem updateImage];
	[dItem.progressView removeFromSuperview];
	 
}
-(void)drawTopView:(NSArray *)itemsArray{
	for (AppItemView *itemView in [popAppView subviews]) {
		[itemView removeFromSuperview];
	}
	NSMutableArray *recAppSet = [NSMutableArray arrayWithArray:itemsArray];
	int lineNum = 2;//行数
	int count = [itemsArray count];  //总数
 	int linecount = 4;    //每行的个数
	int hasCount = 8; //还有多少items没有draw
 
	//如果推荐少于8个，补足默认图片
	if (count<7) {
		for (int i = 0; i<7-count; i++) {
			AppItemView *addItem = [[AppItemView alloc] init];
			NSString *pathStr= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img/my_space_download.png"];
			[addItem setAppIconUrl:[NSURL fileURLWithPath:pathStr]];
			[recAppSet addObject:addItem];
			[addItem release];
		}
	}
	//添加更多item
 
		AppItemView *moreItem = [[AppItemView alloc] init];
		[moreItem setAppId:@"9999997"];
		[moreItem setAppName:ACELocalized(@"更多")];
		NSString *pathStr= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img/my_space_add.png"];
		[moreItem setAppIconUrl:[NSURL fileURLWithPath:pathStr]];
		[recAppSet addObject:moreItem];
		[moreItem release];
 
	//根据popview的行数自动设置布局
	//popAppView.frame = CGRectMake(SIDE_L,LABEL_H+SIDE_H+20, SCREEN_W-2*SIDE_L, lineNum*(ITEM_H+SIDE_H));
 	//	topView.frame = CGRectMake(0, 0, SCREEN_W,popAppView.frame.size.height+2*SIDE_H+LABEL_H*2);
	//现改为只画两行，fuck
	//popAppView.frame = CGRectMake(SIDE_L, LABEL_H+20+SIDE_L, SCREEN_W-2*SIDE_L, 2*(ITEM_H+SIDE_H));
	//topView.frame = CGRectMake(0, 0, SCREEN_W,popAppView.frame.size.height+3*SIDE_H+LABEL_H);
	//NSLog(@"topview h = %f",topView.frame.size.height);
 	//bottomView.frame = CGRectMake(0,topView.frame.size.height,SCREEN_W,SEC_VIEW_H);
 
    for (int i = 0; i<lineNum; i++) {
		for (int j=0; j<linecount; j++) {
			AppItemView *aItem = [recAppSet objectAtIndex:4*i+j];
			CGRect cframe = CGRectMake((j+1)*8+65*j, ITEM_H*i+(i+1)*(SIDE_L), 65, ITEM_H+SIDE_L);
			NSURL *img = aItem.appIconUrl;
			NSString *appName = aItem.appName;
			NSString *appId = aItem.appId;

			 AppItemView *bItem = [[AppItemView alloc] initWithFrame:cframe image:img title:appName appTag:appId];
			bItem.isMyAppItem = NO;
			if ([bItem.appId isEqualToString:@"9999997"]) {
				if (moreDisplay == YES) {
					bItem.hidden = NO;
				}else {
					bItem.hidden = YES;
				}				
			}
			[bItem setDelegate:self];
			[popAppView addSubview:bItem];
			[popAppView setNeedsLayout];
			[bItem release];
			hasCount--;
			if (hasCount==0) {
				break;
			}
		}
		if (count%4!=0&&hasCount<4) {
			linecount = count%4;
		}
		
	}
}

-(void)drawMyAppView:(NSArray *)itemsArray{	
	NSMutableArray *muArray = [NSMutableArray arrayWithArray:itemsArray];
	for (AppItemView  *itemView in [myAppView subviews]) {
			[itemView removeFromSuperview];
	}
	int lineNum = 0;//行数
	int count = [muArray count];  //总数
	if (count == 0) {
		return;
	}
 	int linecount = 4;    //每行的个数
	int hasCount = count; //还有多少items没有draw
	if (count%4==0) {
		if (count==0) {
			lineNum = 1;
		}else {
			lineNum = count/4;
		}
	}else {
		lineNum = count/4+1;
	}
	//根据myAppView的行数设置布局
	CGRect rect = myAppView.frame;
	NSLog(@"myappview size w = %f h= %f,pos x= %f,y = %f",rect.size.width,rect.size.height,rect.origin.x,rect.origin.y);
	myAppView.frame = CGRectMake(SIDE_L,10+LABEL_H, SCREEN_W-2*SIDE_L, (lineNum)*(ITEM_H+SIDE_H));
  	bottomView.frame = CGRectMake(0,FIRST_VIEW_H,SCREEN_W,myAppView.frame.size.height+2*LABEL_H+2*SIDE_H);
	mainView.contentSize = CGSizeMake(SCREEN_W,FIRST_VIEW_H+bottomView.frame.size.height);
   
 
    for (int i = 0; i<lineNum; i++) {
		for (int j=0; j<linecount; j++) {
			AppItemView *aItem = [muArray objectAtIndex:4*i+j];
			CGRect cframe = CGRectMake((j+1)*8+65*j, ITEM_H*i+(i+1)*(SIDE_L), 65, ITEM_H+SIDE_L);
			NSURL *img = aItem.appIconUrl;
			NSString *appName = aItem.appName;
			NSString *appId = [NSString stringWithString:aItem.appId];
			NSLog(@"MYSPACE APPID = %@,aitemDownload= %d",appId,aItem.downloadTag);
			aItem.isMyAppItem = YES;
			 
			[aItem initWithFrame:cframe image:img title:appName appTag:appId];
			[aItem setDelegate:self];
			if (aItem.downloadTag==1) {
				//正在下载
				[aItem.progressView setHidden:NO];
			}			
			[myAppView addSubview:aItem];
			hasCount--;
			if (hasCount==0) {
				break;
			}
		}
		if (count%4!=0&&hasCount<4) {
			linecount = count%4;
		}
		
	}
}
-(void)backButtonCliked:(id)sender{
	if([_delegate respondsToSelector:@selector(appCenterCloseBtnClick)]){
		[_delegate appCenterCloseBtnClick];
	}
}
-(void)settingButtonClicked:(id)sender{
	if ([_delegate respondsToSelector:@selector(appCenterSetting)]) {
		[_delegate appCenterSetting];
	}
}
-(void)iconItemClick:(NSString *)appId{
	if ([_delegate respondsToSelector:@selector(appItemClick:)]) {
		[_delegate appItemClick:appId];
	}
}
-(void)sendAppIdForLongPress:(NSString *)appId{
	NSLog(@"long press,appid = %@",appId);
 	if (actionShowed==NO) {
	        actionShowed = YES;
		UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:ACELocalized(@"删除该应用") delegate:self cancelButtonTitle:ACELocalized(@"取消") destructiveButtonTitle:ACELocalized(@"确定") otherButtonTitles:nil];
		[act setTag:[appId intValue]];
		[act showInView:self.superview];
		[act release];
	}	
}
 
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
		NSString *appid = [NSString stringWithFormat:@"%d",actionSheet.tag];
		if ([_delegate respondsToSelector:@selector(appPressLongForDelete:)]) {
			[_delegate appPressLongForDelete:appid];
		}
	}
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	actionShowed = NO;
}
-(void)showMoreAppBtn:(BOOL)showTag{
	UIView *moreView = [popAppView viewWithTag:9999997];
	if (moreView) {
		if (showTag==YES) {
			[moreView setHidden:NO];
		}else {
			[moreView setHidden:YES];
		}

	}
}
- (void)dealloc {
	[mainView release];
	[popAppView release];
	[myAppView release];
	[bottomView release];
	[topView release];
	_refreshHeaderView=nil;
    [super dealloc];
}


@end
