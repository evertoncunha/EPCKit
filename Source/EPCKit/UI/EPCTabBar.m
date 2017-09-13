//
//  EPCTabBar.m
//
//  Created by Everton Postay Cunha on 15/06/11.
//

#import "EPCTabBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation EPCTabBar

@synthesize delegate, selectedItem, moreButton;
@synthesize moreViewPaddingLeftTop, viewToRenderButtons;
@synthesize moreViewButtonsMarginRightBottom;
@synthesize barButtonsShowsTouchWhenHighlighted;
@synthesize barButtonsShouldHighlight;
@synthesize moreButtonDraggingZoomScale;
@synthesize buttonSwappingAnimated;
@synthesize moreViewController;
@synthesize ignoreButtonTouchWhileEditing;
@synthesize showViewAnimated, hideViewAnimated;
@synthesize autoSaveButtonsOrder;

#pragma mark - Default

- (void)defaultConfig {
	self.moreButtonDraggingZoomScale = 1.35f;
	self.barButtonsShowsTouchWhenHighlighted = YES;
	self.barButtonsShouldHighlight = YES;
	self.buttonSwappingAnimated = YES;
	self.ignoreButtonTouchWhileEditing = YES;
	self.showViewAnimated = YES;
	self.hideViewAnimated = YES;
	self.autoSaveButtonsOrder = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabBar) name:@"TabBarHide" object:[self class]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabBar) name:@"TabBarShow" object:[self class]];
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
		[self defaultConfig];
    }
    return self;
}

- (id)initWithFrame:(CGRect)_frame buttons:(NSArray*)buttons moreButton:(UIButton*)moreBtn {
    self = [super initWithFrame:_frame];
    if (self) {
		[self defaultConfig];
		self.moreButton = moreBtn;
		self.buttons = buttons;
    }
    return self;
}

- (void)dealloc {
	barButtons =nil;
    hidedButtons =nil;
viewToRenderButtons =nil;
	viewsToRestoreClipBounds =nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TabBarHide" object:[self class]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TabBarShow" object:[self class]];
}

#pragma mark - Animation

- (void)animateTransitionWithID:(NSString*)animationID {
	[UIView beginAnimations:animationID context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
}

- (void)hideMoreViewAnimation {
	UIView *theView = self.moreViewController.view;
	
	oldMoreViewFrame = theView.frame;
	CGRect frame = oldMoreViewFrame;
	frame.origin.y = frame.size.height;
	
	[theSuperView bringSubviewToFront:self.superview];
	
	[self animateTransitionWithID:@"showMoreView"];
	[UIView setAnimationDidStopSelector:@selector(hideMoreViewAnimationStop)];
	[UIView setAnimationDelegate:self];
	theView.frame = frame;
	theView.alpha = 0;
	[UIView commitAnimations];
}

- (void)hideMoreViewAnimationStop {
	UIView *theView = self.moreViewController.view;
	[theView removeFromSuperview];
	theView.frame = oldMoreViewFrame;
	
	if ([self.delegate respondsToSelector:@selector(epcTabBar:viewDidHideAnimated:)]) {
		[self.delegate epcTabBar:self viewDidHideAnimated:YES];
	}
}

- (void)scaleDownButton:(UIButton*)button animated:(BOOL)animated {
	if (animated) {
		CABasicAnimation* animation;
		animation = [CABasicAnimation animationWithKeyPath:@"transform"];
		animation.fromValue =  [NSValue valueWithCATransform3D:CATransform3DMakeScale(self.moreButtonDraggingZoomScale, self.moreButtonDraggingZoomScale, 1)];
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
		animation.duration = 0.2f;
		animation.removedOnCompletion = YES;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[button.layer addAnimation:animation forKey:@"scaleDown"];
	}
	
	button.layer.transform = CATransform3DMakeScale(1, 1, 1);
}

- (void)scaleUpButton:(UIButton*)button {
	
	CABasicAnimation* animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.fromValue =  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
	animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(self.moreButtonDraggingZoomScale, self.moreButtonDraggingZoomScale, 1)];
	animation.duration = 0.2f;
	animation.removedOnCompletion = YES;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	[button.layer addAnimation:animation forKey:@"scaleUp"];
	
	button.layer.transform = CATransform3DMakeScale(self.moreButtonDraggingZoomScale, self.moreButtonDraggingZoomScale, 1);
}

