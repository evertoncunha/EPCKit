//
//  EPCLabelAlignedTop.m
//
//  Created by Everton Cunha on 05/11/12.
//

#import "EPCLabelAlignedTop.h"

@interface EPCLabelAlignedTop() {
	CGSize _originalSize;
}
@end

@implementation EPCLabelAlignedTop

- (void)awakeFromNib {
	[super awakeFromNib];
	_originalSize = self.frame.size;
}

- (void)setText:(NSString *)text {
	[super setText:text];
	CGRect newFrame = self.frame;
	newFrame.size = [self sizeThatFits:_originalSize];

	if (newFrame.size.height > _originalSize.height) {
		newFrame.size.height = _originalSize.height;
	}
	if (newFrame.size.width > _originalSize.width) {
		newFrame.size.width = _originalSize.width;
	}
	self.frame = newFrame;
}

@end
