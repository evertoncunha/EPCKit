//
//  EPCContainerView.m
//
//  Created by Everton Postay Cunha on 11/25/11.
//

#import "EPCContainerView.h"
#import <QuartzCore/QuartzCore.h>
#import "EPCCategories.h"
#import "EPCDefines.h"

@implementation EPCContainerView
@synthesize delegate, pushedViewControllers;

- (void)dealloc {
    for (UIView *vv in self.subviews)
		[vv removeFromSuperview];
}

- (void)popAnimated {
	[self popViewControllerAnimated:YES];
}

- (void)popToRootAnimated {
	[self popToRootViewControllerAnimated:YES];
}

- (void)removeAllViewControllersAnimated:(BOOL)animated {
	
	UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	[pushedViewControllers removeAllObjects];
	
	if (!animated)
	{
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
	}
	else
	{
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			[sub setFrameX:self.frame.size.width];
		}
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcContainerView:poppedFromViewController:toViewController:animated:)])
		[self.delegate epcContainerView:self poppedFromViewController:fromViewController toViewController:nil animated:animated];
}

-(void)pushNewRootViewController:(UIViewController *)newViewController animated:(BOOL)animated {
	NSAssert((newViewController != nil), @"Trying to push nil");
	
	UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	if (!pushedViewControllers)
		pushedViewControllers = [NSMutableArray array];
    
    [pushedViewControllers removeAllObjects];
	[pushedViewControllers addObject:newViewController];
    
//	if (IOS_VERSION_LESS_THAN(@"5")) {
		id create = newViewController.view;
		create = nil;
		[newViewController viewWillAppear:animated];
		[fromViewController viewWillDisappear:animated];
//	}
	
	if (self.autoresizesSubviews)
		newViewController.view.frame = self.bounds;
	
	if (!animated) 
    {
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		[newViewController.view setFrameX:0];
		[self addSubview:newViewController.view];
		
		if (IOS_VERSION_LESS_THAN(@"5")) {
			[newViewController viewDidAppear:NO];
		}
	}
	else {
        
        [newViewController.view setFrameX:self.frame.size.width];
		[self addSubview:newViewController.view];
        
		[UIView beginAnimations:@"push" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
        for (UIView *sub in self.subviews) {
			if (sub != newViewController.view) {
				[sub setFrameX:-sub.frame.size.width];
			}
		}

		[newViewController.view setFrameX:0];
		[UIView commitAnimations];        
	}
        
	
	if ([self.delegate respondsToSelector:@selector(epcContainerView:pushedViewController:fromViewController:animated:)])
		[self.delegate epcContainerView:self pushedViewController:newViewController fromViewController:fromViewController animated:animated];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	
	if (IOS_VERSION_LESS_THAN(@"5")) {
		[self.visibleViewController viewDidAppear:YES];
	}
	
	UIView *currentView = self.visibleViewController.view;
	for (UIView *sub in self.subviews) {
		if (sub != currentView) {
			[sub removeFromSuperview];
		}
	}
	self.userInteractionEnabled = YES;
}

-(void)pushViewController:(UIViewController *)newViewController animated:(BOOL)animated {
	NSAssert((newViewController != nil), @"Trying to push nil");
    
	UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	if (!pushedViewControllers)
		pushedViewControllers = [NSMutableArray array];
    
	[pushedViewControllers addObject:newViewController];
    
//	if (IOS_VERSION_LESS_THAN(@"5")) {
		id create = newViewController.view;
		create = nil;
		[newViewController viewWillAppear:animated];
		[fromViewController viewWillDisappear:animated];
//	}
	
	if (self.autoresizesSubviews)
		newViewController.view.frame = self.bounds;
	
	if (!animated) {
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		[self addSubview:newViewController.view];
		
		if (IOS_VERSION_LESS_THAN(@"5")) {
			[newViewController viewDidAppear:NO];
		}
	}
	else {
		[newViewController.view setFrameX:self.frame.size.width];
		[self addSubview:newViewController.view];
		
		[UIView beginAnimations:@"push" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != newViewController.view) {
				[sub setFrameX:-sub.frame.size.width];
			}
		}
        
		[newViewController.view setFrameX:0];
		[UIView commitAnimations];
		
	}
	
	if ([self.delegate respondsToSelector:@selector(epcContainerView:pushedViewController:fromViewController:animated:)])
		[self.delegate epcContainerView:self pushedViewController:newViewController fromViewController:fromViewController animated:animated];
}

