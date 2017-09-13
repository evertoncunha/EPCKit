//
//  EPCCategories.m
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#import "EPCCategories.h"
#import "EPCDefines.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/xattr.h>
#import <objc/runtime.h>

#if TARGET_OS_IPHONE

/// * ALERTVIEW *

@interface NSCBAlertWrapper : NSObject
@property (copy) void(^completionBlock)(UIAlertView *alertView, NSInteger buttonIndex);
@end
@implementation NSCBAlertWrapper
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock)
        self.completionBlock(alertView, buttonIndex);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
    // Just simulate a cancel button click
    if (self.completionBlock)
        self.completionBlock(alertView, alertView.cancelButtonIndex);
}
@end
static const char kNSCBAlertWrapper;
@implementation UIAlertView (EPCCategories)
- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion
{
    NSCBAlertWrapper *alertWrapper = [[NSCBAlertWrapper alloc] init];
    alertWrapper.completionBlock = completion;
    self.delegate = alertWrapper;
	
    // Set the wrapper as an associated object
    objc_setAssociatedObject(self, &kNSCBAlertWrapper, alertWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
    // Show the alert as normal
    [self show];
}
@end

/// * END ALERTVIEW *

@implementation UIViewController (EPCCategories)
- (void)popViewControllerAnimated {
	[self.navigationController popViewControllerAnimated:YES];
}
+ (instancetype)loadFromStoryboard:(NSString *)storyboard {
	return [[UIStoryboard storyboardWithName:storyboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}
@end

@implementation UIColor (EPCCategories)
+ (UIColor*)randomColor {
	CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
	UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
	return color;
}

- (float)brightness {
	CGFloat red, green, blue, alpha = 0;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	float bright = ((red * 299) + (green * 587) + (blue * 114)) / 1000;
	return bright;
}
@end

@implementation UILabel (EPCCategories)
- (void)setFontPointSize:(CGFloat)pointSize {
	self.font = [UIFont fontWithName:self.font.fontName size:pointSize];
}
-(CGFloat)fontPointSize {
	return self.font.pointSize;
}
@end

@implementation UIImage (EPCCategories)
+(UIImage *)imageWithContentsOfFileNamed:(NSString *)name {
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]]];
}
+(UIImage *)imageWithContentsOfFileInDocumentsDirectoryNamed:(NSString *)name {
	if (name) {
		NSString *path = [[UIApplication documentsDirectoryPath] stringByAppendingPathComponent:name];
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			return [UIImage imageWithContentsOfFile:path];
		}
	}
	return nil;
}
+(UIImage *)imageWithContentsOfFileInCacheDirectoryNamed:(NSString *)name {
	return [UIImage imageWithContentsOfFile:[[UIApplication cacheDirectoryPath] stringByAppendingPathComponent:name]];
}
-(UIImage *)imageAtRect:(CGRect)rect
{
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
	UIImage* subImage = [UIImage imageWithCGImage: imageRef];
	CGImageRelease(imageRef);
	
	return subImage;
	
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor > heightFactor)
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		
		if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		} else if (widthFactor < heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) DLog(@"could not scale image");
	
	
	return newImage ;
}

- (UIImage *)imageByScalingProportionallyToWidth:(CGFloat)targetWidth {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	
	CGFloat scaleFactor = targetWidth / width;
	
	CGFloat scaledWidth  = width * scaleFactor;
	CGFloat scaledHeight = height * scaleFactor;
	
	
	CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) DLog(@"could not scale image");
	
	
	return newImage ;
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor < heightFactor)
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		
		if (widthFactor < heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		} else if (widthFactor > heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) DLog(@"could not scale image");
	
	
	return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	//   CGSize imageSize = sourceImage.size;
	//   CGFloat width = imageSize.width;
	//   CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	//   CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) DLog(@"could not scale image");
	
	
	return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
	return [self imageRotatedByDegrees:radiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width*self.scale, self.size.height*self.scale)];
	CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	rotatedViewBox = nil;
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, degreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width*self.scale / 2, -self.size.height*self.scale / 2, self.size.width*self.scale, self.size.height*self.scale), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
	
}

- (UIImage *)imageTintedWithColor:(UIColor *)color
{
	// This method is designed for use with template images, i.e. solid-coloured mask-like images.
	return [self imageTintedWithColor:color fraction:0.0]; // default to a fully tinted mask of the image.
}


- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction
{
	if (color) {
		// Construct new image the same size as this one.
		UIImage *image;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
		if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
			UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f); // 0.f for scale means "scale for device's main screen".
		} else {
			UIGraphicsBeginImageContext([self size]);
		}
#else
		UIGraphicsBeginImageContext([self size]);
#endif
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		// Composite tint color at its own opacity.
		[color set];
		UIRectFill(rect);
		
		// Mask tint color-swatch to this image's opaque mask.
		// We want behaviour like NSCompositeDestinationIn on Mac OS X.
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		
		// Finally, composite this image over the tinted mask at desired opacity.
		if (fraction > 0.0) {
			// We want behaviour like NSCompositeSourceOver on Mac OS X.
			[self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
		}
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	
	return self;
}

