//
//  EPCSQLiteHandler.m
//
//  Created by Everton on 05/06/14.
//

#import "EPCSQLiteHandler.h"
#import <sqlite3.h>
#import <objc/runtime.h>
#import "EPCDefines.h"

@interface EPCSQLiteHandler() {
	sqlite3 *_database;
	BOOL _isOpen;
}

@end

@implementation EPCSQLiteHandler

#pragma mark - SQLITE MAIN

- (BOOL)databaseFileExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self databasePath]];
}

- (NSArray*)fetchDataWithQuery:(NSString*)querySQL openAndClose:(BOOL)openAndClose {
	return [self fetchDataWithQuery:querySQL limit:0 openAndClose:openAndClose];
}

- (BOOL)open {
	if (!_isOpen) {
		const char *dbPath = [[self databasePath] UTF8String];
		if(sqlite3_open(dbPath, &_database) == SQLITE_OK) {
			_isOpen = YES;
			return YES;
		}
	}
	return NO;
}

- (BOOL)close {
	if (_isOpen) {
		if(sqlite3_close(_database) == SQLITE_OK) {
			_isOpen = NO;
			_database = nil;
			return YES;
		}
	}
	return NO;
}

- (id)executeSQL:(NSString*)sql openAndClose:(BOOL)openAndClose {
	
	DLog(@"%@", sql);
	
	id result = nil;
	
	if (openAndClose) {
		[self open];
	}
	
	const char *insertStmt = [sql UTF8String];
	
	char *errmsg=nil;
	
	if(sqlite3_exec(_database, insertStmt, NULL, NULL, &errmsg)==SQLITE_OK)
	{
		DLog(@"Done");
		
		if ([[sql lowercaseString] hasPrefix:@"insert"]) {
			sqlite3_int64 row = sqlite3_last_insert_rowid(_database);
			result = [NSNumber numberWithLongLong:row];
		}
		else {
			return @YES;
		}
	}
	else {
		DLog(@"Error NO SQL");
		
		result = [NSError errorWithDomain:@"erro sql" code:0 userInfo:nil];
	}
	
	return result;
}

- (NSArray*)fetchDataWithQuery:(NSString*)querySQL limit:(int)limit openAndClose:(BOOL)openAndClose{
	
	DLog(@"%@", querySQL);
	
	[self open];
	
	sqlite3_stmt *statement;
	
	const char *query_stmt = [querySQL UTF8String];
	
	sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL);
	
	int columns = sqlite3_column_count(statement);
	
	int step = sqlite3_step(statement);
	
	NSMutableArray *result = [NSMutableArray array];
	
	if (step == SQLITE_OK) {
		DLog(@"SQL OK");
	}
	else if (step == SQLITE_ERROR) {
		DLog(@"ERRO NO SQL: %@ |||| -> oper: %d", querySQL, step);
		result = [NSError errorWithDomain:@"SQLITE_ERROR" code:0 userInfo:nil];
	}
	while (step == SQLITE_ROW)
	{
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		
		for (int i = 0; i < columns; i++) {
			
			NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
			id columnValue = nil;
			
			int type = sqlite3_column_type(statement, i);
			
			if (type != SQLITE_NULL) {
				
				if (type == SQLITE_INTEGER) {
					sqlite3_int64 val = sqlite3_column_int64(statement, i);
					columnValue = [NSNumber numberWithLongLong:val];
				}
				else if (type == SQLITE_FLOAT) {
					columnValue = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
				}
				else if (type == SQLITE3_TEXT) {
					columnValue = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, i)];
				}
				else if (type == SQLITE_BLOB) {
					const void *ptr = sqlite3_column_blob(statement, i);
					int size = sqlite3_column_bytes(statement, i);
					columnValue = [[NSData alloc] initWithBytes:ptr length:size];
				}
				
				if (columnValue) {
					[dic setObject:columnValue forKey:[columnName lowercaseString]];
				}
				
			}
		}
		
		[result addObject:dic];
		
		if (limit > 0 && [result count] == limit) {
			break;
		}
		
		step = sqlite3_step(statement);
	}
	
	sqlite3_finalize(statement);
	
	return result;
}

#pragma mark - CONVERSION

+ (NSArray*)objectsOfClass:(Class)aClass fromFetchResut:(NSArray*)fetchResut {
	
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSDictionary *dict in fetchResut) {
		
		id obj = [[aClass alloc] init];
		[result addObject:obj];
		
		unsigned int outCount, i;
		objc_property_t *properties = class_copyPropertyList(aClass, &outCount);
		for(i = 0; i < outCount; i++) {
			objc_property_t prop = properties[i];
			const char *propNameChar = property_getName(prop);
			if(propNameChar) {
				NSString *propName = [NSString stringWithCString:propNameChar encoding:[NSString defaultCStringEncoding]];
				id value = [dict objectForKey:[propName lowercaseString]];
				if (value) {
					[obj setValue:value forKey:propName];
				}
			}
		}
		free(properties);
		
	}
	return result;
}


@end
