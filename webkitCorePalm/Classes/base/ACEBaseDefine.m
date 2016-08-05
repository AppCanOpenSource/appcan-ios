/**
 *
 *	@file   	: ACEBaseDefine.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 16/8/2
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
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


#import "ACEBaseDefine.h"


ACEInterfaceOrientation ace_interfaceOrientationFromUIDeviceOrientation(UIDeviceOrientation orientation){
    switch (orientation) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:{
            return ACEInterfaceOrientationUnknown;
            break;
        }
        case UIDeviceOrientationPortrait: {
            return ACEInterfaceOrientationProtrait;
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            return ACEInterfaceOrientationProtraitUpsideDown;
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            return ACEInterfaceOrientationLandscapeRight;
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            return ACEInterfaceOrientationLandscapeLeft;
            break;
        }

    }
}

ACEInterfaceOrientation ace_interfaceOrientationFromUIInterfaceOrientation(UIInterfaceOrientation orientation){
    switch (orientation) {
        case UIInterfaceOrientationUnknown: {
            return ACEInterfaceOrientationUnknown;
            break;
        }
        case UIInterfaceOrientationPortrait: {
            return ACEInterfaceOrientationProtrait;
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return ACEInterfaceOrientationProtraitUpsideDown;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return ACEInterfaceOrientationLandscapeLeft;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return ACEInterfaceOrientationLandscapeRight;
            break;
        }
            
    }
}