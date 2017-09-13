//
//  EPCPreferencesSession.h
//  Aqui-Imoveis-iOS
//
//  Created by Everton Cunha on 19/09/13.
//  Copyright (c) 2013 Ring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPCPreferencesSession : NSObject  {
	NSMutableDictionary *_preferences;
	NSDictionary *_beforeChangesPreferences;
	int _changes;
}

@property (readwrite,nonatomic) BOOL trackChanges;

+ (id)sharedInstance;

- (NSDictionary*)preferences;

- (void)save;

- (void)setObject:(id)object forKey:(id)key;

- (id)objectForKey:(id)key;

- (void)removeObjectForKey:(id)key;

- (BOOL)hasChanges;

- (void)clearSession;

/*
 MUST OVERRIDE:
 */
- (BOOL)object:(id)obj1 isTheSameAs:(id)obj2;

@end
