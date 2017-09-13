//
//  EPCContainerView.h
//
//  Created by Everton Postay Cunha on 11/25/11.
//

#import <Foundation/Foundation.h>

@class EPCContainerView;
@protocol EPCContainerViewDelegate <NSObject>
@optional
- (void)epcContainerView:(EPCContainerView*)epcContainerView pushedViewController:(UIViewController*)pushedViewController fromViewController:(UIViewController*)fromViewController animated:(BOOL)animated;
- (void)epcContainerView:(EPCContainerView*)epcContainerView poppedFromViewController:(UIViewController*)fromViewController toViewController:(UIViewController*)toViewController animated:(BOOL)animated;
@end


@interface EPCContainerView : UIView {
	NSMutableArray *pushedViewControllers;
	
}

- (void)pushViewController:(UIViewController*)newViewController animated:(BOOL)animated;

- (void)pushNewRootViewController:(UIViewController*)newViewController animated:(BOOL)animated;

- (void)popToViewController:(UIViewController*)toViewController animated:(BOOL)animated;

- (void)popViewControllerAnimated:(BOOL)animated;

- (void)popToRootViewControllerAnimated:(BOOL)animated;

- (BOOL)canPop;

- (void)removeAllViewControllersAnimated:(BOOL)animated;

- (IBAction)popAnimated;

- (IBAction)popToRootAnimated;

@property (nonatomic, readonly) UIViewController *visibleViewController;
@property (nonatomic, readonly) NSArray *pushedViewControllers;
@property (nonatomic, assign) IBOutlet id<EPCContainerViewDelegate>delegate;

@end


@interface UIView (container)
- (EPCContainerView *)epcContainerView;
@end

@interface UIViewController (container)
- (EPCContainerView *)epcContainerView;
- (IBAction)popEPCContainerViewAnimated:(id)sender;
@end