+ (UIImage *)imageNamedA4I:(NSString*)name {
	NSString *inch4name = [[name stringByDeletingPathExtension] stringByAppendingString:@"568h@2x.png"];
	NSString *path = [[NSBundle mainBundle] pathForResource:[inch4name stringByDeletingPathExtension] ofType:[name pathExtension]];
	if (path) {
		return [UIImage imageNamed:[inch4name stringByAppendingPathExtension:[name pathExtension]]];
	}
	return [UIImage imageNamed:path];
}

- (UIImage *)resizableWidthImage {
	return [self resizableImageWithCapInsets:UIEdgeInsetsMake(0, (self.size.width/2)-1, 0, (self.size.width/2))];
}

-(UIImage *)resizableHeightImage {
	return [self resizableImageWithCapInsets:UIEdgeInsetsMake((self.size.height/2)-1, 0, (self.size.height/2), 0)];
}

- (UIImage *)resizableImage {
	return [self resizableImageWithCapInsets:UIEdgeInsetsMake((self.size.height/2)-1, (self.size.width/2)-1, (self.size.height/2), (self.size.width/2))];
}

- (UIImage*) replaceColor:(UIColor*)color withTolerance:(float)tolerance {
	
	UIImage *image = self;
	
	CGImageRef imageRef = [image CGImage];
	
	NSUInteger width = CGImageGetWidth(imageRef);
	NSUInteger height = CGImageGetHeight(imageRef);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * width;
	NSUInteger bitsPerComponent = 8;
	NSUInteger bitmapByteCount = bytesPerRow * height;
	
	unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
	
	CGContextRef context = CGBitmapContextCreate(rawData, width, height,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
	
	CGColorRef cgColor = [color CGColor];
	const CGFloat *components = CGColorGetComponents(cgColor);
	float r = components[0];
	float g = components[1];
	float b = components[2];
	//float a = components[3]; // not needed
	
	r = r * 255.0;
	g = g * 255.0;
	b = b * 255.0;
	
	const float redRange[2] = {
		MAX(r - (tolerance / 2.0), 0.0),
		MIN(r + (tolerance / 2.0), 255.0)
	};
	
	const float greenRange[2] = {
		MAX(g - (tolerance / 2.0), 0.0),
		MIN(g + (tolerance / 2.0), 255.0)
	};
	
	const float blueRange[2] = {
		MAX(b - (tolerance / 2.0), 0.0),
		MIN(b + (tolerance / 2.0), 255.0)
	};
	
	int byteIndex = 0;
	
	while (byteIndex < bitmapByteCount) {
		unsigned char red   = rawData[byteIndex];
		unsigned char green = rawData[byteIndex + 1];
		unsigned char blue  = rawData[byteIndex + 2];
		
		if (((red >= redRange[0]) && (red <= redRange[1])) &&
			((green >= greenRange[0]) && (green <= greenRange[1])) &&
			((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
			// make the pixel transparent
			//
			rawData[byteIndex] = 0;
			rawData[byteIndex + 1] = 0;
			rawData[byteIndex + 2] = 0;
			rawData[byteIndex + 3] = 0;
		}
		
		byteIndex += 4;
	}
	
	UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
	
	CGContextRelease(context);
	free(rawData);
	
	return result;
}


- (UIColor *)averageColor
{
	CGImageRef rawImageRef = [self CGImage];
	
	// This function returns the raw pixel values
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
	const UInt8 *rawPixelData = CFDataGetBytePtr(data);
	
	NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
	NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
	NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
	NSUInteger stride = CGImageGetBitsPerPixel(rawImageRef) / 8;
	
	// Here I sort the R,G,B, values and get the average over the whole image
	unsigned int red   = 0;
	unsigned int green = 0;
	unsigned int blue  = 0;
	
	for (int row = 0; row < imageHeight; row++) {
		const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
		for (int column = 0; column < imageWidth; column++) {
			red    += rowPtr[0];
			green  += rowPtr[1];
			blue   += rowPtr[2];
			rowPtr += stride;
			
		}
	}
	CFRelease(data);
	
	CGFloat f = 1.0f / (255.0f * imageWidth * imageHeight);
	return [UIColor colorWithRed:f * red  green:f * green blue:f * blue alpha:1];
}

- (UIColor *)mergedColor
{
	CGSize size = {1, 1};
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
	[self drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
	uint8_t *data = CGBitmapContextGetData(ctx);
	UIColor *color = [UIColor colorWithRed:data[2] / 255.0f
									 green:data[1] / 255.0f
									  blue:data[0] / 255.0f
									 alpha:1];
	UIGraphicsEndImageContext();
	return color;
}

- (UIColor *)colorAtPoint:(CGPoint)pixelPoint
{
	if (pixelPoint.x > self.size.width ||
		pixelPoint.y > self.size.height) {
		return nil;
	}
	
	CGDataProviderRef provider = CGImageGetDataProvider(self.CGImage);
	CFDataRef pixelData = CGDataProviderCopyData(provider);
	const UInt8* data = CFDataGetBytePtr(pixelData);
	
	int numberOfColorComponents = 4; // R,G,B, and A
	float x = pixelPoint.x;
	float y = pixelPoint.y;
	float w = self.size.width;
	int pixelInfo = ((w * y) + x) * numberOfColorComponents;
	
	UInt8 red = data[pixelInfo];
	UInt8 green = data[(pixelInfo + 1)];
	UInt8 blue = data[pixelInfo + 2];
	UInt8 alpha = data[pixelInfo + 3];
	CFRelease(pixelData);
	
	// RGBA values range from 0 to 255
	return [UIColor colorWithRed:red/255.0
						   green:green/255.0
							blue:blue/255.0
						   alpha:alpha/255.0];
}

@end

@implementation UIApplication (EPCCategories)
+ (NSString *)documentsDirectoryPath {
	static __strong id dir = nil;
	if (!dir) {
		dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
	}
	return dir;
}
+ (NSString *)cacheDirectoryPath {
	static __strong id cachedir = nil;
	if (!cachedir) {
		cachedir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
	}
	return cachedir;
}
+ (NSString *)tmpDirectoryPath {
	static __strong id tempDir = nil;
	if (!tempDir) {
		tempDir = [NSTemporaryDirectory() copy];
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:tempDir]) {
			[fm createDirectoryAtPath:tempDir withIntermediateDirectories:NO attributes:nil error:nil];
		}
	}
	return tempDir;
}

+ (UIViewController*)visibleViewController {
	UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	while ([root isKindOfClass:[UINavigationController class]] || [root isKindOfClass:[UITabBarController class]]) {
		while ([root isKindOfClass:[UINavigationController class]]) {
			root = [[(UINavigationController*)root viewControllers] lastObject];
		}
		while ([root isKindOfClass:[UITabBarController class]]) {
			root = [(UITabBarController*)root selectedViewController];
		}
	}
	return root;
}

@end

@implementation UIAlertController (EPCCategories)
- (UIView*)superview {
	return nil;
}
- (CGRect)frame {
	return CGRectZero;
}
- (void)setFrame:(CGRect)r {
}
@end

@implementation UIView (EPCCategories)
- (BOOL)isAtScreen {
	CGRect keyRect = [self convertRect:self.bounds toView:nil];
	return CGRectContainsRect([[UIScreen mainScreen] bounds], keyRect);
}
+ (id)loadFromNibName:(NSString*)nibName {
	return [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];
}
+ (id)loadFromNib {
	return [self loadFromNibName:NSStringFromClass(self)];
}
+ (id)loadFromNibReplacingView:(UIView *)view {
	UIView *vv = nil;
	if (view && view.superview) {
		vv = [self loadFromNib];
		vv.frame = view.frame;
		[view.superview addSubview:vv];
		[view removeFromSuperview];
	}
	return vv;
}
- (void)removeAllSubviews {
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
- (void)removeAllSubviewsOfClass:(Class)aClass {
	for (UIView *sub in self.subviews) {
		if ([sub isKindOfClass:aClass]) {
			[sub removeFromSuperview];
		}
	}
}
-(void)sizeToFitHeight{
	CGSize size = [self sizeThatFits:CGSizeMake(self.frameWidth, MAXFLOAT)];
	self.frameSize = CGSizeMake(self.frameWidth, size.height);
}
-(void)sizeToFitWidth{
	CGSize size = [self sizeThatFits:CGSizeMake(MAXFLOAT, self.frameHeight)];
	self.frameSize = CGSizeMake(size.width, self.frameHeight);
}
- (CGPoint)frameOrigin {
	return self.frame.origin;
}
- (void)setFrameOrigin:(CGPoint)newOrigin {
	self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}
- (CGSize)frameSize {
	return self.frame.size;
}
- (void)setFrameSize:(CGSize)newSize {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width, newSize.height);
}
- (CGFloat)frameX {
	return self.frame.origin.x;
}
- (void)setFrameX:(CGFloat)newX {
	self.frame = CGRectMake(newX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
- (CGFloat)frameY {
	return self.frame.origin.y;
}
- (void)setFrameY:(CGFloat)newY {
	self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
}
- (CGFloat)frameWidth {
	return self.frame.size.width;
}
- (void)setFrameWidth:(CGFloat)newWidth {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
}
- (CGFloat)frameHeight {
	return self.frame.size.height;
}
- (void)setFrameHeight:(CGFloat)newHeight {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
}
@end

@implementation UIWebView (EPCCategories)

- (UIScrollView*)webScrollView {
	
	UIScrollView *webScrollView = nil;
	if ([self respondsToSelector:@selector(scrollView)]) {
		webScrollView = self.scrollView;
	}
	else {
		for (id sub in self.subviews) {
			if ([sub isKindOfClass:[UIScrollView class]]) {
				webScrollView = sub;
				break;
			}
		}
	}
	return webScrollView;
}

- (void)disableScroll {
	[self webScrollView].scrollEnabled  = NO;
}

- (void)adjustToHeight {
	UIScrollView *webScrollView = [self webScrollView];
	if (webScrollView)
		self.frameHeight = webScrollView.contentSize.height;
}

-(void)ajustToHeightAndStopBouncing {
	UIScrollView *webScrollView = [self webScrollView];
	if (webScrollView) {
		self.frameHeight = webScrollView.contentSize.height;
		webScrollView.bounces = NO;
	}
}
@end

__weak static id currentFirstResponder;
@implementation UIResponder (EPCCategories)
+(id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
-(void)findFirstResponder:(id)sender {
	if ([self respondsToSelector:@selector(subviews)]) {
		currentFirstResponder = self;
	}
}
@end

@implementation UIScrollView (EPCCategories)

- (void)scrollToBottomAnimated:(BOOL)animated {
	CGPoint bottomOffset = CGPointMake(0, self.contentSize.height - self.bounds.size.height);
	[self setContentOffset:bottomOffset animated:animated];
}

-(void)contentSizeFit {
	int w = 0, h = 0;
	for (UIView *v in self.subviews) {
		int nw = v.frameX + v.frameWidth;
		int nh = v.frameY + v.frameHeight;
		w = MAX(w, nw);
		h = MAX(h, nh);
	}
	[self setContentSize:CGSizeMake(w, h)];
}
-(void)contentSizeFitWidth {
	int w = 0;
	for (UIView *v in self.subviews) {
		int nw = v.frameX + v.frameWidth;
		w = MAX(w, nw);
	}
	[self setContentSize:CGSizeMake(w, self.contentSize.height)];
}
-(void)contentSizeFitHeight {
	int h = 0;
	for (UIView *v in self.subviews) {
		int nh = v.frameY + v.frameHeight;
		h = MAX(h, nh);
	}
	[self setContentSize:CGSizeMake(self.contentSize.width, h)];
}
@end

@implementation UICollectionView (EPCCategories)

-(void)changeDataAnimatedFromArray:(NSArray *)oldEntries toArray:(NSArray *)newEntries {

	NSMutableArray* rowsToDelete = [NSMutableArray array];
	NSMutableArray* rowsToInsert = [NSMutableArray array];

	[UITableView changeDataFromArray:oldEntries toArray:newEntries rowsToDelete:rowsToDelete rowsToInsert:rowsToInsert];
	
	if ([rowsToDelete count] > 0 || [rowsToInsert count] > 0) {
		
		[self performBatchUpdates:^{
			
			if ([rowsToDelete count] > 0) {
				[self deleteItemsAtIndexPaths:rowsToDelete];
			}
			
			if ([rowsToInsert count] > 0) {
				[self insertItemsAtIndexPaths:rowsToInsert];
			}
			
			
		} completion:NULL];
	}

}
@end

@implementation UITableView (EPCCategories)

-(void)changeDataAnimatedFromArray:(NSArray *)oldEntries toArray:(NSArray *)newEntries {
	
	UITableView*tableView = self;
	
	@try {
		NSMutableArray* rowsToDelete = [NSMutableArray array];
		NSMutableArray* rowsToInsert = [NSMutableArray array];
		
		[UITableView changeDataFromArray:oldEntries toArray:newEntries rowsToDelete:rowsToDelete rowsToInsert:rowsToInsert];
		
		if ([rowsToDelete count] > 0 || [rowsToInsert count] > 0) {
			[tableView beginUpdates];
			if ([rowsToDelete count] > 0) {
				[tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
			}
			if ([rowsToInsert count] > 0) {
				[tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
			}
			[tableView endUpdates];
		}
	}
	@catch (NSException *exception) {
		
		DLog(@"%@", exception);
		[tableView reloadData];
	}
}

- (void)sortTableViewAnimatedFromUnsorted:(NSArray*)unsorted toSorted:(NSArray*)sorted {
 
	UITableView *tableView = self;
	
	// Prepare table for the animations batch
	[tableView beginUpdates];
 
	// Move the cells around
	NSInteger sourceRow = 0;
	for (NSString *city in unsorted) {
		NSInteger destRow = [sorted indexOfObject:city];
		
		if (destRow != sourceRow) {
			// Move the rows within the table view
			NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:sourceRow inSection:0];
			NSIndexPath *destIndexPath = [NSIndexPath indexPathForItem:destRow inSection:0];
			[tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destIndexPath];
		}
		sourceRow++;
	}
 
	// Commit animations
	[tableView endUpdates];
}

+ (void)changeDataFromArray:(NSArray *)oldEntries toArray:(NSArray *)newEntries rowsToDelete:(NSMutableArray*)rowsToDelete rowsToInsert:(NSMutableArray*)rowsToInsert {
	
	int section = 0;
	
	for ( NSInteger i = 0; i < oldEntries.count; i++ )
	{
		id theOldObj = oldEntries[i];
		
		BOOL contains = NO;
		
		for (int j = 0; j < [newEntries count]; j++) {
			id theNewObj = newEntries[j];
			if ([theOldObj compare:theNewObj] == NSOrderedSame) {
				contains = YES;
				break;
			}
		}
		
		if (!contains) {
			[rowsToDelete addObject: [NSIndexPath indexPathForRow:i inSection:section]];
		}
	}
	
	for ( NSInteger i = 0; i < newEntries.count; i++ )
	{
		id theNewObj = newEntries[i];
		
		BOOL contains = NO;
		
		for (int j = 0; j < [oldEntries count]; j++) {
			id theOldObj = oldEntries[j];
			if ([theOldObj compare:theNewObj] == NSOrderedSame) {
				contains = YES;
				break;
			}
		}
		
		if (!contains) {
			[rowsToInsert addObject: [NSIndexPath indexPathForRow:i inSection:section]];
		}
	}
}
@end

@implementation UITableViewCell (EPCCategories)
- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
	if (!self.backgroundView) {
		self.selectedBackgroundView = [[UIView alloc] init];
	}
	self.selectedBackgroundView.backgroundColor = selectedBackgroundColor;
}
@end

@implementation NSFileManager (EPCCategories)
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
		if (!IOS_VERSION_LESS_THAN(@"5.1")) {
			NSError *error = nil;
			BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
										  forKey: NSURLIsExcludedFromBackupKey error: &error];
			if(!success){
				DLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
			}
			return success;
		}
		else if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"5.0.1"]) {
			const char* filePath = [[URL path] fileSystemRepresentation];
			const char* attrName = "com.apple.MobileBackup";
			u_int8_t attrValue = 1;
			int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
			return result == 0;
		}
	}
	return NO;
}
@end

