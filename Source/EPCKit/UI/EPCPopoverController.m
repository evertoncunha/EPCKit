//
//  UIPopoverControllerWithTableView.m
//
//  Created by Everton Cunha on 10/11/14.
//

#import "EPCPopoverController.h"
#import "EPCCategories.h"
#import "EPCDefines.h"

@interface EPCPopoverController() <UIPopoverControllerDelegate> {
	UITableViewController *_tableViewController;
	UIDatePicker *_datePicker;
	UIViewController *_viewController;
	NSIndexPath *_lastSelectedRow;
	
	BOOL _didRelease;
	
	__weak UIView *_viewWithoutInteraction;
	
	BOOL _didSetcellSelectionStyle;
}

@property (copy) void(^didSelectRowBlock)(EPCPopoverController *popOverController, UITableView *tableView, NSArray *indexPaths);
@property (copy) void(^datePickerBlock)(EPCPopoverController *popOverController, NSDate *date);
@end

@implementation EPCPopoverController

#pragma mark - TEXT

- (instancetype)initWithContentViewController:(UIViewController *)viewController {
	self = [super initWithContentViewController:viewController];
	
	if (self) {
		CFRetain((__bridge CFTypeRef)(self));
		self.delegate = self;
	}
	
	return self;
}

- (instancetype)initWithText:(NSString *)text width:(float)width {
	return [self initWithText:text width:width font:nil];
}

- (instancetype)initWithText:(NSString *)text width:(float)width font:(UIFont*)font {
	if (text.length == 0) {
		text = @"Sem texto para exibir.";
	}
	
	UIViewController *controller = [[UIViewController alloc] init];
	
	CGSize viewSize = CGSizeMake(width, 300);
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 1, 1)];
	label.numberOfLines = 0;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	self.textFont = font;
	if (font) {
		label.font = font;
	}
	label.text = text;
	
	CGSize labelSize = [label sizeThatFits:viewSize];
	label.frameSize = labelSize;
	controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	
	controller.view.frameSize = CGSizeMake(16+labelSize.width, 16+labelSize.height);
	
	controller.preferredContentSize = controller.view.frameSize;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:controller.view.bounds];
	[scrollView addSubview:label];
	CGSize contentSize = label.frameSize;
	contentSize.height += 16;
	[scrollView setContentSize:contentSize];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	[controller.view addSubview:scrollView];
	
	self = [self initWithContentViewController:controller];
	
	if (self) {
		
		_viewController = controller;
	
	}
	
	return self;

}

- (instancetype)initWithText:(NSString *)text {
	return [self initWithText:text width:300.0];
}

- (instancetype)initWithView:(UIView *)view {
	
	UIViewController *controller = [[UIViewController alloc] init];
	controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	
	CGSize viewSize = view.frameSize;
	
	controller.view.frameSize = CGSizeMake(16+viewSize.width, 16+viewSize.height);
	
	controller.preferredContentSize = controller.view.frameSize;
	
	view.frameOrigin = CGPointMake(8, 8);
	
	[controller.view addSubview:view];
	
	self = [self initWithContentViewController:controller];
	
	if (self) {
		_viewController = controller;
	}
	
	return self;
}


#pragma mark - TABLEVIEW

- (instancetype)initWithStyle:(UITableViewStyle)style tableViewData:(NSArray*)tableViewData stringSelector:(SEL)stringSelector width:(CGFloat)width tableViewSelection:(void(^)(EPCPopoverController *popOverController, UITableView *tableView, NSArray *indexPaths))didSelectRowBlock {
	
	UITableViewController *controller = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	controller.tableView.dataSource = self;
	controller.tableView.delegate = self;
	
	self = [self initWithContentViewController:controller];
	
	if (self) {
		
		_tableViewController = controller;
		
		_stringSelector = stringSelector;
		
		self.tableViewData = tableViewData;
		
		self.didSelectRowBlock = didSelectRowBlock;
		
		self.tableViewWidth = width;
		
		self.cellCheckmarkEnabled = YES;
		
	}
	
	return self;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
	_tableViewController.tableView.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection {
	return _tableViewController.tableView.allowsMultipleSelection;
}

- (UITableViewController *)tableViewController {
	return _tableViewController;
}
#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.selectableData) {
		if (![self.selectableData containsObject:self.tableViewData[indexPath.row]]) {
			return;
		}
	}
	
	if (self.cellCheckmarkEnabled) {
		
		if (_lastSelectedRow && !self.allowsMultipleSelection) {
			
			if (self.singleSelectionAllowsDeselection || [_lastSelectedRow compare:indexPath]!=NSOrderedSame) {
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:_lastSelectedRow];
				[tableView deselectRowAtIndexPath:_lastSelectedRow animated:YES];
				cell.accessoryType = UITableViewCellAccessoryNone;
				_lastSelectedRow = nil;
			}
			
		}
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
	}
	
	if (self.didSelectRowBlock) {
		self.didSelectRowBlock(self, tableView, [self arrayForSelectedIndexPaths]);
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.cellCheckmarkEnabled) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	if (self.didSelectRowBlock) {
		self.didSelectRowBlock(self, tableView, [self arrayForSelectedIndexPaths]);
	}
}

