//
//  EPCStrechableUITextField.m
//
//  Created by Everton Postay Cunha on 8/15/11.
//

#import "EPCStrechableUITextField.h"

@implementation EPCStrechableUITextField

-(void)awakeFromNib {
	[super awakeFromNib];
	
	UIImage *img = [self background];
	if (img)
		[self setBackground:img];
}

- (void)setBackground:(UIImage*)img{
	int w = img.size.width/2;
	int h = img.size.height;
	[super setBackground:[img stretchableImageWithLeftCapWidth:w topCapHeight:h]];
}

@end
