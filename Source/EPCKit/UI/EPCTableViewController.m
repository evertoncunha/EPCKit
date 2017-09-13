//
//  EPCTableViewController.m
//
//  Created by Everton Cunha on 21/03/13.
//

#import "EPCTableViewController.h"

@implementation EPCTableViewController

- (void)dealloc
{
    [_activityIndicatorViewColor release];
	self.tableViewController = nil;
	self.refreshView.delegate = nil;
	self.refreshView = nil;
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
    [super dealloc];
}
- (UIRefreshControl*)createRefreshControl {
	UIRefreshControl *obj = [[[UIRefreshControl alloc] init] autorelease];
	[obj addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	return obj;
}

- (void)refreshControlValueChanged:(UIRefreshControl*)control {
	if (control.isRefreshing) {
		[self reloadTableViewDataSource];
	}
}


- (void)configure {
	if (NSClassFromString(@"UIRefreshControl") != NULL) {
		self.tableViewController = [[[UITableViewController alloc] init] autorelease];
		self.tableViewController.tableView = self.tableView;
		assert(self.tableView);
		self.tableViewController.refreshControl = [self createRefreshControl];
	}
	else {
		[self addCustomRefreshPrivate];
	}
}
- (void)viewDidLoad {
	[super viewDidLoad];
	[self configure];
	self.tableView.delegate = self;
}

#pragma mark - Actions

- (void)addCustomRefreshPrivate {
	if (self.tableViewController == nil) {
		if (!self.refreshView) {
			self.refreshView = [self customRefreshView];
			self.refreshView.frame = CGRectMake(0.f, -self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height);
			self.refreshView.delegate = self;
			[self.tableView addSubview:self.refreshView];
			if ([self.refreshView.activityView respondsToSelector:@selector(setColor:)]) {
				self.refreshView.activityView.color = _activityIndicatorViewColor;
			}
		}
	}
}

- (EPCTableViewRefreshView*)customRefreshView {
	EPCTableViewRefreshView *obj = [[[EPCTableViewRefreshView alloc] initWithFrame:CGRectMake(0.f,0.f, self.tableView.bounds.size.width, self.tableView.bounds.size.height)] autorelease];
	return obj;
}

- (void)removeCustomRefresh {
	if (self.tableViewController == nil) {
		[self.refreshView removeFromSuperview];
		self.refreshView.delegate = nil;
		self.refreshView = nil;
	}
}

- (void)setRefreshActivityIndicatorViewColor:(UIColor *)color {
	[_activityIndicatorViewColor release];
	_activityIndicatorViewColor = [color retain];
	
	self.tableViewController.refreshControl.tintColor = color;
	
	if ([self.refreshView.activityView respondsToSelector:@selector(setColor:)]) {
		// iOS 5+
		self.refreshView.activityView.color = color;
	}
}

- (void)setRefreshHidden:(BOOL)hide {
	if (hide != [self refreshIsHidden]) {
		if (hide) {
			[self endRefreshing];
			self.tableViewController.refreshControl = nil;
			[self removeCustomRefresh];
		}
		else {
			self.tableViewController.refreshControl = [self createRefreshControl];
			self.tableViewController.refreshControl.tintColor = _activityIndicatorViewColor;
			[self addCustomRefreshPrivate];
		}
	}
}

- (BOOL)refreshIsHidden {
	return self.tableViewController.refreshControl == nil && self.refreshView == nil;
}

- (void)beginRefreshing {
	_reloading = YES;
	if (self.tableViewController) {
		[self.tableViewController.refreshControl beginRefreshing];
		if (self.tableView.contentOffset.y >= 0) {
			[self.tableView setContentOffset:CGPointMake(0, -44.f) animated:YES];
		}
	}
	else {
		[self.refreshView beginRefreshing];
	}
}

-(void)endRefreshing {
	_reloading = NO;
	if (self.tableViewController) {
		[self.tableViewController.refreshControl endRefreshing];
	}
	else {
		[self.refreshView endRefreshing];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self.refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource {
	assert(NO); // You need to override
}

@end


@interface EPCTableViewRefreshView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EPCTableViewRefreshView

#pragma mark - Public

- (void)beginRefreshing {
	[self triggerRefreshState:(UITableView*)self.superview];
}
- (void)endRefreshing {
	[self egoRefreshScrollViewDataSourceDidFinishedLoading:(UITableView*)self.superview];
}

#pragma mark - Overriding ScrollView Delegate

- (int)offsetHeight {
	if (_offsetHeight > 0) {
		return _offsetHeight;
	}
	return 60;
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	if (scrollView.contentOffset.y <= - ([self offsetHeight]+5) && !_loading) {
		[self triggerRefreshState:(UIScrollView*)scrollView];
	}
}
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == EGOOPullRefreshLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, ([self offsetHeight]));
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -([self offsetHeight]+5) && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -([self offsetHeight]+5) && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}
- (void)triggerRefreshState:(UIScrollView*)scrollView {
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
		[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
	}
	[self setState:EGOOPullRefreshLoading];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	scrollView.contentInset = UIEdgeInsetsMake(([self offsetHeight]), 0.0f, 0.0f, 0.0f);
	[UIView commitAnimations];
}


#pragma mark - Nib Support
- (void)awakeFromNib {
	[super awakeFromNib];
	_offsetHeight = self.frame.size.height;
}
- (void)setStatusLabel:(UILabel *)statusLabel {
	self->_statusLabel = statusLabel;
}
- (UILabel *)statusLabel {
	return self->_statusLabel;
}
- (void)setActivityView:(UIActivityIndicatorView *)activityView {
	self->_activityView = activityView;
}
- (UIActivityIndicatorView *)activityView {
	return self->_activityView;
}
- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	if (self.arrowDownImageView) {
		CALayer *layer = [CALayer layer];
		layer.frame = self.arrowDownImageView.frame;;
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)self.arrowDownImageView.image.CGImage;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[self.layer addSublayer:layer];
		self->_arrowImage = layer;
		[self.arrowDownImageView removeFromSuperview];
		self.arrowDownImageView = nil;
	}
}
@end
