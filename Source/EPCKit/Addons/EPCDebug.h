//
//  EPCDebug.h
//
//  Created by Everton Postay Cunha on 24/07/12.
//

#import <Foundation/Foundation.h>

@interface EPCDebug : NSObject
+(void)swizzle:(Class)c orig:(SEL)orig new:(SEL)new;
@end
