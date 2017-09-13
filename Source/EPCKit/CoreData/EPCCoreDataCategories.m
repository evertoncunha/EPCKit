//
//  EPCCoreDataCategories.m
//
//  Created by Everton Cunha on 13/08/12.
//

#import "EPCCoreDataCategories.h"
#import "EPCDefines.h"

@implementation NSManagedObjectContext (EPCCoreDataCategories)
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ... {
	if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
		stringOrPredicate = predicate;
    }
	
	NSArray *array = [self fetchObjectsForEntityName:newEntityName sortDescriptors:nil withPredicate:stringOrPredicate];
	if ([array count] >0)
		return array;
	return nil;
}
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 sortDescriptors:(NSArray*)sortDescriptors
					   withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
	if (sortDescriptors)
		[request setSortDescriptors:sortDescriptors];
	
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	BOOL excep = NO;
    NSError *error = nil;
	NSArray *results = nil;
	@try {
		results = [self executeFetchRequest:request error:&error];
	}
	@catch (NSException *ex) {
		excep = YES;
		DLog(@"%@", ex);
		return nil;
	}
    if (error != nil && excep == NO)
    {
		DLog(@"%@", error);
    }
	else {
		if ([results count] > 0)
			return results;
	}
	return nil;
}

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
							   orderBy:(NSString*)orderBy
							 ascending:(BOOL)ascending
						 withPredicate:(id)stringOrPredicate, ... {
	
	if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
		stringOrPredicate = predicate;
    }
	
	if (orderBy)
		return [self fetchObjectsForEntityName:newEntityName sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:orderBy ascending:ascending]] withPredicate:stringOrPredicate];
	return [self fetchObjectsForEntityName:newEntityName sortDescriptors:nil withPredicate:stringOrPredicate];
}
@end

@implementation NSManagedObject (EPCCoreDataCategories)
- (void)arrayOfValueForKeyPath:(id)obj inArray:(NSMutableArray*)array {
	if ([obj isKindOfClass:[NSSet class]]) {
		for (id obj2 in obj) {
			[self arrayOfValueForKeyPath:obj2 inArray:array];
		}
	}
	else {
		if (![array containsObject:obj]) {
			[array addObject:obj];
		}
	}
}
- (NSArray *)arrayOfValueForKeyPath:(NSString *)keyPath {
	NSMutableArray *array = [NSMutableArray array];
	id obj =  [self valueForKeyPath:keyPath];
	[self arrayOfValueForKeyPath:obj inArray:array];
	return array;
}
@end


@implementation NSManagedObject (Clone)

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context withCopiedCache:(NSMutableDictionary *)alreadyCopied exludeEntities:(NSArray *)namesOfEntitiesToExclude {
	NSString *entityName = [[self entity] name];
	
	if ([namesOfEntitiesToExclude containsObject:entityName]) {
		return nil;
	}
	
	NSManagedObject *cloned = [alreadyCopied objectForKey:[self objectID]];
	if (cloned != nil) {
		return cloned;
	}
	
	//create new object in data store
	cloned = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	[alreadyCopied setObject:cloned forKey:[self objectID]];
	
	//loop through all attributes and assign then to the clone
	NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName];
	
	for (NSString *attr in attributes) {
		[cloned setValue:[self valueForKey:attr] forKey:attr];
	}
	
	//Loop through all relationships, and clone them.
	NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] relationshipsByName];
	for (NSString *relName in [relationships allKeys]){
		NSRelationshipDescription *rel = [relationships objectForKey:relName];
		
		NSString *keyName = rel.name;
		if ([rel isToMany]) {
			//get a set of all objects in the relationship
			NSMutableSet *sourceSet = [self mutableSetValueForKey:keyName];
			NSMutableSet *clonedSet = [cloned mutableSetValueForKey:keyName];
			NSEnumerator *e = [sourceSet objectEnumerator];
			NSManagedObject *relatedObject;
			while ( relatedObject = [e nextObject]){
				//Clone it, and add clone to set
				NSManagedObject *clonedRelatedObject = [relatedObject cloneInContext:context withCopiedCache:alreadyCopied exludeEntities:namesOfEntitiesToExclude];
				[clonedSet addObject:clonedRelatedObject];
			}
		}else {
			NSManagedObject *relatedObject = [self valueForKey:keyName];
			if (relatedObject != nil) {
				NSManagedObject *clonedRelatedObject = [relatedObject cloneInContext:context withCopiedCache:alreadyCopied exludeEntities:namesOfEntitiesToExclude];
				[cloned setValue:clonedRelatedObject forKey:keyName];
			}
		}
	}
	
	return cloned;
}

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude {
	return [self cloneInContext:context withCopiedCache:[NSMutableDictionary dictionary] exludeEntities:namesOfEntitiesToExclude];
}

@end