//
//  EPCButton.m
//
//  Created by Everton Postay Cunha on 16/07/12.
//

#import "EPCButton.h"
#import "EPCImageView.h"

@implementation EPCButton
@synthesize dataObject, epcImageView;

- (void)dealloc
{
    self.dataObject = nil;
	epcImageView.delegate = nil;
}

- (EPCImageView *)epcImageView {
	if (!epcImageView) {
		epcImageView = [[EPCImageView alloc] initWithFrame:self.bounds];
		epcImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self insertSubview:epcImageView atIndex:0];
	}
	return epcImageView;
}

-(void)setHighlighted:(BOOL)highlighted {

	if (highlighted == self.highlighted || self.selected) {
		return;
	}
	[super setHighlighted:highlighted];
	
	if (self.highlighted) {
		self.alpha = 0.5;
	}
	else {
		self.alpha = 1;
	}
}

-(void)setSelected:(BOOL)selected {
	if (selected == self.selected) {
		return;
	}
	[super setSelected:selected];
	
	if (self.selected) {
		self.alpha = 0.5;
	}
	else {
		self.alpha = 1;
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	self.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	self.highlighted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	self.highlighted = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	if (point.x < (self.frame.size.width*-0.5) || point.x > (self.frame.size.width*1.5)) {
		self.highlighted = NO;
	}
	else if (point.y < (self.frame.size.height*-0.5) || point.y > (self.frame.size.height*1.5)) {
		self.highlighted = NO;
	}
	else
		self.highlighted = YES;
}

@end
