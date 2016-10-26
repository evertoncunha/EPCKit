//
//  EPCImageView.h
//
//  Created by Everton Postay Cunha on 15/05/12.
//

#import <UIKit/UIKit.h>

typedef void (^EPCImageViewTransitionBetweenImagesAnimation)(UIImage *fromImage);

@class EPCImageView;
@protocol EPCImageViewDelegate <NSObject>
@optional

/*
 isFromCache can either be from EPCImageView cache or because you gave an UIImage in epcImageView:imageForURL:.
 */
- (void)epcImageView:(EPCImageView*)epcImageView isShowingImage:(UIImage*)image fromURL:(NSURL*)url isFromCache:(BOOL)isFromCache;

/*
 When NSData is completely received from a request.
 */
- (void)epcImageView:(EPCImageView*)epcImageView receivedImageData:(NSData*)imageData fromURL:(NSURL*)url;

/*
 When EPCImageView fails to load given URL.
 */
- (void)epcImageView:(EPCImageView*)epcImageView failedLoadingURL:(NSURL*)url;

/*
 When a internet request will start.
 */
- (void)epcImageView:(EPCImageView*)epcImageView willStartRequestForURL:(NSURL*)url;

/*
 When the internet request finishes.
 */
- (void)epcImageView:(EPCImageView*)epcImageView finishedRequestForURL:(NSURL *)url;

/*
 You can provide an UIImage for a given URL. This will be handle as cache and will prevent the request.
 */
- (UIImage*)epcImageView:(EPCImageView*)epcImageView imageForURL:(NSURL*)url;

/*
 If EPCImageView should handle given URL, or ignore.
 */
- (BOOL)epcImageView:(EPCImageView*)epcImageView shouldHandleImageForURL:(NSURL*)url;

@end


@interface EPCImageView : UIImageView

/*
 Default singleton to cache the downloaded images.
 */
+ (NSCache*)imageCache;

/*
 Returns existing chached image for a givin URL or nil if there is none.
 */
- (UIImage*)cachedImageForURL:(NSURL*)url;

/*
 Cancel the request without calling delegates.
 */
- (void)cancel;

/*
 Retry last URL.
 */
- (BOOL)retry;

/*
 Set the URL from the image to be loaded. Set to nil when you want to clear the current image.
 */
- (void)setImageByURL:(NSURL*)url;

/*
 When you don't want to load a image by an URL, but you want everything else. Use this only if all images are local.
 */
- (void)loadImageWithoutURL;

/*
 The UIActivityIndicatorView style.
 */
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

/*
 The UIActivityIndicatorView color.
 */
@property (nonatomic, strong) UIColor *activityIndicatorViewColor;

/*
 Custom ActivityIndicatorView if necessary.
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

/*
 The delegate.
 */
@property (nonatomic, weak) IBOutlet id<EPCImageViewDelegate> delegate;

/*
 You can set your own cache. It also should work with NSMutableDictionary.
 */
@property (nonatomic, weak) NSCache *imageCache;

/*
 The image URL.
 */
@property (nonatomic, readonly) NSURL *imageURL;

/*
 Returns if is currently requesting an image.
 */
@property (nonatomic, readonly) BOOL isRequesting;

/*
 Set YES to prevent UIActivityIndicatorView allocation.
 */
@property (nonatomic, readwrite) BOOL hideActivityIndicator;

/*
 Caches images. Default is NO, caching images.
 */
@property (nonatomic, readwrite) BOOL dontCachesImages;

/*
 Animate transition between image that is currently presented and the new image that has been requested, after it has been loaded.
 */
@property (nonatomic, readwrite) BOOL transitionBetweenImages;

/*
 Customize transition between images animation.
 */
@property (nonatomic, copy)  EPCImageViewTransitionBetweenImagesAnimation transitionBetweenImagesAnimation;

@end