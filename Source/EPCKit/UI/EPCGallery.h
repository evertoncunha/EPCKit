//
//  EPCGallery.h
//
//  Created by Everton Postay Cunha on 23/07/12.
//

/*
 EPCGallery works using the UIView tag property. Please don't change the views tags.
 */

#import <UIKit/UIKit.h>
#import "EPCGalleryDelegate.h"

@interface EPCGallery : UIView <UIScrollViewDelegate>

/*
 Loads the given page and the near pages according to loadLimit.
 */
- (void)loadContentsForPage:(int)page;

/*
 Returns the page number of a given view. NSNotFound it not found.
 */
- (int)pageOfView:(UIView*)view;

/*
 Recalculates the content size.
 */
- (void)refreshContentSize;

/*
 Remove all views and loads the current and loadLimit.
 */
- (void)reload;

/*
 Scrolls to a page. LoadingNear loads more views according to loadLimit.
 If EPCGallery is being animated, setting loadingNear to YES can glitch the animation.
 */
- (void)scrollToPage:(int)page animated:(BOOL)animated loadingNear:(BOOL)loadingNear;

/*
 Remove all views;
 */
- (void)unload;

/*
 Unload not visible pages according to unloadLimit to clear memory.
 */
- (void)unloadAllButNearPages;

/*
 If available returns the view for the given page, it can return nil or ask delegate for the view.
 */
- (UIView*)viewForPage:(int)page shouldAskDelegate:(BOOL)ask;

/*
 Automatically unload far pages. Default is NO.
 */
@property (nonatomic, readwrite) BOOL autoUnload;

/*
 Same as unloadLimit, but fot autoUnload. Default is 7.
 */
@property (nonatomic, readwrite) int autoUnloadLimit;

/*
 The visible page number. 0-n.
 */
@property (nonatomic, readonly) int currentPage;

/*
 The delegate.
 */
@property (nonatomic, assign) IBOutlet id<EPCGalleryDelegate> delegate;

/*
 Enables/disables double tap to zoom. Default is NO.
 */
@property (nonatomic, readwrite) BOOL doubleTapToZoom;

/*
 loadLimit = 2 (default) -> Will load 2 pages before and 2 pages after the current one.
 */
@property (nonatomic, readwrite) int loadLimit;

/*
 unloadLimit = 1 (default) -> Will unload all pages but current, 1 before and 1 after.
 */
@property (nonatomic, readwrite) int unloadLimit;

/*
 Enables Zooming.
 */
@property (nonatomic, readwrite) float maximumZoomScale, minimumZoomScale;

/*
 The private UIScrollView. Use for debugging and don't mess with it.
 */
@property (nonatomic, readonly) UIScrollView *scrollView;

@end
