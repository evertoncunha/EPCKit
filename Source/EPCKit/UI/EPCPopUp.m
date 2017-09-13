//
//  EPCPopUpVC.m
//
//  Created by Everton Cunha on 20/07/15.
//

#import "EPCPopUp.h"
#import "EPCCategories.h"
#define kCloseCustomPopOverNotification @"kCloseCustomPopOverNotification"
#define kCloseCustomPopOverNotificationObjectView @"obj"

@interface EPCPopUp() {
	
	BOOL _autoRemoveFromMemory;
	
	__weak IBOutlet UIView *_viewForOtherController;
	
	BOOL _didRelease;
}


@end

@implementation EPCPopUp


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		CFRetain((__bridge CFTypeRef)(self));
	}
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		CFRetain((__bridge CFTypeRef)(self));
	}
	return self;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		CFRetain((__bridge CFTypeRef)(self));
	}
	return self;
}

#pragma mark - Actions
- (void)tappedShaddow:(id)sender {
	if (!self.dontDismissOnShaddow) {
		if (self.dismissAlert) {
			[self.dismissAlert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
				if (alertView.cancelButtonIndex != buttonIndex) {
					[self close];
				};
			}];
		}
		else {
			[self close];
		}
	}
}

- (void)close {
	
	[self removeFromParentViewController];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseCustomPopOverNotification object:nil];
	
	[_viewController viewWillDisappear:YES];
	
	_isShow = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(kill)];
	[UIView setAnimationDuration:0.222f];
	self.view.alpha = 0.f;
	[UIView commitAnimations];
	
}

- (void)kill {
	
	[self.view removeFromSuperview];
	
	[_viewController viewDidDisappear:YES];
	
	if (self.didClosePopUpBlock) {
		self.didClosePopUpBlock();
	}
	
	self.view.alpha = 1;
	
	if (!_didRelease) {
		_didRelease = YES;
		CFRelease((__bridge CFTypeRef)(self));
	}
}

- (void)show {
	[self presentFromViewController:nil];
}

- (void)presentFromViewController:(UIViewController*)viewController {
	
	_btnB.userInteractionEnabled = _btnL.userInteractionEnabled = _btnR.userInteractionEnabled = _btnT.userInteractionEnabled = NO;
	
	_btnL.frameWidth = self.contentView.frameX;
	
	_btnT.frameHeight = self.contentView.frameY;
	
	_btnR.frameWidth = self.view.frameWidth - self.contentView.frameX - self.contentView.frameWidth;
	_btnR.frameX = self.contentView.frameX + self.contentView.frameWidth;
	
	_btnB.frameHeight = self.view.frameHeight - self.contentView.frameY - self.contentView.frameHeight;
	_btnB.frameY = self.contentView.frameY + self.contentView.frameHeight;
	
	_isShow = YES;
	viewController = nil;
	if (!viewController) {
		viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	}
	else {
		
		CGRect r = [[UIScreen mainScreen] bounds];

		while (!CGRectEqualToRect(viewController.view.frame, r) && viewController.parentViewController!=nil) {
			viewController = viewController.parentViewController;
		}
		
		[viewController addChildViewController:self];
	}
	
	UIView *keyView = [viewController view];
	self.view.frame = keyView.bounds;
	[_viewController viewWillAppear:NO];
	
	[keyView addSubview:self.view];
	
	[_viewController viewDidAppear:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCustomPopOverNotification:) name:kCloseCustomPopOverNotification object:nil];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		_btnB.userInteractionEnabled = _btnL.userInteractionEnabled = _btnR.userInteractionEnabled = _btnT.userInteractionEnabled = YES;
	});
}

- (void)closeCustomPopOverNotification:(NSNotification*)notification {
	UIView *view = notification.userInfo[kCloseCustomPopOverNotificationObjectView];
	if (self.viewController.isViewLoaded && view == self.viewController.view) {
		[self close];
	}
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
	return [self initWithViewController:viewController yCompensation:0];
}

- (instancetype)initWithViewController:(UIViewController*)viewController autoRemoveFromMemory:(BOOL)autoRemoveFromMemory {
	return [self initWithViewController:viewController];
}

- (instancetype)initWithViewController:(UIViewController *)viewController yCompensation:(int)yCompensation {
	
	self = [super initWithNibName:nil bundle:nil];
	
	if (self.view) {
		
		CFRetain((__bridge CFTypeRef)(self));
		
		_viewController = viewController;
		
		int difW = _contentView.frameWidth - _viewForOtherController.frameWidth;
		int difH = _contentView.frameHeight - _viewForOtherController.frameHeight;
		
		CGRect newFrame = _viewController.view.frame;
		newFrame.size.width += difW;
		newFrame.size.height += difH;
		
		_contentView.frame = newFrame;
		_contentView.center = self.view.center;
		
		newFrame = _contentView.frame;
		int x = newFrame.origin.x;
		int y = newFrame.origin.y + yCompensation;
		newFrame.origin = CGPointMake(x, y);
		_contentView.frame = newFrame;
		
		[_viewForOtherController addSubview:_viewController.view];
		
		[self addChildViewController:viewController];
	}
	
	return self;
}

+ (void)closeCustomPopUpWithSubview:(UIView *)subview {
	[[NSNotificationCenter defaultCenter] postNotificationName:kCloseCustomPopOverNotification object:nil userInfo:@{kCloseCustomPopOverNotificationObjectView:subview}];
}

@end
