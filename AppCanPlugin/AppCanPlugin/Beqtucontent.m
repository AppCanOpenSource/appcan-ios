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

#import "Beqtucontent.h"

@implementation Beqtucontent

static NSString *html5appcandemo = @"26cf1a0e-6d52-41aa-bb54-f4efe8a35d33";



+ (NSString *)getContentPath {
    
    if (!html5appcandemo) {
        
        return @"";
        
    }
    
    return html5appcandemo;
    
}



@end
