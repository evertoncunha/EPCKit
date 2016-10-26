//
//  EPCMapKitCategories.h
//
//  Created by Everton Cunha on 14/08/12.
//

#import <MapKit/MapKit.h>

@interface MKMapView (EPCMapKitCategories)

- (void)zoomToFitMapAnnotationsAnimated:(BOOL)animated;

- (void)zoomToUserLocationAnimated:(BOOL)animated;

- (BOOL)zoomOutToMapAnnotations:(int)numberOfMapAnnotations animated:(BOOL)animated;

- (MKMapRect)mapRectForRect:(CGRect)rect toCoordinateFromView:(UIView*)view;

- (NSArray*)annotationsExceptUserLocation;

- (NSArray*)annotationsThatArentInMapView:(NSArray*)annots;

@end
