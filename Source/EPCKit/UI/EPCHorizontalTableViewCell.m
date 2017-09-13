//
//  EPCHorizontalTableViewCell.m
//
//  Created by Everton Cunha on 19/10/12.
//

#import "EPCHorizontalTableViewCell.h"

@implementation EPCHorizontalTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    assert([aDecoder isKindOfClass:[NSCoder class]]);
	
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
        CGFloat k90DegreesClockwiseAngle = (CGFloat) (90 * M_PI / 180.0);
		
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k90DegreesClockwiseAngle);
    }
	
    assert(self);
    return self;
}

@end
