//
//  EPCLabel.h
//
//  Created by Everton Postay Cunha on 8/31/11.
//

#import <UIKit/UIKit.h>

@interface EPCLabel : UILabel {
	float originalPointSize;
	CGSize originalSize;
}
@property (nonatomic, readwrite) BOOL alignTextOnTop;

-(void)verticalAlignTop;

@end