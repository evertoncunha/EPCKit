//
//  EPCAnnotationView.m
//
//
//  Created by Everton Postay Cunha on 20/10/16.
//
//

#import "EPCAnnotationView.h"
#import "EPCPopOverController.h"

@interface EPCAnnotationView () {
	
}

@end

@implementation EPCAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier pinView:(UIView *)pinView calloutView:(UIView *)calloutView mapView:(MKMapView*)mapView {

    NSAssert(pinView != nil, @"Pinview can not be nil");
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = NO;
        self.canShowCallout = NO;

        self.pinView = pinView;
        self.pinView.userInteractionEnabled = YES;
        self.calloutView = calloutView;
		_mapView = mapView;

        [self addSubview:self.pinView];
        self.frame = [self calculateFrame];
        [self positionSubviews];
    }
    return self;
}

- (CGRect)calculateFrame {
    return self.pinView.bounds;
}

- (void)positionSubviews {
    self.pinView.center = self.center;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (_popOver) {
		[_popOver dismissPopoverAnimated:YES];
		_popOver = nil;
	}
	else if (!_isPresentingPopOver) {
		
		UITouch *touch = [touches anyObject];
		
		if(touch.view == self.pinView) {
			[self showCalloutView];
		}
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	[_popOver dismissPopoverAnimated:YES];
	_popOver = nil;
	
	return [super hitTest:point withEvent:event];
}

- (void)showCalloutView {
	
	EPCPopoverController *pop = [[EPCPopoverController alloc] initWithView:self.calloutView];

	if(_mapView) {
		pop.passthroughViews = @[_mapView];
	}
	_isPresentingPopOver = YES;
	[pop presentInWindowRootViewControllerFromView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	_popOver = pop;
	[pop setDidDismissPopoverBlock:^{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			_isPresentingPopOver = NO;
		});
	}];
}


#pragma mark - PinView

- (void)setPinView:(UIView *)pinView {
    //Removing old pinView
    [_pinView removeFromSuperview];
    
    //Adding new pinView to the view's hierachy
    _pinView = pinView;
    [self addSubview:_pinView];
    
    //Position the new pinView
    self.frame = [self calculateFrame];
    self.pinView.center = self.center;
}

@end