- (void)showMoreViewAnimation {
	
	UIView *theView = self.moreViewController.view;
	
	CGRect frame = theView.frame;
	if (frame.size.height > (theSuperView.frame.size.height - self.frame.size.height)) {
		frame.size.height -= self.frame.size.height;
	}
	CGRect frameAnimation = frame;
	
	frameAnimation.origin.y = frame.size.height + frame.origin.y;
	theView.frame = frameAnimation;
	[theSuperView insertSubview:theView belowSubview:self.superview];
	theView.alpha = 0;
	
	[self animateTransitionWithID:@"showMoreView"];
	[UIView setAnimationDidStopSelector:@selector(showMoreViewAnimationStop)];
	[UIView setAnimationDelegate:self];
	theView.frame = frame;
	theView.alpha = 1;
	[UIView commitAnimations];
}

- (void)showMoreViewAnimationStop {
	UIView *theView = self.moreViewController.view;
	[theView.superview bringSubviewToFront:theView];
	
	if ([self.delegate respondsToSelector:@selector(epcTabBar:viewDidAppearAnimated:)]) {
		[self.delegate epcTabBar:self viewDidAppearAnimated:YES];
	}
}

#pragma mark - Design

- (void)designMoreView {
	/*
	 	MORE VIEW DESIGN 
	 */
	
	// include all buttons
	
	CGPoint margin = self.moreViewButtonsMarginRightBottom; // MARGIN FOR BUTTONS
	CGPoint padding = self.moreViewPaddingLeftTop;
	
	CGRect frame = CGRectMake(padding.x, padding.y, 0, 0);
	
	static BOOL shouldAddButtons = YES; // so won't add on other call
	for (UIButton *btn in hidedButtons) {
		frame.size = btn.frame.size;
		btn.frame = frame;
		// change next frame
		frame.origin.x += frame.size.width + margin.x;
		
		// check if will fo out of limits
		if ((frame.origin.x + frame.size.width + padding.x) > self.viewToRenderButtons.frame.size.width) {
			// out of limits
			frame.origin.x = padding.x;
			frame.origin.y += (frame.size.height + margin.y);
		}
		
		if (shouldAddButtons) {
			[self.viewToRenderButtons addSubview:btn];
		}
		
		// REGISTER FOR DRAG
		[self performSelector:@selector(registerForDragEvents:) withObject:btn];
	}
	shouldAddButtons = NO;
	
	moreViewShouldLayout = NO;
}

#pragma mark - Private

- (void)barButtonSelectButton:(UIButton*)button {
	for (UIButton *btn in barButtons) {
		if (btn != button) {
			btn.selected = NO;
		} else {
			btn.selected = YES;
		}
	}
}

- (void)changedButtonAtPosition:(int)position withButton:(UIButton*)hidedButton {
	
	UIButton *barButton = [barButtons objectAtIndex:position];
	
	CGRect barBtnFrame = barButton.frame;
	
	int index = [hidedButtons indexOfObject:hidedButton];
	
	[hidedButtons replaceObjectAtIndex:index withObject:barButton];
	
	[barButton removeFromSuperview];
	
	hidedButton.frame = barBtnFrame;
	
	[barButtons replaceObjectAtIndex:position withObject:hidedButton];
	
	[barButton setHighlighted:NO];
	[self performSelector:@selector(unregisterForDragEvents:) withObject:hidedButton];
	[self performSelector:@selector(registerForDragEvents:) withObject:barButton];
	
	CGRect oldFrameAdjust = barButton.frame;
	oldFrameAdjust.origin.y = viewToRenderButtons.bounds.size.height;
	barButton.frame = oldFrameAdjust;
	[viewToRenderButtons addSubview:barButton];
	
	[self animateTransitionWithID:@"changeButtons"];
	barButton.frame = draggingButtonFrame;
	[UIView commitAnimations];
	
	[self addSubview:hidedButton];
	
	if (self.autoSaveButtonsOrder) {
		[self saveCurrentButtonsInOrder];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcTabBar:orderOfButtonsChanged:)]) {
		[self.delegate epcTabBar:self orderOfButtonsChanged:self.buttons];
	}
}

- (void)hideMoreView {
	if (self.viewToRenderButtons) {
		
		if (self.hideViewAnimated) {
			[self hideMoreViewAnimation];
			
		} else {
			[self.moreViewController.view removeFromSuperview];
			
			if ([self.delegate respondsToSelector:@selector(epcTabBar:viewDidHideAnimated:)]) {
				[self.delegate epcTabBar:self viewDidHideAnimated:NO];
			}
		}
	}
}

- (void)showMoreView {
	
	UIView *superview = theSuperView = self.superview.superview;
	while (superview != nil) {
		superview = superview.superview;
	}
	
	moreViewIsShowing = YES;
	
	if (moreViewShouldLayout) {
		[self designMoreView];
	}
	
	if (self.showViewAnimated) {
		[self showMoreViewAnimation];
		
	} else {
		
		UIView *theView = self.moreViewController.view;
		
		CGRect frame = theView.frame;
		if (frame.size.height > (superview.frame.size.height - self.frame.size.height)) {
			frame.size.height -= self.frame.size.height;
		}
		
		theView.frame = frame;
		[superview addSubview:theView];
		
		if ([self.delegate respondsToSelector:@selector(epcTabBar:viewDidAppearAnimated:)]) {
			[self.delegate epcTabBar:self viewDidAppearAnimated:YES];
		}
	}
	
}

