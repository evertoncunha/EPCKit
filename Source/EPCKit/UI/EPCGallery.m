//
//  EPCGallery
//
//  Created by Everton Cunha on 23/07/12.
//

#import "EPCGallery.h"

#define TAG_DELIMITER 10

@interface EPCGallery () {
	UIScrollView *pvtScrollView;
	UIView *zoomingView;
	UITapGestureRecognizer *doubleTapGesture;
	int numberOfPages;
}
@end

@implementation EPCGallery

@synthesize autoUnload, autoUnloadLimit;
@synthesize maximumZoomScale, minimumZoomScale;
@synthesize loadLimit, unloadLimit, delegate;
@synthesize doubleTapToZoom;

#pragma mark - Default

- (void)dealloc
{
    self.delegate = nil;
	pvtScrollView.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self start];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        [self start];
    }
    return self;
}
- (void)awakeFromNib {
	[super awakeFromNib];
	[self start];
}

- (void)start {
	if (self.unloadLimit == 0)
		self.unloadLimit = 1;
	if (self.loadLimit == 0)
		self.loadLimit = 2;
	if (self.autoUnloadLimit == 0)
		self.autoUnloadLimit = 7;
	if (minimumZoomScale == 0)
		minimumZoomScale = 1;
	if (maximumZoomScale == 0)
		maximumZoomScale = 1;
	
	pvtScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	pvtScrollView.pagingEnabled = YES;
	pvtScrollView.delegate = self;
	pvtScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	pvtScrollView.showsHorizontalScrollIndicator = pvtScrollView.showsVerticalScrollIndicator = NO;
	numberOfPages = [self.delegate epcGalleryNumberOfPages:self];
	[pvtScrollView setContentSize:CGSizeMake(numberOfPages*pvtScrollView.frame.size.width, pvtScrollView.frame.size.height)];
	pvtScrollView.maximumZoomScale = maximumZoomScale;
	pvtScrollView.minimumZoomScale = minimumZoomScale;
	[self insertSubview:pvtScrollView atIndex:0];
	
	if (numberOfPages > 0)
		[self loadContentsForPage:0];
	
	self.doubleTapToZoom = doubleTapToZoom;
}

#pragma mark - Loading Views

- (void)loadContentsForPage:(int)page {
	if (!zoomingView && page < numberOfPages) {
		UIView *view = [self requestViewForPage:page];
		if (view)
			[pvtScrollView addSubview:view];
		
		if (numberOfPages > 1)
			[self performSelectorInBackground:@selector(loadContentsForPageThread:) withObject:[NSNumber numberWithInt:page]];
	}
}

- (void)loadContentsForPageThread:(NSNumber*)pageObj {
	
	int page = [pageObj intValue];
	
	// Auto Load
	
	int pageBefore = page - 1;
	int pageAfter = page + 1;
	
	NSMutableArray *viewsToAdd = [NSMutableArray arrayWithCapacity:(pageAfter - page) + (page - pageBefore)];
	
	while (pageBefore >= page - self.loadLimit) {
		if (pageBefore >= 1) {
			UIView *view = [self requestViewForPage:pageBefore];
			if (view) {
				[viewsToAdd addObject:view];
			}
		}
		pageBefore--;
	}
	
	while (pageAfter <= page + self.loadLimit && pageAfter < numberOfPages) {
		
		UIView *view = [self requestViewForPage:pageAfter];
		if (view) {
			[viewsToAdd addObject:view];
		}
		
		pageAfter++;
	}
	
	[self performSelectorOnMainThread:@selector(addSubviews:) withObject:viewsToAdd waitUntilDone:YES];
	
	// Auto Unload
	
	if (self.autoUnload) {
		[self unloadWithPage:page isAutoUnload:YES];
	}
	
}

- (void)addSubviews:(NSArray*)viewsToAdd {
	for (UIView *view in viewsToAdd) {
		if (![pvtScrollView viewWithTag:view.tag] && view != zoomingView) {
			[pvtScrollView insertSubview:view atIndex:0];
		}
	}
}

- (int)pageOfView:(UIView *)view {
	if (view.tag < TAG_DELIMITER || view.tag - TAG_DELIMITER > numberOfPages)
		return NSNotFound;
	return view.tag - TAG_DELIMITER;
}

