//
//  EPCStrechableUIButton.m
//
//  Created by Everton Postay Cunha on 8/30/11.
//

#import "EPCStretchableUIButton.h"

@implementation EPCStretchableUIButton

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
	self = [super awakeAfterUsingCoder:aDecoder];
	if (self) {
		[[self class] applyStretchOnButton:self];
	}
	return self;
}

- (void)setBackgroundImage:(UIImage*)img forState:(UIControlState)state {
	int w = img.size.width/2;
	int h = img.size.height/2;
	img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(h-1, w-1, h, w)];
	[super setBackgroundImage:img forState:state];
}

+ (void)applyStretchOnButton:(UIButton *)button {
	UIImage *img = [button backgroundImageForState:UIControlStateNormal];
	
	if (img)
		[button setBackgroundImage:img forState:UIControlStateNormal];
	
	UIImage *t = [button backgroundImageForState:UIControlStateHighlighted];
	
	if (img != t) {
		img = t;
		[button setBackgroundImage:img forState:UIControlStateHighlighted];
	}
	
	t = [button backgroundImageForState:UIControlStateSelected];
	if (img != t) {
		img = t;
		[button setBackgroundImage:img forState:UIControlStateSelected];
	}
	
	t = [button backgroundImageForState:UIControlStateDisabled];
	if (img != t) {
		img = t;
		[button setBackgroundImage:img forState:UIControlStateDisabled];
	}
}

@end