- (void)hideTabBar {
	self.hidden = YES;
}

- (void)showTabBar {
	self.hidden = NO;
}

#pragma mark - Drag Events

- (void)draggingAboveButton:(UIButton *)btn {
	
	if (btn != lastInButton) {
		
		if (self.barButtonsShouldHighlight)
			lastInButton.highlighted = NO;
		
		if (self.barButtonsShowsTouchWhenHighlighted) {
			lastInButton.adjustsImageWhenHighlighted = NO;
			lastInButton.showsTouchWhenHighlighted = NO;
		}
		
		if (!btn) {
			for (UIButton *btn in barButtons) {
				if (self.barButtonsShouldHighlight)
					btn.highlighted = NO;
				
				if (self.barButtonsShowsTouchWhenHighlighted) {
					btn.adjustsImageWhenHighlighted = NO;
					btn.showsTouchWhenHighlighted = NO;
				}
			}
		} else {
			if (self.barButtonsShowsTouchWhenHighlighted) {
				btn.adjustsImageWhenHighlighted = YES;
				btn.showsTouchWhenHighlighted = YES;
			}
			
			if (self.barButtonsShouldHighlight)
				btn.highlighted = YES;
		}
	}
	
	lastInButton = btn;
	
}

- (void)draggingButton:(UIButton *)button withEvent:(UIEvent *)event {
	
	if (!draggingButton) {
		draggingButton = YES;
		draggingButtonFrame = button.frame;
		[[button superview] bringSubviewToFront:button];
		
		UIView *superview = button.superview;
		
		while (superview != nil) {
			if (superview.clipsToBounds) {
				if (!viewsToRestoreClipBounds) {
					viewsToRestoreClipBounds = [[NSMutableArray alloc] init];
				}
				[viewsToRestoreClipBounds addObject:superview];
				superview.clipsToBounds = NO;
			}
			superview = superview.superview;
		}
		
		[self scaleUpButton:button];
	}
	CGPoint point = [[[event allTouches] anyObject] locationInView:self.viewToRenderButtons];
	
	// move the object to the center of the touch
	button.center = point;
	
	if ((point.y + moreButton.bounds.size.height/2) > viewToRenderButtons.bounds.size.height) {
		buttonDraggedToPosition = ceil(point.x/ 64) - 1;
		
		if (buttonDraggedToPosition < [barButtons count]) {
			UIButton *btn = [barButtons objectAtIndex:buttonDraggedToPosition];
			[self draggingAboveButton:btn];
			
		} else {
			[self draggingAboveButton:nil];
		}
		
	} else {
		buttonDraggedToPosition = -1;
		[self draggingAboveButton:nil];
	}
}

- (void)draggingExit:(UIButton *)button withEvent:(UIEvent *)event {
	if (viewsToRestoreClipBounds) {
		for (UIView* view in viewsToRestoreClipBounds) {
			view.clipsToBounds = YES;
		}
		viewsToRestoreClipBounds = nil;
	}
	if (draggingButton) {
		
		button.layer.transform = CATransform3DMakeScale(1, 1, 1);
		
		draggingButton = NO;
		[self barButtonSelectButton:nil];
		
		/* BUTTON BEEING DRAGGED */
		
		if (buttonDraggedToPosition >= 0 && buttonDraggedToPosition < [barButtons count]) {
			// CHANGE POSITION WITH ANOTHER BUTTON
			[self performSelector:@selector(draggingAboveButton:) withObject:nil];
			[self changedButtonAtPosition:buttonDraggedToPosition withButton:button];
			
			[self scaleDownButton:button animated:self.buttonSwappingAnimated];
			
		} else {
			// DID NOT MAKE ANY CHANGE
			[self animateTransitionWithID:@"buttonBack"];
			button.frame = draggingButtonFrame;
			[UIView commitAnimations];
			
			[self scaleDownButton:button animated:YES];
		}
		
	} else {
		
		/* BUTTON TOUCH ACTION */
		
		if (!self.ignoreButtonTouchWhileEditing || [self.barButtons containsObject:button]) {
			[self performSelector:@selector(selectedButton:) withObject:button];
		}
	}
}

