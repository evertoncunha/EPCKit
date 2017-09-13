//
//  EPCLabel.m
//
//  Created by Everton Postay Cunha on 8/31/11.
//

#import "EPCLabel.h"

@implementation EPCLabel
@synthesize alignTextOnTop;

-(void)verticalAlignTop {
	CGSize maximumSize = originalSize;
    NSString *dateString = self.text;
    UIFont *dateFont = self.font;
    CGSize dateStringSize = [dateString sizeWithFont:dateFont 
								   constrainedToSize:CGSizeMake(self.frame.size.width, maximumSize.height) 
									   lineBreakMode:self.lineBreakMode];
	
    CGRect dateFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, dateStringSize.height);
	
    [super setFrame:dateFrame];
}

- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGFloat fontSize = [font pointSize];
    CGFloat height = [self.text sizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    UIFont *newFont = font;
	
    //Reduce font size while too large, break if no height (empty string)
    while (height > size.height && height != 0 && fontSize > self.minimumFontSize) {
        fontSize--;  
        newFont = [UIFont fontWithName:font.fontName size:fontSize];   
        height = [self.text sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    };
	
    // Loop through words in string and resize to fit
	if (fontSize > self.minimumFontSize) {
		for (NSString *word in [self.text componentsSeparatedByString:@" "]) {
			CGFloat width = [word sizeWithFont:newFont].width;
			while (width > size.width && width != 0 && fontSize > self.minimumFontSize) {
				fontSize--;
				newFont = [UIFont fontWithName:font.fontName size:fontSize];   
				width = [word sizeWithFont:newFont].width;
			}
		}
	}
    return fontSize;
}

-(void)setText:(NSString *)text {
	[super setText:text];
	
	if (originalSize.height == 0) {
		originalPointSize = self.font.pointSize;
		originalSize = self.frame.size;
	}
	
	if (self.adjustsFontSizeToFitWidth && self.numberOfLines > 1) {
		UIFont *origFont = [UIFont fontWithName:self.font.fontName size:originalPointSize];
		float newSize = [self fontSizeWithFont:origFont constrainedToSize:originalSize];
		if (newSize < self.font.pointSize)
			self.font = [UIFont fontWithName:origFont.fontName size:newSize];
	}
	
	if (self.alignTextOnTop)
		[self verticalAlignTop];
}

-(void)setAlignTextOnTop:(BOOL)flag {
	alignTextOnTop = YES;
	if (alignTextOnTop && self.text != nil)
		[self setText:self.text];
}

-(void)awakeFromNib {
	[super awakeFromNib];
	self.alignTextOnTop = YES;
	self.minimumFontSize = self.font.pointSize - 4;
	//self.adjustsFontSizeToFitWidth = YES;
}

-(void)setFrame:(CGRect)newSize {
	[super setFrame:newSize];
	originalSize = newSize.size;
}

@end
