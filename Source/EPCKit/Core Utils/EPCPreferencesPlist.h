//
//  EPCPreferencesPlist.h
//
//  Created by Everton Cunha on 17/09/13.
//

#import <Foundation/Foundation.h>
#import "EPCPreferencesSession.h"

@interface EPCPreferencesPlist : EPCPreferencesSession


@property (nonatomic,readwrite) BOOL automaticallySaves;

@property (nonatomic,readwrite) BOOL syncsWithICloud;

/*
 MUST OVERRIDE:
 */

+ (NSString*)preferencesPath;

@end
