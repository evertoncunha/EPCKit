//
//  EPCComboBox.m
//
//  Created by Everton Postay Cunha on 28/06/11.
//

#import "EPCComboBox.h"


@implementation EPCComboBox

@synthesize delegate, indexOfSelectedRow, selectedView, open;

#pragma mark - Life Cycle

- (void)start {
	
	// ADD THE ARROW BUTTON
	
	button = [delegate comboBoxButtonForComboBox:self];
	button.frame = CGRectMake(self.bounds.size.width - button.frame.size.width, 0, button.frame.size.width, button.frame.size.height);
	[button addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchUpOutside];
	[self addSubview:button];
	
	
	// ADD FIRST ITEM BUTTON
	
	selectedViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectedViewButton.frame = CGRectMake(0, 0, self.bounds.size.width - button.frame.size.width, self.bounds.size.height);
	[selectedViewButton addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
	[selectedViewButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
	[selectedViewButton addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchUpOutside];
	selectedViewButton.adjustsImageWhenHighlighted = NO;
	[self addSubview:selectedViewButton];
	
	// TABLE VIEW
	
	CGRect tf;
	tf.origin.x = self.frame.origin.x;
	tf.origin.y = self.frame.origin.y + self.frame.size.height;
	tf.size.width = self.frame.size.width - button.frame.size.width;
	tf.size.height = self.superview.frame.size.height - tf.origin.y; 
	tableView = [[UITableView alloc] initWithFrame:tf];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.bounces = NO;
	tableView.backgroundColor = [UIColor clearColor];
	
	
	// ADD THE FIRST ROW VIEW
	
	indexOfSelectedRow = 0;
	
	self.selectedView = [delegate comboBox:self viewForSelectedItemWhileOpen:NO];
	
}

- (void)dealloc
{
	[tableView release];
	if (shadowView) {
		[shadowView release];
	}
    [super dealloc];
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [delegate comboBox:self tableView:_tableView viewForRowAtIndex:indexPath.row].bounds.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [delegate numberOfRowsForComboBox:self];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [delegate comboBox:self tableView:_tableView viewForRowAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self performSelector:@selector(hideList)];
	
	NSArray *indexPaths = nil;
	
	if (indexPath.row != indexOfSelectedRow) {
		NSIndexPath *oldIndex = [NSIndexPath indexPathForRow:indexOfSelectedRow inSection:0];
		indexPaths = [NSArray arrayWithObjects:indexPath, oldIndex, nil];
	} else {
		indexPaths = [NSArray arrayWithObject:indexPath];
	}
	
	indexOfSelectedRow = indexPath.row;
	self.selectedView = [delegate comboBox:self viewForSelectedItemWhileOpen:NO];
	
	[tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
	
	
	if ([delegate respondsToSelector:@selector(comboBox:didSelectedRowAtIndex:)]) {
		[delegate comboBox:self didSelectedRowAtIndex:indexPath.row];
	}
}

#pragma mark - Private

- (void)hideList {
	open = NO;
	
	self.selectedView = [delegate comboBox:self viewForSelectedItemWhileOpen:NO];
	[shadowView removeFromSuperview];
	[tableView removeFromSuperview];
}

- (void)showList {
	open = YES;
	
	self.selectedView = [delegate comboBox:self viewForSelectedItemWhileOpen:YES];
	[self.superview bringSubviewToFront:self];
	[self.superview addSubview:tableView];
	
	if (!shadowView) {
		shadowView = [[ComboListShadowView alloc] initWithFrame:self.superview.bounds];
		shadowView.comboBoxView = self;
	}
	[self.superview insertSubview:shadowView belowSubview:self];
}

#pragma mark - Actions

- (void)selectedButton:(UIButton*)btn {
	
	button.highlighted = NO;
	
	open ? [self hideList] : [self showList];
}

- (void)highlightButton:(id)sender {
	button.highlighted = YES;
	selectedViewButton.highlighted = YES;
}

- (void)unhighlightButton:(id)sender {
	button.highlighted = NO;
	selectedViewButton.highlighted = NO;
}

#pragma mark - Public

- (void)selectRowAtIndex:(int)index {
	NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
	[self tableView:tableView didSelectRowAtIndexPath:ip];
}

- (void)setSelectedView:(UIView *)newView {
	
	if ([selectedViewButton.subviews containsObject:self.selectedView]) {
		[self.selectedView removeFromSuperview];
	}
	
	selectedView = newView;
	
	newView.frame = selectedViewButton.bounds;
	newView.userInteractionEnabled = NO;
	[selectedViewButton addSubview:newView];
}

- (void)setDelegate:(id<EPCComboBoxDelegate>)dd {
	delegate = dd;
	[self start];
}

- (void)reloadData {
	[tableView reloadData];
}

- (void)close {
	if (open) {
		[self hideList];
	}
}

- (void)open {
	if (!open) {
		[self showList];
	}
}

- (void)touchedShadow {
	[self hideList];
}

@end



@implementation ComboListShadowView

@synthesize comboBoxView;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.comboBoxView performSelector:@selector(touchedShadow)];
}

@end