- (UIView*)requestViewForPage:(int)page {
	
	int tag = TAG_DELIMITER+page;
	
	@synchronized(pvtScrollView) {
		NSArray *subviews = [NSArray arrayWithArray:pvtScrollView.subviews];
		for (UIView *v in subviews) {
			if (v.tag == tag)
				return nil;
		}
	}
	
	UIView *view = [self.delegate epcGallery:self viewForPage:page];
	
	if (!view)
		return nil;
	
	view.tag = tag;
	
	if ([self.delegate respondsToSelector:@selector(epcGallery:shouldAdjustFrameForView:)])
		if (![self.delegate epcGallery:self shouldAdjustFrameForView:view])
			return view;
	
	CGRect fra = pvtScrollView.bounds;
	fra.origin.x = page*fra.size.width;
	view.frame = fra;
	
	return view;
}

-(UIView *)viewForPage:(int)page shouldAskDelegate:(BOOL)ask {
	UIView* view = [pvtScrollView viewWithTag:TAG_DELIMITER+page];
	if (!view && ask)
		view = [self requestViewForPage:page];
	return view;
}

-(void)reload {
	pvtScrollView.userInteractionEnabled = NO;
	zoomingView = nil;
	
	[self unload];
	
	numberOfPages = [self.delegate epcGalleryNumberOfPages:self];
	[pvtScrollView setContentSize:CGSizeMake(numberOfPages*pvtScrollView.frame.size.width, pvtScrollView.frame.size.height)];
	if (numberOfPages > 0)
		[self loadContentsForPage:self.currentPage];
	pvtScrollView.userInteractionEnabled = YES;
}

#pragma mark - Unloading Views

-(void)unload {
	pvtScrollView.userInteractionEnabled = NO;
	zoomingView = nil;
	@synchronized(pvtScrollView) {
		NSArray *subviews = [NSArray arrayWithArray:pvtScrollView.subviews];
		for (UIView *view in subviews) {
			if (view.tag >= TAG_DELIMITER)
				[view removeFromSuperview];
		}
	}
	numberOfPages = [self.delegate epcGalleryNumberOfPages:self];
	[pvtScrollView setContentSize:CGSizeMake(numberOfPages*pvtScrollView.frame.size.width, pvtScrollView.frame.size.height)];
	pvtScrollView.userInteractionEnabled = YES;
}

- (void)unloadAllButNearPages {
	CGFloat pageWidth = pvtScrollView.frame.size.width;
    int page = floor((pvtScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self performSelectorInBackground:@selector(unloadAllButNearPagesThread:) withObject:[NSNumber numberWithInt:page]];
}

- (void)unloadAllButNearPagesThread:(NSNumber*)pageObj {
	int page = [pageObj integerValue];
	[self unloadWithPage:page isAutoUnload:NO];
}

- (void)unloadWithPage:(int)page isAutoUnload:(BOOL)isAutoUnload {
	
	int limit = self.unloadLimit;
	if (isAutoUnload)
		limit = self.autoUnloadLimit;
	
	int pageMinTag = page - limit + TAG_DELIMITER;
	int pageMaxTag = page + limit + TAG_DELIMITER;
	
	@synchronized(pvtScrollView) {
		NSArray *subviews = [NSArray arrayWithArray:pvtScrollView.subviews];
		for (UIView *view in subviews) {
			if (view.tag >= TAG_DELIMITER) { // exclude private subviews
				if (view.tag < pageMinTag || view.tag > pageMaxTag) {
					[view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
				}
			}
		}
	}
}

#pragma mark - ScrollView


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (!zoomingView) {
		int page = self.currentPage;
		[self loadContentsForPage:page];
		if ([self.delegate respondsToSelector:@selector(epcGallery:changedToPage:)])
			[self.delegate epcGallery:self changedToPage:page];
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self scrollViewDidEndDecelerating:scrollView];
	}
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)_scrollView {
	[self scrollViewDidEndDecelerating:_scrollView];
}


#pragma mark - Zooming

-(void)setMaximumZoomScale:(float)max {
	maximumZoomScale = max;
	pvtScrollView.maximumZoomScale = maximumZoomScale;
}

