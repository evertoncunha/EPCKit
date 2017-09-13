//
//  EPCRadioControl.m
//
//  Created by Everton Postay Cunha on 14/06/11.
//

#import "EPCRadioControl.h"


@implementation EPCRadioControl

@synthesize buttons;

- (id)initWithButtons:(NSArray *)btns {
    self = [super init];
    if (self) {		
        self.buttons = btns;
		
		// REGISTER FOR NOTIFICATIONS
		
		for (UIButton *btn in self.buttons) {
			[btn addObserver:self forKeyPath:@"selected" options:(NSKeyValueObservingOptionNew) context:nil];
		}
    }
    return self;
}

- (void)dealloc {
	for (UIButton *btn in self.buttons) {
		[btn removeObserver:self forKeyPath:@"selected"];
	}
	self.buttons = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([[change objectForKey:@"new"] boolValue] == NO) {
		return;
	}
	for (UIButton *btn in self.buttons) {
		if (btn != object) {
			[btn removeObserver:self forKeyPath:@"selected"];
			[btn setSelected:NO];
			[btn addObserver:self forKeyPath:@"selected" options:(NSKeyValueObservingOptionNew) context:nil];
		}
	}
}

- (UIButton *)selectedButton {
	for (UIButton *btn in self.buttons) {
		if (btn.selected) {
			return btn;
		}
	}
	return nil;
}

@end
