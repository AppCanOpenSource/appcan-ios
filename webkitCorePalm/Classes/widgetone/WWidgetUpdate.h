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

@interface WWidgetUpdate : NSObject<UIAlertViewDelegate>{
    NSString *saveWgtPath;
    NSString *uniqueId;
    long long fileTotalLength;
    long long appendFileSize;
    UIProgressView *_downProgress;
    
    
}
@property(nonatomic,copy)NSString *downLoadURL;
//提示更新
-(void)promptUpdate;
-(void)forceUpdateWgt;
-(BOOL)unZipUpdateWgt:(NSString*)inWgtName;
-(void)removeAllUD:(NSString*)idStr;
@end
