/**
 *
 *	@file   	: ACGCDThrottle.h  in AppCanKit
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/22
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


#import <Foundation/Foundation.h>
#import <AppCanKit/ACMetaMacros.h>




APPCAN_EXPORT void ac_dispatch_throttle(NSTimeInterval threshold, dispatch_queue_t queue, dispatch_block_t block);
