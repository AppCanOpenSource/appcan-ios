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
            return ACEInterfaceOrientationLandscapeLeft;
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            return ACEInterfaceOrientationLandscapeRight;
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
            return ACEInterfaceOrientationLandscapeRight;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return ACEInterfaceOrientationLandscapeLeft;
            break;
        }
            
    }
}

UIInterfaceOrientationMask ace_interfaceOrientationMaskFromACEInterfaceOrientation(ACEInterfaceOrientation orientation){

    UIInterfaceOrientationMask mask = 0;
    if (orientation & ACEInterfaceOrientationProtrait) {
        mask |= UIInterfaceOrientationMaskPortrait;
    }
    if (orientation & ACEInterfaceOrientationLandscapeLeft) {
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    }
    if (orientation & ACEInterfaceOrientationProtraitUpsideDown) {
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    if (orientation & ACEInterfaceOrientationLandscapeRight) {
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    if (mask == 0) {
        mask = UIInterfaceOrientationMaskAll;
    }
    return mask;
}


