//
//  EPCButton.h
//
//  Created by Everton Postay Cunha on 16/07/12.
//

#import <UIKit/UIKit.h>

@class EPCImageView;

@interface EPCButton : UIControl {
}

@property (nonatomic, retain) id dataObject;
@property (nonatomic, readonly) EPCImageView *epcImageView;
@end
