//
//  EPCScrollViewKeyboard.m
//
//  Created by Everton Cunha on 26/04/13.
//

#import "EPCScrollViewKeyboard.h"
#import "EPCCategories.h"

@implementation EPCScrollViewKeyboard

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
	
	[self setContentSize:self.frame.size];
	
	if (!self.showsVerticalScrollIndicator && !self.showsHorizontalScrollIndicator && !self.delegate) {
		self.delegate = self;
	}
}

#pragma mark - Keyboard


- (void)keyboardWillShowNotification:(NSNotification*)notification {
	
	CGRect keyRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	if (keyRect.size.height>0) {
		
		UIScrollView *scrollView = self;
		
		UIView *keyView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
		
		keyRect = [keyView convertRect:keyRect toView:nil];
		
		CGRect rect = [scrollView convertRect:scrollView.frame toView:keyView];
		
		int y = rect.origin.y+rect.size.height-keyRect.origin.y;
		
		CGRect responderFrame = [[UIResponder currentFirstResponder] frame];
		responderFrame.size.height+=10;
		
		scrollView.contentInset = UIEdgeInsetsMake(0, 0, y, 0);
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
		[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		[scrollView scrollRectToVisible:responderFrame animated:NO];
		[UIView commitAnimations];
		
	}
}

- (void)keyboardWillHideNotification:(NSNotification*)notification {
	
	UIScrollView *scrollView = self;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
	[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	scrollView.contentInset = UIEdgeInsetsZero;
	[UIView commitAnimations];
}

#pragma mark - TextFields

- (void)nextTextField:(UITextField*)sender {
	
	UIView *superview = sender.superview;
	
	NSArray *subviews = superview.subviews;
	
	int index = (int)[subviews indexOfObject:sender];
	
	for (int i = index+1; i < [subviews count]; i++) {
		id obj = [subviews objectAtIndex:i];
		if ([obj isKindOfClass:[UITextField class]]) {
			[obj becomeFirstResponder];
			break;
		}
	}
}

#pragma mark - Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[UIResponder currentFirstResponder] resignFirstResponder];
}

@end