-(void)setMinimumZoomScale:(float)min {
	minimumZoomScale = min;
	pvtScrollView.minimumZoomScale = min;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if (!zoomingView) {
		zoomingView = [self viewForPage:self.currentPage shouldAskDelegate:YES];
		if (!zoomingView.superview)
			[pvtScrollView addSubview:zoomingView];
		else
			[pvtScrollView bringSubviewToFront:zoomingView];
		
		@synchronized(pvtScrollView) {
			NSArray *subviews = [NSArray arrayWithArray:scrollView.subviews];
			for (UIView *sub in subviews)
				sub.hidden = (sub != zoomingView);
		}
	}
	return zoomingView;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	scrollView.pagingEnabled = NO;
	scrollView.userInteractionEnabled = NO;
	if ([self.delegate respondsToSelector:@selector(epcGallery:willBeginZoomingWithView:)])
		[self.delegate epcGallery:self willBeginZoomingWithView:view];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	if (scale == 1.0f) {
		scrollView.pagingEnabled = YES;
		numberOfPages = [self.delegate epcGalleryNumberOfPages:self];
		[scrollView setContentSize:CGSizeMake(numberOfPages*pvtScrollView.frame.size.width, scrollView.frame.size.height)];
		@synchronized(pvtScrollView) {
			NSArray *subviews = [NSArray arrayWithArray:scrollView.subviews];
			for (UIView *sub in subviews)
				sub.hidden = NO;
		}
		
		CGRect fra = zoomingView.frame;
		fra.origin.x = (zoomingView.tag - TAG_DELIMITER)*scrollView.frame.size.width;
		zoomingView.frame = fra;
		[scrollView setContentOffset:fra.origin animated:NO];
		zoomingView = nil;
	}
	scrollView.userInteractionEnabled = YES;
	
	if ([self.delegate respondsToSelector:@selector(epcGallery:didEndZoomingAtScale:)])
		[self.delegate epcGallery:self didEndZoomingAtScale:scale];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	zoomingView.frame = [self centeredFrameForScrollView:scrollView andUIView:zoomingView];;
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
	CGSize boundsSize = scroll.bounds.size;
	CGRect frameToCenter = rView.frame;
	// center horizontally
	if (frameToCenter.size.width < boundsSize.width) {
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
	}
	else {
		frameToCenter.origin.x = 0;
	}
	// center vertically
	if (frameToCenter.size.height < boundsSize.height) {
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
	}
	else {
		frameToCenter.origin.y = 0;
	}
	return frameToCenter;
}

-(void)setDoubleTapToZoom:(BOOL)flag {
	doubleTapToZoom = flag;
	if (doubleTapToZoom && !doubleTapGesture && pvtScrollView) {
		doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		[doubleTapGesture setNumberOfTapsRequired:2];
		[pvtScrollView addGestureRecognizer:doubleTapGesture];
	}
	else if (!doubleTapToZoom && doubleTapGesture && pvtScrollView) {
		[pvtScrollView removeGestureRecognizer:doubleTapGesture];
		doubleTapGesture = nil;
	}
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	if (numberOfPages > 0) {
		if(pvtScrollView.zoomScale > pvtScrollView.minimumZoomScale)
			[pvtScrollView setZoomScale:pvtScrollView.minimumZoomScale animated:YES];
		else
			[pvtScrollView setZoomScale:pvtScrollView.maximumZoomScale animated:YES];
	}
}

#pragma mark - Others

-(int)currentPage {
	CGFloat pageWidth = pvtScrollView.frame.size.width;
    int page = floor((pvtScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	return page;
}

-(void)scrollToPage:(int)page animated:(BOOL)animated loadingNear:(BOOL)loadingNear {
	
	if (loadingNear)
		[self loadContentsForPage:page];
	else {
		UIView *view = [self requestViewForPage:page];
		if (view)
			[pvtScrollView addSubview:view];
	}
	
	[pvtScrollView setContentOffset:CGPointMake(page*pvtScrollView.bounds.size.width, 0) animated:animated];
}

-(UIScrollView*)scrollView {
	return pvtScrollView;
}

-(void)refreshContentSize {
	if (!zoomingView) {
		numberOfPages = [self.delegate epcGalleryNumberOfPages:self];
		[pvtScrollView setContentSize:CGSizeMake(numberOfPages*pvtScrollView.frame.size.width, pvtScrollView.frame.size.height)];
	}
}

@end