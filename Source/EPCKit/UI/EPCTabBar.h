//
//  EPCTabBar.h
//
//  Created by Everton Postay Cunha on 15/06/11.
//

#import <Foundation/Foundation.h>

@class EPCTabBar;
@protocol EPCTabBarDelegate <NSObject>
@required
- (void)epcTabBar:(EPCTabBar*)tabBar selectedButton:(UIButton*)button;
@optional
- (void)epcTabBar:(EPCTabBar*)tabBar viewDidHideAnimated:(BOOL)animated;
- (void)epcTabBar:(EPCTabBar*)tabBar viewDidAppearAnimated:(BOOL)animated;
- (void)epcTabBar:(EPCTabBar*)tabBar orderOfButtonsChanged:(NSArray*)buttons;
@end



@interface EPCTabBar : UIView {
	
@private
	NSMutableArray *hidedButtons;
	NSMutableArray *barButtons;
	
	BOOL draggingButton;
	CGRect draggingButtonFrame;
	int buttonDraggedToPosition;
	
	BOOL moreViewShouldLayout;
	BOOL moreViewIsShowing;
	CGRect oldMoreViewFrame;
	
	UIButton *lastInButton;
	
	NSMutableArray *viewsToRestoreClipBounds;
	
	UIView *theSuperView;
}

/*
 @frame view frame
 @buttons NSArray with UIButtons
 @moreButton UIButton to show the extra buttons view
 */
- (id)initWithFrame:(CGRect)frame buttons:(NSArray*)buttons moreButton:(UIButton*)moreBtn;


/*
 @method saves the current buttons in order
 */
- (void)saveCurrentButtonsInOrder;


/*
 @action sended the more button is selected
 */
- (IBAction)selectedMoreButton:(UIButton*)sender;


/*
 @action sended when a button is selected
 */
- (IBAction)selectedButton:(UIButton*)sender;


/*
 @setter/getter if the buttons order should be saved on edit
 */
@property (nonatomic, assign) BOOL autoSaveButtonsOrder;


/*
 @getter the buttons that are in the bar
 */
@property (nonatomic, readonly) NSArray *barButtons;


/*
 @setter/getter show touch blur on barButton item when some other item might replace it
 */
@property (nonatomic, assign) BOOL barButtonsShowsTouchWhenHighlighted;


/*
 @setter/getter barButton item should highlight when some other item might replace it
 */
@property (nonatomic, assign) BOOL barButtonsShouldHighlight;


/*
 @setter/getter for the buttons
 */
@property (nonatomic, assign) NSArray *buttons;


/*
 @setter/getter the scale down animation when a button in moreView is swapped to barButton
 */
@property (nonatomic, assign) BOOL buttonSwappingAnimated;


/*
 @setter delegate that conforms to EPCTabBarDelegate protocol
 */
@property (nonatomic, assign) id<EPCTabBarDelegate> delegate;


/*
 @setter/getter hide the view animated
 */
@property (nonatomic, assign) BOOL hideViewAnimated;


/*
 @setter/getter BOOL value to ignore button touch when in edit mode
 */
@property (nonatomic, assign) BOOL ignoreButtonTouchWhileEditing;



/*
 @setter/getter defines the button that calls the view for more buttons
 */
@property (nonatomic, assign) UIButton *moreButton;


/*
 @setter/getter the scale factor to transform the button while dragging it
 */
@property (nonatomic, assign) float moreButtonDraggingZoomScale;


/*
 @getter the buttons that are in moreView
 */
@property (nonatomic, readonly) NSArray *moreViewButtons;


/*
 @setter/getter the view controller that will be opened on hit
 */
@property (nonatomic, retain) UIViewController *moreViewController;


/*
 @setter the margin between buttons
 */
@property (nonatomic, assign) CGPoint moreViewButtonsMarginRightBottom;


/*
 @setter the inner-margin for moreView.
 */
@property (nonatomic, assign) CGPoint moreViewPaddingLeftTop;


/*
 @method load saved buttons
 */
@property (nonatomic, readonly) NSArray *savedButtons;


/*
 @setter/getter the selected item
 */
@property (nonatomic, assign) UIButton *selectedItem;


/*
 @setter/getter show the view animated
 */
@property (nonatomic, assign) BOOL showViewAnimated;


/*
 @setter/getter view to render the extra buttons
 */
@property (nonatomic, retain) UIView *viewToRenderButtons;


+ (void)setHidden:(BOOL)flag;

@end


