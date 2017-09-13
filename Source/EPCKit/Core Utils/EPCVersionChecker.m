//
//  EPCVersionChecker.m
//
//  Created by Everton Cunha on 16/11/12.
//

#import "EPCVersionChecker.h"
#import <UIKit/UIKit.h>

#define kLastVersionKey @"kLastVersionKey"

@implementation EPCVersionChecker

static id myself = nil;

+ (void)load {
	myself = [[[self class] alloc] init];
	if (myself) {
		[[NSNotificationCenter defaultCenter] addObserver:myself selector:@selector(appDidBecomeActive) name:UIApplicationDidFinishLaunchingNotification object:nil];
	}
}

- (void)appDidBecomeActive {
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
	NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kLastVersionKey];
	if (![currentVersion isEqualToString:lastVersion]) {
		// version changed
		
		[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLastVersionKey];
		
		id appdelegate = [[UIApplication sharedApplication] delegate];
		if ([appdelegate conformsToProtocol:@protocol(EPCVersionCheckerDelegate)]) {
			[appdelegate appicationBundleChangedFromVersion:lastVersion toVersion:currentVersion];
		}
		
		// do it again in case the stanstardUserDefaults got cleared
		[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLastVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:myself name:UIApplicationDidBecomeActiveNotification object:nil];
	myself = nil;
}

+ (BOOL)appChangedVersion {
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
	NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kLastVersionKey];
	return ![currentVersion isEqualToString:lastVersion] && lastVersion != nil;
}

@end