- (void)registerForDragEvents:(UIButton*)btn {
	[btn addTarget:self action:@selector(draggingButton:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
}

- (void)unregisterForDragEvents:(UIButton*)btn {
	[btn removeTarget:self action:@selector(draggingButton:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
}

#pragma mark - Save/Load - Public

- (void)saveCurrentButtonsInOrder {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.buttons];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"orderedButtonsArray"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)savedButtons {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orderedButtonsArray"];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	return nil;
}

#pragma mark - Public

- (NSArray *)barButtons {
	return barButtons;
}

- (NSArray *)buttons {
	NSMutableArray *mut = [NSMutableArray arrayWithCapacity:(barButtons.count + hidedButtons.count)];
	[mut addObjectsFromArray:barButtons];
	[mut addObjectsFromArray:hidedButtons];
	return mut;
}

- (UIView *)viewToRenderButtons {
	if (!viewToRenderButtons) {
		CGRect frame = [[self superview] bounds];
		frame.size.height -= self.frame.size.height;
		
		viewToRenderButtons = [[UIView alloc] initWithFrame:frame];
	}
	return viewToRenderButtons;
}

- (NSArray *)moreViewButtons {
	return hidedButtons;
}

- (void)setButtons:(NSArray *)buttons {
	moreViewShouldLayout = YES;
	
	// RETAIN BUTTONS IN ARRAYS
	
	barButtons = [[NSMutableArray alloc] initWithCapacity:4];
	
	float frameX = 0;
	CGRect frame;
	
	for (int i = 0; i < 4; i++) {
		UIButton *btn = [buttons objectAtIndex:i];
		[barButtons addObject:btn];
		[btn addTarget:self action:@selector(draggingExit:withEvent:) forControlEvents:UIControlEventTouchUpInside];
		btn.multipleTouchEnabled = NO;
		btn.exclusiveTouch = YES;
		
		// ADD BUTTONS TO VIEW (SELF) AS BAR BUTTONS
		frame = btn.frame;
		frame.origin.x = frameX;
		
		btn.frame = frame;
		
		frameX += frame.size.width;
		[self addSubview:btn];
	}
	
	hidedButtons = [[NSMutableArray alloc] initWithCapacity:buttons.count-4];
	for (int i = 4; i < buttons.count; i++) {
		UIButton *btn = [buttons objectAtIndex:i];
		[hidedButtons addObject:btn];
		[btn addTarget:self action:@selector(draggingExit:withEvent:) forControlEvents:UIControlEventTouchUpInside];
		btn.multipleTouchEnabled = NO;
		btn.exclusiveTouch = YES;
	}
	
}

- (void)setMoreButton:(UIButton *)moreBtn {
	moreViewShouldLayout = YES;
	
	// BUTTON MORE
	
	moreButton = moreBtn;
	
	//sends the button to the right
	CGRect frame = moreButton.frame;
	frame.origin.x = self.frame.size.width - frame.size.width;
	moreButton.frame = frame;
	
	[self addSubview:moreButton];
	[moreButton addTarget:self action:@selector(selectedMoreButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setViewToRenderButtons:(UIView *)view {
	if (viewToRenderButtons) {
		viewToRenderButtons =nil;
	}
	viewToRenderButtons = view;
	self.viewToRenderButtons.multipleTouchEnabled = NO;
	self.viewToRenderButtons.exclusiveTouch = YES;
}

- (void)setMoreViewButtonsMarginRightBottom:(CGPoint)point {
	moreViewButtonsMarginRightBottom = point;
	moreViewShouldLayout = YES;
}

- (void)setMoreViewPaddingLeftTop:(CGPoint)point {
	moreViewPaddingLeftTop = point;
	moreViewShouldLayout = YES;
}

- (void)setSelectedItem:(UIButton *)item {
	for (UIButton *btn in barButtons) {
		if (btn.selected)
			btn.selected = NO;
	}
	for (UIButton *btn in hidedButtons) {
		if (btn.selected)
			btn.selected = NO;
	}
	
	item.selected = YES;
	selectedItem = item;
	
	[self.delegate epcTabBar:self selectedButton:selectedItem];
}

#pragma mark - Public Actions

- (void)selectedButton:(UIButton*)sender {
	if (!draggingButton) {
		
		if (moreViewIsShowing) {
			moreButton.selected = NO;
			[self performSelector:@selector(hideMoreView)];
		}
		self.selectedItem = sender;
	}
}

- (void)selectedMoreButton:(UIButton*)sender {
	if (!moreButton.selected) {
		moreButton.selected = YES;
		[self performSelector:@selector(barButtonSelectButton:) withObject:nil];
		[self performSelector:@selector(showMoreView)];
		self.selectedItem = sender;
	}
}

+ (void)setHidden:(BOOL)flag {
	NSString *str = @"TabBarHide";
	if (!flag)
		str = @"TabBarShow";
	[[NSNotificationCenter defaultCenter] postNotificationName:str object:[self class]];
}

@end
