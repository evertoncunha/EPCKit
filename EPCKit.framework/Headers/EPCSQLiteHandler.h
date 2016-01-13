//
//  EPCSQLiteHandler.h
//
//  Created by Everton on 05/06/14.
//

#import <Foundation/Foundation.h>

@interface EPCSQLiteHandler : NSObject

- (NSArray*)fetchDataWithQuery:(NSString*)querySQL limit:(int)limit openAndClose:(BOOL)openAndClose;

- (NSArray*)fetchDataWithQuery:(NSString*)querySQL openAndClose:(BOOL)openAndClose;

- (id)executeSQL:(NSString*)sql openAndClose:(BOOL)openAndClose;

- (BOOL)open;

- (BOOL)close;

+ (NSArray*)objectsOfClass:(Class)aClass fromFetchResut:(NSArray*)fetchResut;

@property (nonatomic, strong) NSString *databasePath;
@end
