//
//  EPCMapKitCategories.m
//
//  Created by Everton Cunha on 14/08/12.
//

#import "EPCMapKitCategories.h"
#import "EPCDefines.h"

@implementation MKMapView (EPCMapKitCategories)
-(void)zoomToFitMapAnnotationsAnimated:(BOOL)animated
{
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in self.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
}
- (void)zoomToUserLocationAnimated:(BOOL)animated {
	if (self.userLocation) {
		MKCoordinateRegion region;
		region.span = MKCoordinateSpanMake(0.05, 0.05);
		region.center = self.userLocation.coordinate;
		
		if (region.center.latitude != -180.0f) {
			region = [self regionThatFits:region];
			[self setRegion:region animated:animated];
		}
	}
}
- (BOOL)zoomOutToMapAnnotations:(int)numberOfMapAnnotations animated:(BOOL)animated {
	
	if (numberOfMapAnnotations > [self.annotations count]) {
		numberOfMapAnnotations = (int)[self.annotations count];
	}
	
	NSSet *set = [self annotationsInMapRect:self.visibleMapRect];
	
	if ([set count] >= numberOfMapAnnotations)
		return NO;
	
	MKCoordinateRegion region;
	region.span = MKCoordinateSpanMake(0.05, 0.05);
	region.center = self.region.center;
	
	CGRect rect = [self convertRegion:region toRectToView:self];
	MKMapRect mapRect = [self mapRectForRect:rect toCoordinateFromView:self];
	
	set = [self annotationsInMapRect:mapRect];
	
	while ([set count] < numberOfMapAnnotations) {
		
		region.span = MKCoordinateSpanMake(region.span.latitudeDelta*2, region.span.longitudeDelta*2);
		
		rect = [self convertRegion:region toRectToView:self];
		mapRect = [self mapRectForRect:rect toCoordinateFromView:self];
		
		set = [self annotationsInMapRect:mapRect];
	}
	
	region.span = MKCoordinateSpanMake(region.span.latitudeDelta*1.1, region.span.longitudeDelta*1.1);
	region = [self regionThatFits:region];
	[self setRegion:region animated:animated];
	
	return YES;
}

- (MKMapRect)mapRectForRect:(CGRect)rect toCoordinateFromView:(UIView *)view
{
    CLLocationCoordinate2D topleft = [self convertPoint:CGPointMake(rect.origin.x, rect.origin.y) toCoordinateFromView:view];
    CLLocationCoordinate2D bottomeright = [self convertPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)) toCoordinateFromView:view];
    MKMapPoint topleftpoint = MKMapPointForCoordinate(topleft);
    MKMapPoint bottomrightpoint = MKMapPointForCoordinate(bottomeright);
	
    return MKMapRectMake(topleftpoint.x, topleftpoint.y, bottomrightpoint.x - topleftpoint.x, bottomrightpoint.y - topleftpoint.y);
}
-(NSArray *)annotationsExceptUserLocation {
	return [[self annotations] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (class == %@)", [MKUserLocation class]]];
}
- (NSArray*)annotationsThatArentInMapView:(NSArray*)annots {
	return [annots filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.annotations]];
}
@end
