//
//  EPCHorizontalTableView.m
//
//  Created by Everton Cunha on 19/10/12.
//

#import "EPCHorizontalTableView.h"

@implementation EPCHorizontalTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    assert([aDecoder isKindOfClass:[NSCoder class]]);
	
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
        const CGFloat k90DegreesCounterClockwiseAngle = (CGFloat) -(90 * M_PI / 180.0);
		
        CGRect frame = self.frame;
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k90DegreesCounterClockwiseAngle);
        self.frame = frame;
		
    }
    assert(self);
    return self;
}

@end