#else

// MAC ONLY

@implementation NSAttributedString (EPCCategories)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
	
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
	
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
    [attrString addAttribute:
	 NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
    [attrString endEditing];
	
    return attrString;
}
@end

#endif

@implementation NSUserDefaults (EPCCategories)
+ (BOOL)syncBool:(BOOL)value forKey:(NSString*)key {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:value forKey:key];
	return [ud synchronize];
}
+ (BOOL)boolForKey:(NSString*)key {
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
+ (BOOL)syncObject:(id)object forKey:(NSString*)key {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:object forKey:key];
	return [ud synchronize];
}
+ (id)objectForKey:(NSString*)key {
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
+(void)clearUserDefaults {
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
@end

@implementation NSObject (EPCCategories)
- (id)objectForSelector:(SEL)selector {
	id obj = self;
	IMP imp = [obj methodForSelector:selector];
	NSString * (*func)(id, SEL) = (void *)imp;
	return func(obj, selector);
}
- (BOOL)hasEqualPropertiesWith:(NSObject *)obj {
	unsigned int numberOfProperties = 0;
	objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
	
	BOOL result = YES;
	for (NSUInteger i = 0; i < numberOfProperties; i++)
	{
		objc_property_t property = propertyArray[i];
		NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
		
		id test1 = [self valueForKey:name];
		id test2 = [obj valueForKey:name];
		
		if (test1 && test2) {
			if (![test1 isEqual:test2]) {
				result = NO;
				break;
			}
		}
		else if (!test1 && !test2) {
			
		}
		else {
			result = NO;
			break;
		}
	}
	free(propertyArray);
	
	return result;
}

- (NSArray *)propertyNames {
	unsigned int numberOfProperties = 0;
	objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
	
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSUInteger i = 0; i < numberOfProperties; i++)
	{
		objc_property_t property = propertyArray[i];
		NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
		[result addObject:name];
	}
	free(propertyArray);
	
	return result;
}
@end

@implementation	NSArray (EPCCategories)
- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
- (NSArray *)sortedArrayWithKey:(NSString *)key ascending:(BOOL)asc {
	NSInteger options = NSCaseInsensitiveSearch
	| NSNumericSearch              // Numbers are compared using numeric value
	| NSDiacriticInsensitiveSearch // Ignores diacritics (â == á == a)
	| NSWidthInsensitiveSearch;    // Unicode special width is ignored
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:key ascending:asc comparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 respondsToSelector:@selector(compare:options:)]) {
			return [obj1 compare:obj2 options:options];
		}
		return [obj1 compare:obj2];
	}];
	return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)sortedArrayWithKeys:(NSArray*)keys ascendings:(NSArray*)ascendings {
	
	NSInteger options = NSCaseInsensitiveSearch
	| NSNumericSearch              // Numbers are compared using numeric value
	| NSDiacriticInsensitiveSearch // Ignores diacritics (â == á == a)
	| NSWidthInsensitiveSearch;    // Unicode special width is ignored
	
	NSMutableArray *sorts = [NSMutableArray arrayWithCapacity:[keys count]];
	
	for (int i = 0; i < [keys count]; i++) {
		
		NSString *key = keys[i];
		
		BOOL asc = YES;
		
		if ([ascendings count] > i) {
			asc = [ascendings[i] boolValue];
		}
		
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:key ascending:asc comparator:^NSComparisonResult(id obj1, id obj2) {
			if ([obj1 respondsToSelector:@selector(compare:options:)]) {
				return [obj1 compare:obj2 options:options];
			}
			return [obj1 compare:obj2];
		}];
		
		[sorts addObject:sort];
	}
	return [self sortedArrayUsingDescriptors:sorts];
}
static NSInteger comparatorForSortingUsingArray(id object1, id object2, void *context) {
    NSUInteger index1 = [(__bridge NSArray *)context indexOfObject:object1];
    NSUInteger index2 = [(__bridge NSArray *)context indexOfObject:object2];
    if (index1 < index2)
        return NSOrderedAscending;
    // else
    if (index1 > index2)
        return NSOrderedDescending;
    // else
    return [object1 compare:object2];
}
- (NSArray *)sortedArrayUsingArray:(NSArray *)otherArray {
    return [self sortedArrayUsingFunction:comparatorForSortingUsingArray context:(__bridge void *)(otherArray)];
}
- (id)firstObjectWithPredicate:(NSPredicate*)predicate {
	for (id obj in self) {
		if ([predicate evaluateWithObject:obj]) {
			return obj;
		}
	}
	return nil;
}
@end

