//
//  EPCPopOverDateButton.m
//  Ramarim-iOS
//
//  Created by Everton Cunha on 22/11/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import "EPCPopOverDateButton.h"

@implementation EPCPopOverDateButton

- (void)dealloc
{
    self.popOverTitle = nil;
    [super dealloc];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self addTarget:self action:@selector(showPopOver) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showPopOver {
	self.selected = YES;
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]; // esconde teclado se aberto
	
	UIDatePicker *filterPickerView = nil;
	
	assert(_popOverWidth > 0);
	assert(_permittedArrowDirections != 0);
	assert(_datePickerMode != 0);
	
	if (!_filterPopOver) {
		
		int width = _popOverWidth;
		
		UIViewController *sortViewController = [[UIViewController alloc]init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sortViewController];
		
		filterPickerView = [[UIDatePicker alloc] init];
		filterPickerView.frameWidth = width;
		filterPickerView.datePickerMode = _datePickerMode;
		
		
		sortViewController.navigationItem.title = _popOverTitle;
		
		sortViewController.view = filterPickerView;
		sortViewController.contentSizeForViewInPopover = CGSizeMake(width, 162);
		_filterPopOver = [[UIPopoverController alloc] initWithContentViewController:navController];
		_filterPopOver.delegate = self;
		
		[filterPickerView release];
		[sortViewController release];
		[navController release];
		
		[filterPickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	}
	
	_datePicker = filterPickerView;
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverDateButtonDelegate:minimumDateForDatePicker:)]) {
		[filterPickerView setMinimumDate:[self.delegate epcPopOverDateButtonDelegate:self minimumDateForDatePicker:filterPickerView]];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverDateButtonDelegate:maximumDateForDatePicker:)]) {
		[filterPickerView setMaximumDate:[self.delegate epcPopOverDateButtonDelegate:self maximumDateForDatePicker:filterPickerView]];
	}
	
    [_filterPopOver presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:self.permittedArrowDirections animated:YES];
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverDateButtonDelegate:didPresentDatePicker:popOverController:)]) {
		[self.delegate epcPopOverDateButtonDelegate:self didPresentDatePicker:filterPickerView popOverController:_filterPopOver];
	}
}

- (void)dateChanged:(UIDatePicker*)datePicker {
	if ([self.delegate respondsToSelector:@selector(epcPopOverDateButtonDelegate:dateChangedOfDatePicker:)]) {
		[self.delegate epcPopOverDateButtonDelegate:self dateChangedOfDatePicker:datePicker];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.selected = NO;
	if ([self.delegate respondsToSelector:@selector(epcPopOverDateButtonDelegate:dismissedPopOverController:datePicker:)]) {
		[self.delegate epcPopOverDateButtonDelegate:self dismissedPopOverController:popoverController datePicker:_datePicker];
	}
	
	_datePicker = nil;
	[_filterPopOver release];
	_filterPopOver = nil;
}

@end
