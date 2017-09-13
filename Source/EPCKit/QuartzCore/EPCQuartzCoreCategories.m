//
//  EPCQuartzCoreCategories.m
//
//  Created by Everton Cunha on 19/10/12.
//

#import "EPCQuartzCoreCategories.h"
#import "EPCDefines.h"

@implementation UIView (EPCQuartzCoreCategories)
- (UIImage*)renderToImageOfSize:(CGSize)size opaque:(BOOL)opaque
{
	CGRect originalRect = self.frame;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
	UIGraphicsBeginImageContextWithOptions(self.frame.size, opaque, 0.0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.frame = originalRect;
	return image;
}
- (void)flipVertical {
	BOOL m22 = self.layer.transform.m22 == 1;
	self.layer.transform = CATransform3DMakeRotation(M_PI,1.0*m22,0.0,0.0);
}
- (BOOL)isFlippedVertical {
	return self.layer.transform.m22 == 1;
}
- (void)rotateDegrees:(float)degrees {
	CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadians(degrees));
	self.transform = transform;
}

- (void)flipHorizontal {
	BOOL m33 = self.layer.transform.m33 == 1;
	self.layer.transform = CATransform3DMakeRotation(M_PI,0.0,1.0*m33,0.0);
}
- (BOOL)isFlippedHorizontal {
	return self.layer.transform.m33 == -1;
}
@end