@implementation NSMutableArray (EPCCategories)
- (void)reverse {
	if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:j];
        i++;
        j--;
    }
}
- (void)removeNullObjects {
	for (int i = 0; i < [self count]; i++) {
		id obj = [self objectAtIndex:i];
		if ([obj isKindOfClass:[NSNull class]]) {
			[self removeObjectAtIndex:i];
			i--;
		}
		else if ([obj isKindOfClass:[NSMutableDictionary class]]) {
			[obj removeNullObjects];
		}
	}
}
@end

@implementation	NSSet (EPCCategories)
- (NSArray *)sortedArrayWithKey:(NSString *)key ascending:(BOOL)asc {
	return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:asc]]];
}
@end

@implementation NSMutableDictionary (EPCCategories)
-(void)setNullToNilAtDictionariesInArray:(NSMutableArray*)array {
	for (id item in array) {
		if ([item isKindOfClass:[NSMutableDictionary class]]) {
			[self setNullToNilInDictionary:item];
			
		} else if ([item isKindOfClass:[NSMutableArray class]]) {
			[self setNullToNilAtDictionariesInArray:item];
		}
	}
}
-(void)setNullToNilInDictionary:(NSMutableDictionary*)d {
	for(NSString *key in [d allKeys]) {
		id obj = [d objectForKey:key];
		if ([obj isKindOfClass:[NSNull class]]){
			[d removeObjectForKey:key];
		} else if([obj isKindOfClass:[NSMutableArray class]] || [obj isKindOfClass:[NSMutableDictionary class]]) {
			[obj removeNullObjects];
		}
	}
}
- (void)removeNullObjects {
	[self setNullToNilInDictionary:self];
}
@end

