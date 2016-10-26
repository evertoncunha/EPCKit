//
//  EPCQuartzCoreCategories.h
//
//  Created by Everton Cunha on 19/10/12.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface UIView (EPCQuartzCoreCategories)
- (UIImage*)renderToImageOfSize:(CGSize)size opaque:(BOOL)opaque;

- (void)flipVertical;
- (BOOL)isFlippedVertical;

- (void)flipHorizontal;
- (BOOL)isFlippedHorizontal;

- (void)rotateDegrees:(float)degrees;
@end