- (void)popToViewController:(UIViewController *)toViewController animated:(BOOL)animated {
	
	UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	if (![pushedViewControllers containsObject:toViewController])
		[NSException raise:@"Exception!" format:@"Trying to pop a view that wasn't push in the container."];
	
//	if (IOS_VERSION_LESS_THAN(@"5")) {
		id create = toViewController.view;
		create = nil;
		[toViewController viewWillAppear:animated];
		[fromViewController viewWillDisappear:animated];
//	}
	
	if (!animated) 
    {
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
		
		[self addSubview:toViewController.view];
		
		if (IOS_VERSION_LESS_THAN(@"5")) {
			[toViewController viewDidAppear:NO];
		}
	}
	else 
    {
        
		[toViewController.view setFrameX:-toViewController.view.frame.size.width];
		[self addSubview:toViewController.view];
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != toViewController.view) {
				[sub setFrameX:self.frame.size.width];
			}
		}
		[toViewController.view setFrameX:0];
		[UIView commitAnimations];
	}
    
    while([pushedViewControllers lastObject] != toViewController)
    {
		[pushedViewControllers removeLastObject];
    }
	
	if ([self.delegate respondsToSelector:@selector(epcContainerView:poppedFromViewController:toViewController:animated:)])
		[self.delegate epcContainerView:self poppedFromViewController:fromViewController toViewController:toViewController animated:animated];
	
}

-(void)popViewControllerAnimated:(BOOL)animated
{
	assert([pushedViewControllers count] > 0);
	
	UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	[pushedViewControllers removeLastObject];
	UIViewController *toViewController = [pushedViewControllers lastObject];
	
//	if (IOS_VERSION_LESS_THAN(@"5")) {
		id create = toViewController.view;
		create = nil;
		[toViewController viewWillAppear:animated];
		[fromViewController viewWillDisappear:animated];
//	}
	
	if (!animated) 
    {        
        
		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        
		[self addSubview:toViewController.view];
		
		if (IOS_VERSION_LESS_THAN(@"5")) {
			[toViewController viewDidAppear:NO];
		}
	}
	else 
    {
        
		[toViewController.view setFrameX:-toViewController.view.frame.size.width];
		[self addSubview:toViewController.view];
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != toViewController.view) {
				[sub setFrameX:self.frame.size.width];
			}
		}
		[toViewController.view setFrameX:0];
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcContainerView:poppedFromViewController:toViewController:animated:)])
		[self.delegate epcContainerView:self poppedFromViewController:fromViewController toViewController:toViewController animated:animated];
}

-(void)popToRootViewControllerAnimated:(BOOL)animated {

	if ([pushedViewControllers count] <= 1) {
		return;
	}
	
	UIViewController *fromViewController = [pushedViewControllers lastObject];
	
	while ([pushedViewControllers count] > 1)
		[pushedViewControllers removeLastObject];
	
	UIViewController *toViewController = [pushedViewControllers lastObject];
	
//	if (IOS_VERSION_LESS_THAN(@"5")) {
		id create = toViewController.view;
		create = nil;
		[toViewController viewWillAppear:animated];
		[fromViewController viewWillDisappear:animated];
//	}
	
	if (!animated) {

		for (UIView *sub in self.subviews)
			[sub removeFromSuperview];
        
		[self addSubview:toViewController.view];
		
		if (IOS_VERSION_LESS_THAN(@"5")) {
			[toViewController viewDidAppear:NO];
		}
	}
	else 
    {
        
		[toViewController.view setFrameX:-toViewController.view.frame.size.width];
		[self addSubview:toViewController.view];
		
		[UIView beginAnimations:@"pop" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.333f];
		[UIView setAnimationDelegate:self];
		self.userInteractionEnabled = NO;
		for (UIView *sub in self.subviews) {
			if (sub != toViewController.view) {
				[sub setFrameX:self.frame.size.width];
			}
		}

		[toViewController.view setFrameX:0];
		[UIView commitAnimations];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcContainerView:poppedFromViewController:toViewController:animated:)])
		[self.delegate epcContainerView:self poppedFromViewController:fromViewController toViewController:toViewController animated:animated];
}


-(BOOL)canPop {
	return ([pushedViewControllers count] > 1);
}

-(UIView *)visibleViewController {
	return [pushedViewControllers lastObject];
}
@end



@implementation UIView (container)

- (EPCContainerView *)epcContainerView {
	UIView *view = self.superview;
	
	while (view != nil && ![view isKindOfClass:[EPCContainerView class]])
		view = view.superview;
	
#ifdef DEBUG
	if (view == nil)
		NSLog(@"Warning: %@ is not in a EPCContainerView. Returning nil.", NSStringFromClass([self class]));
#endif
	return (id)view;
}
@end

@implementation UIViewController (container)

- (EPCContainerView *)epcContainerView {
	UIView *view = self.view.superview;
	
	while (view != nil && ![view isKindOfClass:[EPCContainerView class]])
		view = view.superview;
	
#ifdef DEBUG
	if (view == nil)
		NSLog(@"Warning: %@ is not in a EPCContainerView. Returning nil.", NSStringFromClass([self class]));
#endif
	return (id)view;
}
- (void)popEPCContainerViewAnimated:(id)sender {
	[self.epcContainerView popViewControllerAnimated:YES];
}
@end

