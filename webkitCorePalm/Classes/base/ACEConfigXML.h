/**
 *
 *	@file   	: ACEConfigXML.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/15
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
#import <Ono/Ono.h>

@interface ACEConfigXML: NSObject
//原始的config.xml文档,打包时生成,不可更改
+ (ONOXMLElement *)ACEOriginConfigXML;

//widget中的config.xml文档,可以在自动更新时被修改
//如果应用不支持自动更新,将会返回`ACEOriginConfigXML`
+ (ONOXMLElement *)ACEWidgetConfigXML;




@end
