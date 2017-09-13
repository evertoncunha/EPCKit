//
//  EPCStretchableUIImageView.m
//
//  Created by Everton Postay Cunha on 8/15/11.
//

#import "EPCStretchableUIImageView.h"

@implementation EPCStretchableUIImageView

-(void)awakeFromNib {
	[super awakeFromNib];
	
	UIImage *img = [self image];
	if (img)
		[self setImage:img];
}

- (void)setImage:(UIImage*)img{
	[self setContentMode:UIViewContentModeScaleToFill];
	int w = img.size.width/2;
	int h = img.size.height/2;
	[super setImage:[img stretchableImageWithLeftCapWidth:w topCapHeight:h]];
}

@end
