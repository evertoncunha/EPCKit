//
//  EPCCategories.h
//
//  Created by Everton Postay Cunha on 25/07/12.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (EPCCategories)
- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;
@end

@interface UIApplication (EPCCategories)
+ (NSString*)documentsDirectoryPath;
+ (NSString*)cacheDirectoryPath;
+ (NSString*)tmpDirectoryPath;
+ (UIViewController*)visibleViewController;
@end

@interface UIColor (EPCCategories)
+ (UIColor*)randomColor;
- (float)brightness;
@end

@interface UILabel (EPCCategories)
@property (nonatomic) CGFloat fontPointSize;
@end

@interface UIImage (EPCCategories)
+ (UIImage*)imageWithContentsOfFileNamed:(NSString*)name; /* this prevents caching the image object */
+ (UIImage*)imageWithContentsOfFileInDocumentsDirectoryNamed:(NSString*)name;
+ (UIImage*)imageWithContentsOfFileInCacheDirectoryNamed:(NSString*)name;
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToWidth:(CGFloat)targetWidth;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
+ (UIImage *)imageNamedA4I:(NSString*)name;
- (UIImage*)resizableWidthImage;
- (UIImage*)resizableHeightImage;
- (UIImage*)resizableImage;
- (UIImage*)replaceColor:(UIColor*)color withTolerance:(float)tolerance;
- (UIColor *)colorAtPoint:(CGPoint)pixelPoint;
- (UIColor *)averageColor;
- (UIColor *)mergedColor;
@end

@interface UIAlertController (EPCCategories)
- (UIView*)superview;
@end

@interface UIView (EPCCategories)
+ (id)loadFromNib;
+ (id)loadFromNibName:(NSString*)nibName;
+ (id)loadFromNibReplacingView:(UIView*)view;
- (BOOL)isAtScreen;
- (void)removeAllSubviews;
- (void)removeAllSubviewsOfClass:(Class)aClass;
- (void)sizeToFitHeight;
- (void)sizeToFitWidth;
@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;
@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;
@end

@interface UIViewController (EPCCategories)
- (IBAction)popViewControllerAnimated;
+ (instancetype)loadFromStoryboard:(NSString*)storyboard;
@end

@interface UIWebView (EPCCategories)
- (void)adjustToHeight;
- (void)disableScroll;
- (UIScrollView*)webScrollView;
- (void)ajustToHeightAndStopBouncing;
@end

@interface UIResponder (EPCCategories)
+ (id)currentFirstResponder;
@end

@interface UIScrollView (EPCCategories)
- (void)scrollToBottomAnimated:(BOOL)animated;
/**
 Fits the contentSize to it's subviews content.
 */
- (void)contentSizeFit;
- (void)contentSizeFitHeight;
- (void)contentSizeFitWidth;
@end

@interface NSFileManager (EPCCategories)
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@end

@interface UICollectionView (EPCCategories)
- (void)changeDataAnimatedFromArray:(NSArray*)fromArray toArray:(NSArray*)toArray;
@end
@interface UITableView (EPCCategories)
- (void)changeDataAnimatedFromArray:(NSArray*)fromArray toArray:(NSArray*)toArray;
+ (void)changeDataFromArray:(NSArray *)oldEntries toArray:(NSArray *)newEntries rowsToDelete:(NSMutableArray*)rowsToDelete rowsToInsert:(NSMutableArray*)rowsToInsert;
- (void)sortTableViewAnimatedFromUnsorted:(NSArray*)unsorted toSorted:(NSArray*)sorted;
@end
@interface UITableViewCell (EPCCategories)
- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor;
@end

@interface NSObject (EPCCategories)
- (id)objectForSelector:(SEL)selector;
- (BOOL)hasEqualPropertiesWith:(NSObject*)obj;
- (NSArray*)propertyNames;
@end

@interface NSUserDefaults (EPCCategories)
+ (BOOL)syncBool:(BOOL)value forKey:(NSString*)key;
+ (BOOL)boolForKey:(NSString*)key;
+ (BOOL)syncObject:(id)object forKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key;
+ (void)clearUserDefaults;
@end

@interface NSArray (EPCCategories)
- (NSArray*)reversedArray;
- (NSArray*)sortedArrayWithKey:(NSString*)property ascending:(BOOL)asc;
- (NSArray*)sortedArrayUsingArray:(NSArray*)otherArray;
- (NSArray *)sortedArrayWithKeys:(NSArray*)keys ascendings:(NSArray*)ascendings;
- (id)firstObjectWithPredicate:(NSPredicate*)predicate;
@end

@interface NSMutableArray (EPCCategories)
- (void)reverse;
- (void)removeNullObjects;
@end

@interface NSSet (EPCCategories)
- (NSArray*)sortedArrayWithKey:(NSString*)property ascending:(BOOL)asc;
@end

@interface NSMutableDictionary (EPCCategories)
- (void)removeNullObjects;
@end

@interface NSDate (EPCCategories)
@property (readonly) NSString *day;
@property (readonly) NSString *hours;
@property (readonly) NSString *minutes;
@property (readonly) NSString *month;
@property (readonly) NSString *seconds;
@property (readonly) NSString *year;
@end

@interface NSString (EPCCategories)
- (NSString*)md5;
- (NSString*)sha1;
- (NSURL*)urlSafe;
- (NSString*)stringByTruncatingToLength:(int)length tail:(NSString*)tail;
- (NSString*)stringByRemovingCharacterSet:(NSCharacterSet*)characterSet;
- (NSString*)stringByRemovingNewLinesAndWhitespace;
- (NSArray*)arrayByExplodingWithString:(NSString*)string;
- (NSString*)phpURLEncoded;
- (NSString*)stringByFirstCharCapital;
- (NSString*)stringByAllWordsFirstCharUpperCase;
- (NSString*)stringByDeletingLastWord;
- (NSString*)decodeHTMLCharacterEntities;
- (NSString*)encodeHTMLCharacterEntities;
- (NSString*)stringByRemovingAccents;
- (NSString*)substringFromLocation:(NSInteger)fromLocation toLocation:(NSInteger)toLocation;
- (NSString*)substringFromRange:(NSRange)fromRange toRange:(NSRange)toRange;
- (NSRange)rangeOfString:(NSString*)string fromRange:(NSRange)range;
- (NSArray*)arrayOfStringsBetweenString:(NSString*)start andString:(NSString*)end;
- (UIColor*)colorFromHexCode;
- (BOOL)excludePathFromBackup;
@end

@interface NSMutableString (EPCCategories)
- (NSMutableString*)initWithUnknowEncondingAndData:(NSData*)data;
@end

@interface NSNumberFormatter (EPCCategories)
+ (NSString*)stringFromTime:(float)time;
@end

@interface NSNumber (EPCCategories)
- (NSDecimalNumber*)decimalNumber;
@end

@interface NSNull (EPCCategories)
@end
