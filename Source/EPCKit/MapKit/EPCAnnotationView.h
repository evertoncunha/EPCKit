//
//  EPCAnnotationView.h
//
//  Created by Everton Postay Cunha on 20/10/16.
//
//

#import <MapKit/MapKit.h>

@class EPCPopoverController;

@interface EPCAnnotationView : MKAnnotationView {
	
	__weak MKMapView
	*_mapView;
	
	EPCPopoverController
	*_popOver;
	
	NSDate
	*_dateDismissed;
	
	BOOL
	_isPresentingPopOver;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier pinView:(UIView *)pinView calloutView:(UIView *)calloutView mapView:(MKMapView*)mapView ;

- (void)showCalloutView;

@property(nonatomic) UIView *pinView;

@property(nonatomic) UIView *calloutView;

@end