- (UITableViewCell*)newCellWithIdentifier:(NSString*)iden {
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *iden = @"iden";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
	
	if (!cell) {
		cell = [self newCellWithIdentifier:iden];
		if (self.textFont) {
			cell.textLabel.font = self.textFont;
		}
		if (_didSetcellSelectionStyle) {
			cell.selectionStyle = self.cellSelectionStyle;
		}
	}
	
	NSString *theString = nil;
	
	if (self.stringSelector != nil) {
		id obj = self.tableViewData[indexPath.row];
		IMP imp = [obj methodForSelector:self.stringSelector];
		NSString * (*func)(id, SEL) = (void *)imp;
		theString = func(obj, self.stringSelector);
	}
	else {
		theString = self.tableViewData[indexPath.row];
		
		NSAssert([theString isKindOfClass:[NSString class]], @"%@ is not a NSString. At: %@ %s", theString, NSStringFromClass([self class]), __PRETTY_FUNCTION__);
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (self.cellCheckmarkEnabled) {
		if (self.allowsMultipleSelection) {
			cell.accessoryType = UITableViewCellAccessoryNone;
			if ([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		}
		else {
			
			NSIndexPath *sl = [tableView indexPathForSelectedRow];
			if ((sl && [sl compare:indexPath] == NSOrderedSame) || (_lastSelectedRow && [_lastSelectedRow compare:indexPath] == NSOrderedSame)) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		}
	}

	if ([self.cellImages count] > indexPath.row) {
		UIImage *img = self.cellImages[indexPath.row];
		cell.imageView.image = img;
	}
	else {
		cell.imageView.image = nil;
	}
	
	cell.textLabel.text = theString;
	
	if (self.selectableData) {
		if ([self.selectableData containsObject:self.tableViewData[indexPath.row]]) {
			cell.selectionStyle =  UITableViewCellSelectionStyleDefault;
			cell.textLabel.textColor = [UIColor blackColor];
		}
		else {
			cell.selectionStyle =  UITableViewCellSelectionStyleNone;
			cell.textLabel.textColor = UIColorFromRGB(0x808080);
		}
		
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tableViewData count];
}

- (CGSize)contentSizeForTableViewController {
	CGFloat width = [self calculateWidth];
	if (width < self.tableViewWidth) {
		width = self.tableViewWidth;
	}
	CGRect rect = [_tableViewController.tableView rectForSection:[_tableViewController.tableView numberOfSections] - 1];
	CGFloat height = CGRectGetMaxY(rect);
	return (CGSize){width, height};
}

- (CGFloat)calculateWidth {
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"iden"];
	UILabel *label = cell.textLabel;
	
	CGFloat maxWidth = [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] bounds].size.width;
	if (self.cellCheckmarkEnabled) {
		maxWidth -= 50; // accessory discount
	}
	
	CGFloat cellMargins = 20;
	maxWidth -= cellMargins; // margins
	
	NSInteger width = 0;
	
	UIFont *font = nil;
	
	if (self.textFont) {
		font = self.textFont;
	}
	else {
		font = label.font;
	}
	
	CGFloat labelHeight = label.frameHeight;
	
	for (id obj in self.tableViewData) {
		NSString *str = nil;
		if (self.stringSelector) {
			str = [obj objectForSelector:self.stringSelector];
		}
		else {
			str = obj;
		}
		
		CGRect rect = [str boundingRectWithSize:CGSizeMake(maxWidth, labelHeight)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:font}
												  context:nil];
		width = MAX(width, rect.size.width);
	}
	
	if (self.cellCheckmarkEnabled) {
		width += 50;
	}
	
	width += cellMargins;
	
	return width;
}

#pragma mark - DatePicker

- (instancetype)initWithDatePickerMode:(UIDatePickerMode)pickerMode minimumDate:(NSDate*)minimunDate maximumDate:(NSDate*)maximumDate selectedDate:(NSDate*)selectedDate datePickerValueChanged:(void(^)(EPCPopoverController *popOverController, NSDate *date))block {
	
	return [self initWithDatePickerMode:pickerMode minimumDate:minimunDate maximumDate:maximumDate selectedDate:selectedDate bottomView:nil datePickerValueChanged:block];
}

- (instancetype)initWithDatePickerMode:(UIDatePickerMode)pickerMode minimumDate:(NSDate*)minimunDate maximumDate:(NSDate*)maximumDate selectedDate:(NSDate*)selectedDate bottomView:(UIView*)bottomView datePickerValueChanged:(void(^)(EPCPopoverController *popOverController, NSDate *date))block {
	return [self initWithDatePickerMode:pickerMode locale:nil minimumDate:minimunDate maximumDate:maximumDate selectedDate:selectedDate bottomView:bottomView datePickerValueChanged:block];
}

