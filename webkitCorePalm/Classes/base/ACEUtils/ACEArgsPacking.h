/**
 *
 *	@file   	: ACEArgsPacking.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 16/5/9.
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
#import "ACEMetamacros.h"






#define _ACE_ArgsPack(...) (@[metamacro_foreach(_ACE_ObjectOrNil,,__VA_ARGS__ )])
#define _ACE_ObjectOrNil(idx,obj) [ACEArgsPackingHelper objectOrNil:obj],



#define _ACE_ArgsUnpack(...)\
    metamacro_foreach(_ACE_ArgsUnpack_Declare,, __VA_ARGS__) \
    \
    int _ACE_ArgsUnpackState = 0;\
    _ACE_ArgsUnpack_After:\
        ;\
        metamacro_foreach(_ACE_ArgsUnpack_Assign,, __VA_ARGS__) \
        if (_ACE_ArgsUnpackState != 0) _ACE_ArgsUnpackState = 2; \
            while (_ACE_ArgsUnpackState != 2) \
                if (_ACE_ArgsUnpackState == 1) { \
                    goto _ACE_ArgsUnpack_After; \
                } else \
                for (; _ACE_ArgsUnpackState != 1; _ACE_ArgsUnpackState = 1) \
                    [ACEArgsPackingHelper trampoline][ @[ metamacro_foreach(_ACE_ArgsUnpack_Value,, __VA_ARGS__) ] ]




#define _ACE_ArgsUnpackState \
    metamacro_concat(_ACE_ArgsUnpackState, __LINE__)

#define _ACE_ArgsUnpack_After \
    metamacro_concat(_ACE_ArgsUnpack_After, __LINE__)

#define _ACE_ArgsUnpack_Declare_Name(INDEX) \
    metamacro_concat(metamacro_concat(_ACE_ArgsUnpack, __LINE__), metamacro_concat(_var, INDEX))

#define _ACE_ArgsUnpack_Declare(INDEX, ARG) \
    __strong id _ACE_ArgsUnpack_Declare_Name(INDEX);

#define _ACE_ArgsUnpack_Assign(INDEX, ARG) \
    __strong ARG = [ACEArgsPackingHelper unpackedObjectFromObject:_ACE_ArgsUnpack_Declare_Name(INDEX) definitionString:@metamacro_stringify(ARG)];

#define _ACE_ArgsUnpack_Value(INDEX, ARG) \
    [NSValue valueWithPointer:&_ACE_ArgsUnpack_Declare_Name(INDEX)],





NS_ASSUME_NONNULL_BEGIN

@interface ACEArgsPackingHelper: NSObject
+ (instancetype)trampoline;
+ (id)objectOrNil:(nullable id)obj;
+ (nullable id)unpackedObjectFromObject:(nullable id)obj definitionString:(NSString *)defStr;
- (void)setObject:(NSArray *)args forKeyedSubscript:(NSArray<NSValue *> *)variables;
@end
NS_ASSUME_NONNULL_END

