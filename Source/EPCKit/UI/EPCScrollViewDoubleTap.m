//
//  EPCScrollViewDoubleTap.m
//
//  Created by Everton Cunha on 15/10/12.
//

#import "EPCScrollViewDoubleTap.h"

@interface EPCScrollViewDoubleTap() {
	UITapGestureRecognizer *_doubleTapGesture;
}
@end

@implementation EPCScrollViewDoubleTap
@synthesize doubleTapToZoom = _doubleTapToZoom;
- (void)dealloc
{
    self.doubleTapToZoom = NO;
	self.delegate = nil;
}
- (BOOL)doubleTapToZoom {
	return _doubleTapToZoom;
}
-(void)setDoubleTapToZoom:(BOOL)flag {
	_doubleTapToZoom = flag;
	if (_doubleTapToZoom && !_doubleTapGesture) {
		_doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		[_doubleTapGesture setNumberOfTapsRequired:2];
		[self addGestureRecognizer:_doubleTapGesture];
	}
	else if (!_doubleTapToZoom && _doubleTapGesture) {
		[self removeGestureRecognizer:_doubleTapGesture];
		_doubleTapGesture = nil;
	}
}
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	if(self.zoomScale > self.minimumZoomScale)
		[self setZoomScale:self.minimumZoomScale animated:YES];
	else {
		[self setZoomScale:self.maximumZoomScale animated:YES];
	}
}
@end
