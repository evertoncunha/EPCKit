//
//  EPCCoreDataCategories.h
//
//  Created by Everton Cunha on 13/08/12.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (EPCCoreDataCategories)
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...;

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName sortDescriptors:(NSArray*)sortDescriptors withPredicate:(id)stringOrPredicate, ...;

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName orderBy:(NSString*)orderBy ascending:(BOOL)ascending withPredicate:(id)stringOrPredicate, ...;
@end

@interface NSManagedObject (EPCCoreDataCategories)
- (NSArray *)arrayOfValueForKeyPath:(NSString*)key;
@end


@interface NSManagedObject (Clone)
// from http://stackoverflow.com/a/7613406/539194
- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude;
@end