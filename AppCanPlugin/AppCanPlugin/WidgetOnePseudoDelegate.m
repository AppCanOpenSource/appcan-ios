/*
 *  Copyright (C) 2017 The AppCan Open Source Project.
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

#import "WidgetOnePseudoDelegate.h"
@implementation WidgetOnePseudoDelegate

- (id) init
{
	if (self = [super init]) {
		self.userStartReport = NO;
		self.useOpenControl = NO;
		self.useEmmControl = NO;
		self.usePushControl = NO;
		self.useUpdateControl = NO;
		self.useOnlineArgsControl = YES;
		self.useDataStatisticsControl = NO;
        self.useAuthorsizeIDControl = NO;
        self.useCloseAppWithJaibroken = NO;
        self.useRC4EncryptWithLocalstorage = YES;
        self.useUpdateWgtHtmlControl = NO;
        self.useStartReportURL = @"http://192.168.1.140:8080/dc/";
        self.useAnalysisDataURL = @"http://192.168.1.140:8080/dc/";
        self.useBindUserPushURL = @"http://192.168.1.140:8080/push/";
        self.useAppCanMAMURL = @"http://192.168.1.140:8080/mam/";
        self.useAppCanMCMURL = @"http://192.168.1.183:8443/mcmIn/";
        self.useAppCanMDMURL = @"http://192.168.1.183:8443/mdmIn/";
        self.useAppCanMDMURLControl = NO;
        self.useCertificatePassWord = @"123456";
        self.useCertificateControl = NO;
        self.useIsHiddenStatusBarControl = NO;
        self.useAppCanUpdateURL = @"";
        self.signVerifyControl = NO;
        
        self.useAppCanEMMTenantID = @"";
        self.useAppCanAppStoreHost = @"";
        self.useAppCanMBaaSHost = @"";
        self.useAppCanIMXMPPHost = @"";
        self.useAppCanIMHTTPHost = @"";
        self.useAppCanTaskSubmitSSOHost = @"";
        self.useAppCanTaskSubmitHost = @"";
        self.validatesSecureCertificate = NO;
        self.useValidatesSecureCertificateControl = NO;
	}
	return self;
}


@end
