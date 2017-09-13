//
//  EPCTableViewController.h
//
//  Created by Everton Cunha on 21/03/13.
//


/* 
 
 * * INSTRUCTIONS * *
 
 
// * Required to override:
 
- (void)reloadTableViewDataSource {}
 
 
// * Optional to override and call super:

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {}
 
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView	willDecelerate:(BOOL)willDecelerate {}


// * Optional if you want to customize refresh view
// Localize:
//"Release to refresh..." = "Release to refresh...";
//"Pull down to refresh..." = "Pull down to refresh...";
//"Loading..." = "Loading...";
 
- (EPCTableViewRefreshView*)customRefreshView  {}
 
*/

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class EPCTableViewRefreshView;

@interface EPCTableViewController : UIViewController <UITableViewDelegate, EGORefreshTableHeaderDelegate> {
	UIColor *_activityIndicatorViewColor;
	BOOL _reloading;
}

- (void)beginRefreshing;

- (void)endRefreshing;

- (void)setRefreshActivityIndicatorViewColor:(UIColor*)color;

- (void)reloadTableViewDataSource; // * REQUIRED OVERRIDE

/*
 Your custom view will be streched to TableView's width and height, note your Autosizing rules, should be Flexible Right and Top.
 */
- (EPCTableViewRefreshView*)customRefreshView; // * OPTIONAL OVERRIDE (You can load a nib with EGORefreshTableHeaderView)

@property (assign) IBOutlet UITableView *tableView;

@property (strong) UITableViewController *tableViewController;

@property (strong) EPCTableViewRefreshView *refreshView;

@property (getter=refreshIsHidden) BOOL refreshHidden;

@end




@interface EPCTableViewRefreshView : EGORefreshTableHeaderView {
	int _offsetHeight;
}

- (void)beginRefreshing;

- (void)endRefreshing;

@property (assign) IBOutlet UIActivityIndicatorView *activityView;

@property (assign) IBOutlet UILabel *statusLabel;

@property (assign) IBOutlet UIImageView *arrowDownImageView;

@end