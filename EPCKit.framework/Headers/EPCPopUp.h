//
//  EPCPopUpVC.h
//
//  Created by Everton Cunha on 20/07/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EPCPopUp : UIViewController {
	
	__weak IBOutlet UIButton
	*_btnT,
	*_btnR,
	*_btnB,
	*_btnL;
}

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, readonly) UIViewController *viewController;

@property (nonatomic) BOOL isShow;

@property (nonatomic) BOOL dontDismissOnShaddow;

@property (nonatomic) BOOL autoRemoveFromMemory __deprecated;

@property (copy) void(^didClosePopUpBlock)();

- (IBAction)tappedShaddow:(id)sender;

- (void)close;

- (void)show __deprecated;

- (void)presentFromViewController:(UIViewController*)viewController;

- (instancetype)initWithViewController:(UIViewController*)viewController autoRemoveFromMemory:(BOOL)autoRemoveFromMemory __deprecated;

- (instancetype)initWithViewController:(UIViewController*)viewController;

- (instancetype)initWithViewController:(UIViewController *)viewController yCompensation:(int)yCompensation;

+ (void)closeCustomPopUpWithSubview:(UIView*)subview;


@property (nonatomic, weak) IBOutlet UIButton *shadowButton;

@property (nonatomic) UIAlertView *dismissAlert;
@end
