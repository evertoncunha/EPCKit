//
//  EPCTabScrollView.m
//
//  Created by Everton Cunha on 24/12/14.
//

#import "EPCTabScrollView.h"

@implementation EPCTabScrollView

- (void)setViewControllers:(NSArray *)viewControllers {
	
	int i = 0;
	
	for (; i < [_viewControllers count]; i++) {
		
		UIViewController *current = _viewControllers[i];
		
		UIViewController *new = nil;
		
		if (i < [viewControllers count]) {
			new = viewControllers[i];
		}
		
		if (new != current) {
			new.view.frame = current.view.frame;
			[current.view removeFromSuperview];
			if (new) {
				[self addSubview:new.view];
			}
		}
	}
	
	
	CGRect fra = self.bounds;
	for (; i < [viewControllers count]; i++) {
		UIViewController *new = viewControllers[i];
		
		fra.origin.x = i*fra.size.width;
		new.view.frame = fra;
		
		[self addSubview:new.view];
	}
	
	_viewControllers = viewControllers;
	
	CGSize size = CGSizeMake(i*fra.size.width, fra.size.height);
	[self setContentSize:size];
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
	if (index < [self.viewControllers count]) {
		int x = index * self.frame.size.width;
		[self setContentOffset:CGPointMake(x, 0) animated:animated];
	}
	else {
		NSLog(@"%@ %s index (%d) out of viewControllers bounds (%d)", self, __PRETTY_FUNCTION__, (int)index, (int)[self.viewControllers count]);
	}
}

@end


@implementation UIViewController (EPCTabScrollView)
- (EPCTabScrollView*)tabScrollView {
	UIView *v = self.view;
	while (v && [v class] != [EPCTabScrollView class]) {
		v = v.superview;
	}
	return (id)v;
}
@end