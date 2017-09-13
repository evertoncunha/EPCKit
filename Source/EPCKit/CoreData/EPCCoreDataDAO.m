//
//  EPCCoreDataDAO.m
//
//  Created by Everton Cunha on 18/10/12.
//

#import "EPCCoreDataDAO.h"
#import "EPCCategories.h"
#import <CoreData/CoreData.h>
#import "EPCCoreDataCategories.h"
#import "EPCDefines.h"

#define DB_FOLDER @"Databases"

@interface EPCCoreDataDAO() {
	NSManagedObjectContext *__managedObjectContext;
	NSPersistentStoreCoordinator *__persistentStoreCoordinator;
	NSManagedObjectModel *__managedObjectModel;
}
@end

@implementation EPCCoreDataDAO

- (BOOL)databaseExists {
	NSString *path = [self databaseFilePath];
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	return exists;
}

- (BOOL)deleteDatabaseFile {
	NSString *path = [self databaseFilePath];
	if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	return NO;
}

- (NSManagedObjectContext *)managedObjectContext
{
	assert([[NSThread currentThread] isMainThread]);
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
	NSPersistentStoreCoordinator *persistentStore = [self persistentStoreCoordinator];
	if (!persistentStore) // error
		return nil;
	
    NSPersistentStoreCoordinator *coordinator = persistentStore;
	
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	assert([[NSThread currentThread] isMainThread]);
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self databaseModelName] withExtension:@"momd"];
	
	if (!modelURL) {
		modelURL = [[NSBundle mainBundle] URLForResource:[self databaseModelName] withExtension:@"mom"];
	}
	
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
	NSString *dir = [[UIApplication documentsDirectoryPath] stringByAppendingPathComponent:DB_FOLDER];
	if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
		NSError *error = nil;
		if(![[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error]) {
			DLog(@"%s %@", __PRETTY_FUNCTION__, error);
		}
	}
	
	
    NSURL *storeURL = [NSURL fileURLWithPath:[self databaseFilePath]];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[self persistentStoreOptions] error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
#ifdef DEBUG
        NSLog(@"%s Unresolved error %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
#endif
		[self handleModelIsIncompatibleWithStore];
        return nil;
    }
    
    return __persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectoryURL
{
	return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] copy];
}

- (NSDictionary*)persistentStoreOptions {
	return nil;
}

#pragma - Commiting

- (BOOL)save:(NSError **)error {
	BOOL saved = NO;
	@try {
		if (!error) {
			NSError *errrror = nil;
			saved = [[self managedObjectContext] save:&errrror];
			if (errrror){
				DLog(@"%s %@", __PRETTY_FUNCTION__, errrror);
			}
		}
		saved =  [[self managedObjectContext] save:error];
	}
	@catch (NSException *exception) {
		DLog(@"%@", exception);
	}
	return saved;
}

- (void)rollback {
	[[self managedObjectContext] rollback];
}

#pragma mark - Inserting

- (id)insertNewObjectForEntityForName:(NSString*)name {
	return [NSEntityDescription insertNewObjectForEntityForName:name
								  inManagedObjectContext:[self managedObjectContext]];
}

- (id)insertNewObjectForEntityForClass:(Class)aClass {
	return [self insertNewObjectForEntityForName:NSStringFromClass(aClass)];
}

#pragma mark - Deleting

- (void)deleteObject:(NSManagedObject*)object {
	if (object != nil) {
		assert([object isKindOfClass:[NSManagedObject class]]);
		[[self managedObjectContext] deleteObject:object];
	}
}

#pragma mark - Checking

- (BOOL)hasChanges {
	return [[self managedObjectContext] hasChanges];
}

#pragma mark - Fetching

- (NSArray*)fetchWithEntity:(NSString*)entity orderBy:(NSString*)order predicateString:(NSString*)predicateString {
	NSManagedObjectContext *context =[self managedObjectContext];
	if (context) {
		NSArray *array = nil;
		@try {
			NSPredicate *predicate = nil;
			if (predicateString) {
				predicate = [NSPredicate predicateWithFormat:predicateString];
			}
			array = [context fetchObjectsForEntityName:entity orderBy:order ascending:YES withPredicate:predicate];
		}
		@catch (NSException *exception) {
			array = nil;
			DLog(@"%s %@", __PRETTY_FUNCTION__, exception);
		}
		return array;
	}
	return nil;
}

- (NSArray*)fetchWithEntity:(NSString*)entity orderBy:(NSString*)order predicate:(NSPredicate*)predicate {
	NSManagedObjectContext *context =[self managedObjectContext];
	if (context) {
		NSArray *array = nil;
		@try {
			array = [context fetchObjectsForEntityName:entity orderBy:order ascending:YES withPredicate:predicate];
		}
		@catch (NSException *exception) {
			array = nil;
			DLog(@"%s %@", __PRETTY_FUNCTION__, exception);
		}
		return array;
	}
	return nil;
}


#pragma mark - Override

- (NSString*)databaseFilePath {
	return [[[UIApplication documentsDirectoryPath] stringByAppendingPathComponent:DB_FOLDER] stringByAppendingPathComponent:[self databaseFileName]];
}

- (NSString*)databaseFileName {
	assert(NO);
	return nil;
}

- (NSString*)databaseModelName {
	assert(NO);
	return nil;
}

- (void)handleModelIsIncompatibleWithStore {
	DLog(@"%s", __PRETTY_FUNCTION__);
	assert(NO);
}

@end
