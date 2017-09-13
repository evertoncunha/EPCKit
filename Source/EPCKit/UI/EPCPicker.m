//
//
//

#import "EPCPicker.h"

@interface EPCPicker() {
	UIActionSheet *_actionSheet;
	UIPickerView *_pickerView;
	UIPopoverController *_popoverCont;
	
}
@property(nonatomic,copy) void (^completion)(id, NSInteger);
@end


@implementation EPCPicker

- (id)initWithHandler:(void (^)(id, NSInteger))handler {
	self = [super init];
	if (handler != NULL) {
		self.completion = handler;
	}
	return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

-(void)selected:(UIBarButtonItem *)item
{
	if (_pickerType==kPickerDate) {
		_date= [(UIDatePicker *)_pickerView date];
		self.completion(_date, NSNotFound);
	}
	else {
		self.completion([self.items objectAtIndex:self.selectedRow], self.selectedRow);
	}
	
	[self hidePicker];
}

-(void)cancel
{
	[self hidePicker];
}

-(void)hidePicker
{
	[_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	_actionSheet = nil;
	_pickerView = nil;
}

-(void)showInView:(UIView *)superview
{
	[[self actionSheet] showInView:superview];
	[_actionSheet setBounds:CGRectMake(0, 0, 320, 500)];
}

- (void)showFromTabBar:(UITabBar *)tabBar {
	[[self actionSheet] showFromTabBar:tabBar];
	[_actionSheet setBounds:CGRectMake(0, 0, 320, 367)];
}

- (UIPickerView*)thePickerView {
	id pickerView;
	
	if (kPickerDate == _pickerType) {
		UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 32, 0, 0)];
		datePicker.datePickerMode = UIDatePickerModeDate;
		
		datePicker.minimumDate = self.minimumDate;
		datePicker.maximumDate = self.maximumDate;
		if (self.date) {
			datePicker.date = self.date;
		}
		else {
			datePicker.date = self.startDate;
		}
		
		pickerView = datePicker;
	}
	
	if (kPickerItem == _pickerType) {
		UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 32, 0, 0)];
		[picker setDelegate:self];
		[picker setDataSource:self];
		[picker setShowsSelectionIndicator:YES];
		
		[picker selectRow:self.selectedRow inComponent:0 animated:NO];
		
		pickerView = picker;
	}
	return pickerView;
}

- (UIActionSheet*)actionSheet {
	if (!_actionSheet) {
		
		int width = 320;
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
		
				
		_pickerView = [self thePickerView];
		
		[actionSheet addSubview:_pickerView];
		
		
		UISegmentedControl *selectButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Selecionar"]];
		selectButton.segmentedControlStyle = UISegmentedControlStyleBar;
		[selectButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
		[actionSheet addSubview:selectButton];
		selectButton.frame = CGRectMake(width - 90, 4.f, 80.0f, 26.0f);
		if (self.selectTintColor) {
			selectButton.tintColor = self.selectTintColor;
		}
		
		
		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancelar"]];
		closeButton.frame = CGRectMake(10, 4.f, 80.0f, 26.0f);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		if (self.closeTintColor) {
			closeButton.tintColor = self.closeTintColor;
		}
		else {
			closeButton.tintColor = [UIColor grayColor];
		}
		[closeButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventValueChanged];
		
		[actionSheet addSubview:closeButton];
		
		[actionSheet setBounds:CGRectMake(0, 0, width, 367)];
		
		_actionSheet = actionSheet;
	}
	return _actionSheet;
}

#pragma mark - PickerView Delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [self.items objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.selectedRow = row;
}

#pragma mark - IPAD

- (void)showFromCGRect:(CGRect)rect inView:(UIView*)view  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirection {
	
	if (!_popoverCont) {
		UIViewController *sortViewController = [[UIViewController alloc]init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sortViewController];
		
		UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(popOverCancelled)];
		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popOverIsDone)];
		
		if (self.selectTintColor) {
			done.tintColor = self.selectTintColor;
		}
		if (self.closeTintColor) {
			cancel.tintColor = self.closeTintColor;
		}
		
		sortViewController.navigationItem.leftBarButtonItem = cancel;
		sortViewController.navigationItem.rightBarButtonItem = done;
		
		_pickerView = [self thePickerView];
		sortViewController.view = _pickerView;
		sortViewController.contentSizeForViewInPopover = _pickerView.bounds.size; //CGSizeMake(260, 162);
		
		_popoverCont = [[UIPopoverController alloc] initWithContentViewController:navController];
		
	}
    [_popoverCont presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirection animated:YES];
}

-(void)popOverIsDone {
	if (_pickerType==kPickerDate) {
		_date= [(UIDatePicker *)_pickerView date];
		self.completion(_date, NSNotFound);
	}
	else {
		self.completion([self.items objectAtIndex:self.selectedRow], self.selectedRow);
	}
	[_popoverCont dismissPopoverAnimated:YES];
}

- (void)popOverCancelled {
	[_popoverCont dismissPopoverAnimated:YES];
}
@end
