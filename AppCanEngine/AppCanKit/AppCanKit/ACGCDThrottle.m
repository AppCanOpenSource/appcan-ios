/**
 *
 *	@file   	: ACGCDThrottle.m  in AppCanKit
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


#import "ACGCDThrottle.h"


void ac_dispatch_throttle(NSTimeInterval threshold, dispatch_queue_t queue, dispatch_block_t block){
    static NSMutableDictionary<NSString *,dispatch_source_t> *_sources = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sources = [NSMutableDictionary dictionary];
    });
    
    NSString *key = [NSThread callStackSymbols][1];
    dispatch_source_t source = _sources[key];
    if (source) {
        dispatch_source_cancel(source);
    }
    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, threshold * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(source, ^{
        block();
        dispatch_source_cancel(source);
        [_sources removeObjectForKey:key];
    });
    dispatch_resume(source);
    _sources[key] = source;
    
}