@implementation NSString (EPCCategories)

- (UIColor *)colorFromHexCode {
	if ([self length] > 0) {
		// #123456
		return UIColorFromRGB((UInt32)strtoull([[self substringFromIndex:1] UTF8String], NULL, 16));
	}
	return nil;
}

- (NSArray*)arrayOfStringsBetweenString:(NSString*)start andString:(NSString*)end {
	
	NSMutableArray *mut = [NSMutableArray array];
	
	NSRange s = [self rangeOfString:start];
	while (s.location!=NSNotFound) {
		NSRange e = [self rangeOfString:end fromRange:s];
		if(e.location==NSNotFound) {
			[NSException raise:@"EPCCategories Exception" format:@"%s Could not find the end string %@", __PRETTY_FUNCTION__, end];
			s.location = NSNotFound;
		}
		else {
			NSString *str = [self substringFromRange:s toRange:e];
			[mut addObject:str];
			s = [self rangeOfString:start fromRange:e];
		}
	}
	
	if ([mut count] == 0) {
		return nil;
	}
	
	return mut;
}

- (NSString *)substringFromLocation:(NSInteger)fromLocation toLocation:(NSInteger)toLocation {
	return [self substringWithRange:NSMakeRange(fromLocation, toLocation-fromLocation)];
}

