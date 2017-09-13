//
//  EPCPreferencesPlist.m
//
//  Created by Everton Cunha on 17/09/13.
//

#import "EPCPreferencesPlist.h"

@implementation EPCPreferencesPlist

#pragma mark - PRIVATE

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
		
		self.automaticallySaves = YES;
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSave) name:UIApplicationWillTerminateNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSave) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)autoSave {
	if (self.automaticallySaves) {
		if (self == [[self class] sharedInstance]) {
			[self save];
		}
	}
}



- (NSMutableDictionary*)preferencesDictionary {
	
	if (!_preferences) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSString *path = [[self class] preferencesPath];
		
		NSMutableDictionary *prefs = nil;
		
		if ([fileManager fileExistsAtPath: path])
		{
			prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		}
		
		if (!prefs) {
			prefs = [[NSMutableDictionary alloc] init];
		}
		
		_preferences = prefs;
	}
	
	return _preferences;
}

- (void)save {
	
	if (_preferences) {
		if (!self.trackChanges || [self hasChanges]) {
			
			_changes = 0;
			_beforeChangesPreferences = nil;
			[self willChangeValueForKey:@"preferences"];
			
			if(![_preferences writeToFile:[[self class] preferencesPath] atomically:YES]) {
				DLog(@"ERROR WRITING PREFERENCES TO FILE");
			}
			
			[self didChangeValueForKey:@"preferences"];
			
		}
		
	}
	
	[super save];
}

+ (NSString*)preferencesPath {
	NSAssert(NO, @"Override me %s", __PRETTY_FUNCTION__);
/*
	static id path = nil;
	if (!path) {
		NSString *documentsDirectory = [UIApplication documentsDirectoryPath];
		path = [[documentsDirectory stringByAppendingPathComponent:@"filter.plist"] copy];
	}
	return path;
 */
	return nil;
}

- (id)copy {
	NSAssert(NO, @"Override me %s", __PRETTY_FUNCTION__);
/*
	FilterPreferences *new = [[FilterPreferences alloc] init];
	new->_preferences = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
	new.trackChanges = self.trackChanges;
*/
	return nil;
}


- (NSDictionary *)preferences {
	return [[NSDictionary alloc] initWithDictionary:[self preferencesDictionary] copyItems:YES];
}

@end
