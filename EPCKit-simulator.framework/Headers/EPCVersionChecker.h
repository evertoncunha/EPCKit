//
//  EPCVersionChecker.h
//
//  Created by Everton Cunha on 16/11/12.
//

#import <Foundation/Foundation.h>

@protocol EPCVersionCheckerDelegate <NSObject>
- (void)appicationBundleChangedFromVersion:(NSString*)previousVersion toVersion:(NSString*)newVersion;
@end

@interface EPCVersionChecker : NSObject

+ (BOOL)appChangedVersion;
@end
