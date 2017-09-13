//
//  EPCGalleryTweaked.m
//
//  Created by Everton Cunha on 23/07/12.
//

#import "EPCGalleryTweaked.h"
#import "EPCScrollViewDoubleTap.h"

#define TAG_DELIMITER 10

@interface EPCGalleryTweaked () {
	UIScrollView *pvtScrollView;
	UIView *zoomingView;
	int numberOfPages;
	BOOL _zoomIsEnabled;
}
@end

@implementation EPCGalleryTweaked

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
	
	self.autoUnload = YES;
	
	self.doubleTapToZoom = doubleTapToZoom;
	
	pvtScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	pvtScrollView.pagingEnabled = YES;
	pvtScrollView.delegate = self;
	pvtScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin;
	pvtScrollView.showsHorizontalScrollIndicator = pvtScrollView.showsVerticalScrollIndicator = NO;
	numberOfPages = [self.delegate epcGalleryNumberOfPages:self];
	[pvtScrollView setContentSize:CGSizeMake(numberOfPages*pvtScrollView.frame.size.width, pvtScrollView.frame.size.height)];
	
	[self insertSubview:pvtScrollView atIndex:0];
	
	if (numberOfPages > 0)
		[self loadContentsForPage:0];
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
	
	EPCScrollViewDoubleTap *sv = nil;
	
	if (_zoomIsEnabled) {
		sv = [[EPCScrollViewDoubleTap alloc] initWithFrame:self.frame];
		[sv addSubview:view];
		sv.maximumZoomScale = maximumZoomScale;
		sv.minimumZoomScale = minimumZoomScale;
		sv.delegate = self;
		sv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		if (doubleTapToZoom) {
			sv.doubleTapToZoom = YES;
		}
		sv.showsHorizontalScrollIndicator = NO;
		sv.showsVerticalScrollIndicator = NO;
	}
	
	sv.tag = tag;
	view.tag = tag;
	
	if ([self.delegate respondsToSelector:@selector(epcGallery:shouldAdjustFrameForView:)]) {
		if (![self.delegate epcGallery:self shouldAdjustFrameForView:view]) {
			if (sv) {
				return sv;
			}
			return view;
		}
	}
	
	CGRect fra = pvtScrollView.bounds;
	fra.origin.x = page*fra.size.width;
	
	if (sv) {
		sv.frame = fra;
		return sv;
	}
	
	view.frame = fra;
	
	return view;
}

-(UIView *)viewForPage:(int)page shouldAskDelegate:(BOOL)ask {
	UIView* view = [pvtScrollView viewWithTag:TAG_DELIMITER+page];
	if (!view && ask)
		view = [self requestViewForPage:page];
	if ([view isKindOfClass:[EPCScrollViewDoubleTap class]]) {
		view = [[view subviews] objectAtIndex:0];
	}
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

- (void)reset {
	[self unload];
	[pvtScrollView setContentOffset:CGPointZero animated:NO];
	[self reload];
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
	if (scrollView == pvtScrollView) {
		if (!zoomingView) {
			int page = self.currentPage;
			[self loadContentsForPage:page];
			if ([self.delegate respondsToSelector:@selector(epcGallery:changedToPage:)])
				[self.delegate epcGallery:self changedToPage:page];
		}
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (scrollView == pvtScrollView) {
		if (!decelerate) {
			[self scrollViewDidEndDecelerating:scrollView];
		}
	}
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (scrollView == pvtScrollView) {
		[self scrollViewDidEndDecelerating:scrollView];
	}
}


#pragma mark - Zooming

-(void)setMaximumZoomScale:(float)max {
	maximumZoomScale = max;
	assert(numberOfPages == 0);
	_zoomIsEnabled = (minimumZoomScale != 1 || maximumZoomScale != 1);
}

-(void)setMinimumZoomScale:(float)min {
	minimumZoomScale = min;
	assert(numberOfPages == 0);
	_zoomIsEnabled = (minimumZoomScale != 1 || maximumZoomScale != 1);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if (!zoomingView) {
		zoomingView = [self viewForPage:self.currentPage shouldAskDelegate:YES];
		if (!zoomingView.superview) {
			[scrollView addSubview:zoomingView];
		}
	}
	return zoomingView;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	if (pvtScrollView.scrollEnabled) {
		pvtScrollView.scrollEnabled = NO;
		if ([self.delegate respondsToSelector:@selector(epcGallery:willBeginZoomingWithView:)])
			[self.delegate epcGallery:self willBeginZoomingWithView:view];
	}
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	if (scale == 1.0f) {
		pvtScrollView.scrollEnabled = YES;
		zoomingView = nil;
		if ([self.delegate respondsToSelector:@selector(epcGallery:didEndZoomingAtScale:)])
			[self.delegate epcGallery:self didEndZoomingAtScale:scale];
	}
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
	assert(numberOfPages == 0);
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