- (NSRange)rangeOfString:(NSString*)string fromRange:(NSRange)range {
	return [self rangeOfString:string options:0 range:NSMakeRange(range.location+range.length, [self length]-(range.location+range.length))];
}

- (NSString *)substringFromRange:(NSRange)fromRange toRange:(NSRange)toRange {
	return [self substringWithRange:NSMakeRange(fromRange.location+fromRange.length, toRange.location - (fromRange.location+fromRange.length))];
}

- (NSString *)decodeHTMLCharacterEntities {
    if ([self rangeOfString:@"&"].location == NSNotFound) {
        return self;
    } else {
        NSMutableString *escaped = [NSMutableString stringWithString:self];
        NSArray *codes = [NSArray arrayWithObjects:
                          @"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;", @"&curren;", @"&yen;", @"&brvbar;",
                          @"&sect;", @"&uml;", @"&copy;", @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;",
                          @"&macr;", @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
                          @"&para;", @"&middot;", @"&cedil;", @"&sup1;", @"&ordm;", @"&raquo;", @"&frac14;",
                          @"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;", @"&Acirc;",
                          @"&Atilde;", @"&Auml;", @"&Aring;", @"&AElig;", @"&Ccedil;", @"&Egrave;",
                          @"&Eacute;", @"&Ecirc;", @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;",
                          @"&ETH;", @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;", @"&Ouml;",
                          @"&times;", @"&Oslash;", @"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", @"&Yacute;",
                          @"&THORN;", @"&szlig;", @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
                          @"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;",
                          @"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", @"&eth;", @"&ntilde;", @"&ograve;",
                          @"&oacute;", @"&ocirc;", @"&otilde;", @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
                          @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;", @"&yuml;", nil];
		
        NSUInteger i, count = [codes count];
		
        // Html
        for (i = 0; i < count; i++) {
            NSRange range = [self rangeOfString:[codes objectAtIndex:i]];
            if (range.location != NSNotFound) {
                [escaped replaceOccurrencesOfString:[codes objectAtIndex:i]
                                         withString:[NSString stringWithFormat:@"%C", (unsigned short) (160 + i)]
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [escaped length])];
            }
        }
		
        // The following five are not in the 160+ range
		
        // @"&amp;"
        NSRange range = [self rangeOfString:@"&amp;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&amp;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 38]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
		
        // @"&lt;"
        range = [self rangeOfString:@"&lt;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&lt;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 60]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
		
        // @"&gt;"
        range = [self rangeOfString:@"&gt;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&gt;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 62]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
		
        // @"&apos;"
        range = [self rangeOfString:@"&apos;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&apos;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 39]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
		
        // @"&quot;"
        range = [self rangeOfString:@"&quot;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&quot;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 34]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
		
        // Decimal & Hex
        NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
        i = 0;
		
        while (i < [escaped length]) {
            start = [escaped rangeOfString:@"&#"
                                   options:NSCaseInsensitiveSearch
                                     range:searchRange];
			
            finish = [escaped rangeOfString:@";"
                                    options:NSCaseInsensitiveSearch
                                      range:searchRange];
			
            if (start.location != NSNotFound && finish.location != NSNotFound &&
                finish.location > start.location) {
                NSRange entityRange = NSMakeRange(start.location, (finish.location - start.location) + 1);
                NSString *entity = [escaped substringWithRange:entityRange];
                NSString *value = [entity substringWithRange:NSMakeRange(2, [entity length] - 2)];
				
                [escaped deleteCharactersInRange:entityRange];
				
                if ([value hasPrefix:@"x"]) {
                    unsigned tempInt = 0;
                    NSScanner *scanner = [NSScanner scannerWithString:[value substringFromIndex:1]];
                    [scanner scanHexInt:&tempInt];
                    [escaped insertString:[NSString stringWithFormat:@"%C", (unsigned short) tempInt] atIndex:entityRange.location];
                } else {
                    [escaped insertString:[NSString stringWithFormat:@"%C", (unsigned short) [value intValue]] atIndex:entityRange.location];
                } i = start.location;
            } else { i++; }
            searchRange = NSMakeRange(i, [escaped length] - i);
        }
		
        return escaped;    // Note this is autoreleased
    }
}

- (NSString *)encodeHTMLCharacterEntities {
    NSMutableString *encoded = [NSMutableString stringWithString:self];
	
    // @"&amp;"
    NSRange range = [self rangeOfString:@"&"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"&"
                                 withString:@"&amp;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
	
    // @"&lt;"
    range = [self rangeOfString:@"<"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"<"
                                 withString:@"&lt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
	
    // @"&gt;"
    range = [self rangeOfString:@">"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@">"
                                 withString:@"&gt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
	
    return encoded;
}

- (NSArray*)arrayByExplodingWithString:(NSString*)string {
	NSMutableArray *strings = [NSMutableArray array];
	NSRange range = [self rangeOfString:string];
	if (range.location != NSNotFound) { // first
		NSString *subf = [self substringWithRange:NSMakeRange(0, range.location)];
		if ([subf length] > 0) {
			[strings addObject:subf];
		}
	}
	while (range.location != NSNotFound && range.location > 0) {
		NSRange nextRange = [self rangeOfString:string options:NSLiteralSearch range:NSMakeRange(range.location+range.length, [self length] - (range.location+range.length))];
		NSString *subs = nil;
		if (nextRange.location == NSNotFound) {
			subs = [self substringFromIndex:range.location+range.length];
		}
		else {
			subs = [self substringWithRange:NSMakeRange(range.location+range.length, nextRange.location-(range.location+range.length))];
		}
		if ([subs length] > 0)
			[strings addObject:subs];
		range = nextRange;
	}
	if ([strings count] > 0)
		return strings;
	if ([self length] > 0)
		return [NSArray arrayWithObject:self];
	return nil;
}
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}
- (NSString *)sha1 {
	NSString *str = self;
	const char *cStr = [str UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
	NSString *s = [NSString  stringWithFormat:
				   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   result[0], result[1], result[2], result[3], result[4],
				   result[5], result[6], result[7],
				   result[8], result[9], result[10], result[11], result[12],
				   result[13], result[14], result[15],
				   result[16], result[17], result[18], result[19]
				   ];
	
    return s;
}
- (NSURL*)urlSafe {
	NSURL *url = [NSURL URLWithString:self];
	if (!url)
		url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	return url;
}
-(NSString *)phpURLEncoded {
	NSMutableString *str = [[NSMutableString alloc] initWithString:[self stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	[str replaceOccurrencesOfString:@":" withString:@"%3A" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"&" withString:@"%26" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	NSString *encodedString = [str copy];
	str = nil;
	return encodedString;
}
- (NSString*)stringByTruncatingToLength:(int)limit tail:(NSString*)tail {
	NSString *text = self;
	if ([text length] > limit) {
		if ([[text substringWithRange:NSMakeRange(limit, 1)] isEqualToString:@" "]) {
			// end not breaking a word
			text = [text substringToIndex:limit];
		}
		else {
			// don't break a word
			NSRange range = [text rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, limit)];
			text = [text substringToIndex:range.location];
		}
		if (tail)
			text = [text stringByAppendingString:tail];
	}
	return text;
}

-(NSString *)stringByRemovingCharacterSet:(NSCharacterSet*)characterSet {
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	while (![scanner isAtEnd]) {
		temp = nil;
		[scanner scanUpToCharactersFromSet:characterSet intoString:&temp];
		if (temp) [result appendString:temp];
		if ([scanner scanCharactersFromSet:characterSet intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd])
				[result appendString:@" "];
		}
	}
	scanner = nil;
	NSString *retString = [NSString stringWithString:result];
	result = nil;
	return retString;
}

-(NSString *)stringByRemovingNewLinesAndWhitespace {
	
	// Strange New lines:
	//  Next Line, U+0085
	//  Form Feed, U+000C
	//  Line Separator, U+2028
	//  Paragraph Separator, U+2029
	
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
													  [NSString stringWithFormat:@" \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
	return [self stringByRemovingCharacterSet:newLineAndWhitespaceCharacters];
}

- (NSString *)stringByFirstCharCapital {
	if ([self length] > 0) {
		return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] uppercaseString]];
	}
	return self;
}

- (NSString *)stringByAllWordsFirstCharUpperCase {
	NSArray *words = [self arrayByExplodingWithString:@" "];
	NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
	for (NSString *str in words) {
		if ([str length] > 0) {
			[result appendString:[str stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[str substringToIndex:1] uppercaseString]]];
		}
		[result appendString:@" "];
	}
	[result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
	return result;
}

- (NSString *)stringByDeletingLastWord {
	__block NSRange lastWordRange = NSMakeRange([self length], 0);
    NSStringEnumerationOptions opts = NSStringEnumerationByWords | NSStringEnumerationReverse | NSStringEnumerationSubstringNotRequired;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:opts usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        lastWordRange = substringRange;
        *stop = YES;
    }];
    return [self substringToIndex:lastWordRange.location];
}

- (NSString *)stringByRemovingAccents {
	NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	return newStr;
}

#if TARGET_OS_IPHONE
-(BOOL)excludePathFromBackup {
	NSURL *url = [[NSURL alloc] initFileURLWithPath:self];
	
	if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"5.0.1"]) {
		assert([[NSFileManager defaultManager] fileExistsAtPath: self]);
		
		const char* filePath = [[url path] fileSystemRepresentation];
		
		const char* attrName = "com.apple.MobileBackup";
		u_int8_t attrValue = 1;
		
		int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
		assert(result);
		return result == 0;
	}
	else if (!IOS_VERSION_LESS_THAN(@"5.0.1")) {
		assert([[NSFileManager defaultManager] fileExistsAtPath: self]);
		
		NSError *error = nil;
		BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
									  forKey: NSURLIsExcludedFromBackupKey error: &error];
		if(!success){
			DLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
		}
//		[url release];
		assert(success);
		return success;
	}
	return YES; // ios 5 and earlier can't ignore files from backup, so we just return yes to ignore error alerts.
}
#endif
@end

@implementation NSDate (EPCCategories)
// YYYY-MM-DD HH:MM:SS ±HHMM
- (NSString*)day {
	return [[self description] substringWithRange:NSMakeRange(8, 2)];
}
- (NSString*)hours {
	return [[self description] substringWithRange:NSMakeRange(11, 2)];
}
- (NSString*)minutes {
	return [[self description] substringWithRange:NSMakeRange(14, 2)];
}
- (NSString*)month {
	return [[self description] substringWithRange:NSMakeRange(5, 2)];
}
- (NSString*)seconds {
	return [[self description] substringWithRange:NSMakeRange(17, 2)];
}
- (NSString*)year {
	return [[self description] substringWithRange:NSMakeRange(0, 4)];
}
@end

@implementation NSMutableString (EPCCategories)

- (NSMutableString*)initWithUnknowEncondingAndData:(NSData*)data {
	int e [23];
	e[0] = NSASCIIStringEncoding;
	e[1] = NSUTF8StringEncoding;
	e[2] = NSISOLatin1StringEncoding;
	e[3] = NSISOLatin2StringEncoding;
	e[4] = NSUnicodeStringEncoding;
	e[5] = NSSymbolStringEncoding;
	e[6] = NSNonLossyASCIIStringEncoding;
	e[7] = NSShiftJISStringEncoding;
	e[8] = NSUTF32StringEncoding;
	e[9] = NSUTF16StringEncoding;
	e[10] = NSWindowsCP1251StringEncoding;
	e[11] = NSWindowsCP1252StringEncoding;
	e[12] = NSWindowsCP1253StringEncoding;
	e[13] = NSWindowsCP1254StringEncoding;
	e[14] = NSWindowsCP1250StringEncoding;
	e[15] = NSISO2022JPStringEncoding;
	e[16] = NSMacOSRomanStringEncoding;
	e[17] = NSUTF16BigEndianStringEncoding;
	e[18] = NSUTF32LittleEndianStringEncoding;
	e[19] = NSJapaneseEUCStringEncoding;
	e[20] = NSUTF16LittleEndianStringEncoding;
	e[21] = NSUTF32BigEndianStringEncoding;
	e[22] = NSNEXTSTEPStringEncoding;
	
	NSMutableString *dataString = nil;
	for (int i = 0; i < 23; i++) {
		NSStringEncoding encode = e[i];
		dataString = [self initWithData:data encoding:encode];
		if (dataString) {
			return dataString;
		}
	}
	return nil;
}

@end

@implementation NSNumberFormatter (EPCCategories)
+ (NSString *)stringFromTime:(float)time {
	int minutes = ((int)time)/60.f;
	int seconds = fmodf(time, 60.f);
	int hours = 0;
	if (minutes > 60) {
		hours = (int)(minutes/60.f);
		minutes = fmodf(minutes, 60.f);
	}
	if (hours > 0) {
		return fstr(@"%02d:%02d:%02d", hours, minutes, seconds);
	}
	return fstr(@"%02d:%02d", minutes, seconds);
}
@end

@implementation NSNumber (EPCCategories)
- (NSDecimalNumber*)decimalNumber {
	return [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
}
@end

#if TARGET_OS_IPHONE
@implementation NSNull (EPCCategories)

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    // If NSNull doesn't respond to aSelector, signature will be nil and a new signature for an empty method
    // will be created and returned
    
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if (!signature) {
        // Note: "@:" are (id)self and (SEL)_cmd
        signature = [NSMethodSignature signatureWithObjCTypes:"@:"];
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // Called if NSNull received a message to a non-existent method
	// do nothing and prevent crashes
}
@end
#endif
