//
//  EPCCoreDataDAO.h
//
//  Created by Everton Cunha on 18/10/12.
//

/*
 You should override:
- (NSString*)databaseFileName { // or - (NSString*)databaseFilePath
	return @"mydb.sqlite";
}
 
- (NSString*)databaseModelName {
	return @"mydbmodel";
}
 
- (void)handleModelIsIncompatibleWithStore { 
}
 
- (NSDictionary*)persistentStoreOptions { 
}
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface EPCCoreDataDAO : NSObject

/*
 Checks if database exists.
 */
- (BOOL)databaseExists;

/*
 Override this if necessary. The db file path.
 */
- (NSString*)databaseFilePath;

/*
 Override this. The db file name, like 'mydb.sqlite'.
 */
- (NSString*)databaseFileName;

/*
 Override this. The db model name, like 'mydbmodel', without extension.
 */
- (NSString*)databaseModelName;

/*
 Delete the database file.
 */
- (BOOL)deleteDatabaseFile;

/*
 Delete an NSManagedObject.
 */
- (void)deleteObject:(NSManagedObject*)object;

/*
 Fetching.
 */
- (NSArray*)fetchWithEntity:(NSString*)entity orderBy:(NSString*)order predicate:(NSPredicate*)predicate;

/*
 Fetching.
 */
- (NSArray*)fetchWithEntity:(NSString*)entity orderBy:(NSString*)order predicateString:(NSString*)predicateString;

/*
 Tells if DB has changes.
 */
- (BOOL)hasChanges;

/*
 Inserting new object for entity name.
 */
- (id)insertNewObjectForEntityForName:(NSString*)name;

/*
 Inserting new object for entity class.
 */
- (id)insertNewObjectForEntityForClass:(Class)aClass;

/*
 The context.
 */
- (NSManagedObjectContext *)managedObjectContext;

/*
 The store.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/*
 Commits.
 */
- (BOOL)save:(NSError**)error;

/*
 Rollback to the last commit.
 */
- (void)rollback;
@end
