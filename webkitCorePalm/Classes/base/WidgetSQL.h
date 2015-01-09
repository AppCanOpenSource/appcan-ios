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

#import "sqlite3.h"
@interface WidgetSQL : NSObject {
	sqlite3 *dbObject;
}
- (void)Open_database:(NSString*)databaseName;
- (void)close_database;
- (BOOL)operateSQL:(const char*)inSql;
- (void)createTable:(const char*)inSql;
- (NSString*)select:(NSString*)sqlStr;
//插入表中数据
-(void)insertSql:(const char*)inSql;
//更新数据
-(void)updateSql:(const char*)inSql;
- (BOOL)deleteSql:(const char*)inSql;
- (void)dropTable:(NSString *)tableName;

//查找widget
-(NSMutableArray*)selectWgt:(NSString*)sqlStr;
@end
