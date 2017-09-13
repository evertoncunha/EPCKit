//
//  EPCGalleryDelegate.h
//
//  Created by Everton Cunha on 15/10/12.
//

#import <Foundation/Foundation.h>

@class EPCGallery;
@protocol EPCGalleryDelegate <NSObject>
@required
- (UIView*)epcGallery:(id)epcGallery viewForPage:(int)page;
- (int)epcGalleryNumberOfPages:(id)epcGallery;
@optional
- (void)epcGallery:(id)epcGallery changedToPage:(int)page;
- (BOOL)epcGallery:(id)epcGallery shouldAdjustFrameForView:(UIView*)view;
- (void)epcGallery:(id)epcGallery willBeginZoomingWithView:(UIView*)view;
- (void)epcGallery:(id)epcGallery didEndZoomingAtScale:(float)scale;
@end