- (instancetype)initWithDatePickerMode:(UIDatePickerMode)pickerMode locale:(NSLocale*)locale minimumDate:(NSDate*)minimunDate maximumDate:(NSDate*)maximumDate selectedDate:(NSDate*)selectedDate bottomView:(UIView*)bottomView datePickerValueChanged:(void(^)(EPCPopoverController *popOverController, NSDate *date))block {
	
	UIViewController *controller = [[UIViewController alloc] init];
	
	self = [self initWithContentViewController:controller];
	
	if (self) {
		
		_viewController = controller;
		
		_datePicker = [[UIDatePicker alloc] init];
		_datePicker.datePickerMode = pickerMode;
		if (minimunDate) {
			_datePicker.minimumDate = minimunDate;
		}
		if (maximumDate) {
			_datePicker.maximumDate = maximumDate;
		}
		if (selectedDate) {
			_datePicker.date = selectedDate;
		}
		if (locale) {
			_datePicker.locale = locale;
		}
		
		
		CGRect frame = _datePicker.bounds;
		frame.size.height+=bottomView.bounds.size.height;
		controller.view.frame = frame;
		[controller.view addSubview:_datePicker];
		
		if (bottomView) {
			CGRect fra = bottomView.frame;
			fra.origin.y = _datePicker.bounds.size.height;
			fra.size.width = _datePicker.bounds.size.width;
			bottomView.frame = fra;
			[controller.view addSubview:bottomView];
		}
		
		[self setPopoverContentSize:controller.view.frameSize];
		
		[_datePicker addTarget:self action:@selector(datePickerChangedDate) forControlEvents:UIControlEventValueChanged];
		
		self.datePickerBlock = block;
	}
	
	return self;
}

- (void)datePickerChangedDate {
	self.datePickerBlock(self, _datePicker.date);
}

- (UIDatePicker *)datePicker {
	return _datePicker;
}

#pragma mark - Present

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
	
	_viewWithoutInteraction = view;
	[_viewWithoutInteraction setUserInteractionEnabled:NO];
	
	if (_tableViewController) {
		[self setPopoverContentSize:[self contentSizeForTableViewController]];
	}
	
	[super presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}

- (void)presentInWindowRootViewControllerFromView:(UIView*)sender permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
	
	UIView *windowRootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
	
	_viewWithoutInteraction = windowRootView;
	[_viewWithoutInteraction setUserInteractionEnabled:NO];
	
	[self presentPopoverFromRect:[windowRootView convertRect:sender.bounds fromView:sender] inView:windowRootView permittedArrowDirections:arrowDirections animated:animated];
}

- (void)presentInWindowRootViewControllerFromView:(UIView*)sender rect:(CGRect)rect permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
	
	UIView *windowRootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
	
	_viewWithoutInteraction = windowRootView;
	[_viewWithoutInteraction setUserInteractionEnabled:NO];
	
	[self presentPopoverFromRect:[windowRootView convertRect:rect fromView:sender] inView:windowRootView permittedArrowDirections:arrowDirections animated:animated];
}

#pragma mark - Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	
	if (self.didDismissPopoverBlock) {
		self.didDismissPopoverBlock();
	}
	
	if (!_didRelease) {
		_didRelease = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			CFRelease((__bridge CFTypeRef)(self));
		});
	}
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	
	_viewWithoutInteraction.userInteractionEnabled = YES;
	
	if (self.willDismissPopoverBlock) {
		self.willDismissPopoverBlock(self, [self arrayForSelectedIndexPaths]);
	}
	return YES;
}

- (NSArray*)arrayForSelectedIndexPaths {
	NSArray *arr = nil;
	if (self.allowsMultipleSelection) {
		arr = [_tableViewController.tableView indexPathsForSelectedRows];
	}
	else {
		NSIndexPath *ip = [_tableViewController.tableView indexPathForSelectedRow];
		if (ip) {
			arr = @[ip];
		}
	}
	return arr;
}

-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)position {
	UITableView *tableView = _tableViewController.tableView;
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	_lastSelectedRow = indexPath;
}

-(void)selectRowsAtIndexPaths:(NSMutableArray*)indexPaths {
	assert(_tableViewController.tableView.allowsMultipleSelection);
	UITableView *tableView = _tableViewController.tableView;
	for (NSIndexPath *ip in indexPaths) {
		[tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:ip];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
}

- (NSIndexPath*)indexPathForSelectedRow {
	return [_tableViewController.tableView indexPathForSelectedRow];
}

- (void)setSelectedObject:(id)object {
	if (object) {
		NSInteger index = NSNotFound;
		
		NSInteger i = 0;
		
		for (id obj in self.tableViewData) {
			if ([object isEqual:obj]) {
				index = i;
				NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
				[self selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionMiddle];
				break;
			}
			i++;
		}
	}
}

- (void)dismissPopoverAnimated:(BOOL)animated {
	[self popoverControllerShouldDismissPopover:self];
	[super dismissPopoverAnimated:animated];
	[self popoverControllerDidDismissPopover:self];
}

- (void)setCellSelectionStyle:(UITableViewCellSelectionStyle)cellSelectionStyle {
	_cellSelectionStyle = cellSelectionStyle;
	_didSetcellSelectionStyle = YES;
}
@end
