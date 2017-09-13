//
//  EPCPopOverButton.m
//  Ramarim-iOS
//
//  Created by Everton Cunha on 21/11/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import "EPCPopOverButton.h"

@implementation EPCPopOverButton

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
	
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]; // esconde teclado se aberto
	
	self.selected = YES;
	
	UIPickerView *filterPickerView = nil;
	
	assert(_popOverWidth > 0);
	assert(_permittedArrowDirections != 0);
	
	
	if (!_filterPopOver) {
		
		int width = _popOverWidth;
		
		UIViewController *sortViewController = [[UIViewController alloc]init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sortViewController];
		
		filterPickerView = [[UIPickerView alloc] init];
		filterPickerView.frameWidth = width;
		
		sortViewController.navigationItem.title = _popOverTitle;
		
		sortViewController.view = filterPickerView;
		sortViewController.contentSizeForViewInPopover = CGSizeMake(width, 162);
		filterPickerView.delegate = self;
		filterPickerView.dataSource = self;
		filterPickerView.showsSelectionIndicator = YES;
		_filterPopOver = [[UIPopoverController alloc] initWithContentViewController:navController];
		_filterPopOver.delegate = self;
		
		[filterPickerView release];
		[sortViewController release];
		[navController release];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverButton:willPresentPickerView:)]) {
		[self.delegate epcPopOverButton:self willPresentPickerView:filterPickerView];
	}
	
    [_filterPopOver presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:self.permittedArrowDirections animated:YES];
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverButton:didPresentPickerView:popOverController:)]) {
		[self.delegate epcPopOverButton:self didPresentPickerView:filterPickerView popOverController:_filterPopOver];
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

	if ([self.delegate respondsToSelector:@selector(epcPopOverButton:pickerView:didSelectRow:inComponent:)]) {
		if ([self.delegate respondsToSelector:@selector(epcPopOverButton:rowIsDisabled:)]) {
			if ([self.delegate epcPopOverButton:self rowIsDisabled:row]) {
				int numbersOfRows = [self.delegate epcPopOverButton:self pickerView:pickerView numberOfRowsInComponent:component];
				int nextValidRow = -1;
				// find next valid row
				for (int i = row+1; i < numbersOfRows; i++) {
					if (![self.delegate epcPopOverButton:self rowIsDisabled:i]) {
						nextValidRow = i;
						break;
					}
				}
				if (nextValidRow == -1) {
					// find previous valid row
					for (int i = row-1; i >= 0; i--) {
						if (![self.delegate epcPopOverButton:self rowIsDisabled:i]) {
							nextValidRow = i;
							break;
						}
					}
				}
				if (nextValidRow >= 0 && nextValidRow < numbersOfRows) {
					row = nextValidRow;
					[pickerView selectRow:nextValidRow inComponent:component animated:YES];
				}
			}
		}
		[self.delegate epcPopOverButton:self pickerView:pickerView didSelectRow:row inComponent:component];
	}
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.delegate epcPopOverButton:self pickerView:pickerView numberOfRowsInComponent:component];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [self.delegate epcPopOverButton:self numberOfComponentsInPickerView:pickerView];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.selected = NO;
	if ([self.delegate respondsToSelector:@selector(epcPopOverButton:popoverControllerDidDismissPopover:)]) {
		[self.delegate epcPopOverButton:self popoverControllerDidDismissPopover:popoverController];
	}
	[_filterPopOver release];
	_filterPopOver = nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	
	UIView *returnView = nil;
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverButton:pickerView:viewForRow:forComponent:reusingView:)]) {
		returnView = [self.delegate epcPopOverButton:self pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
		if (returnView) {
			return returnView;
		}
	}
	
	UILabel *label = nil;
	
	if ([view isKindOfClass:[UILabel class]]) {
		label = (id)view;
	}
	if ([returnView isKindOfClass:[UILabel class]]) {
		label = (id)returnView;
	}
	
	if (!label) {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(40, 0, pickerView.frameWidth-40, 44)] autorelease];
		label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.f];
		label.textAlignment = UITextAlignmentLeft;
		label.backgroundColor = [UIColor clearColor];
	}
	
	if ([self.delegate respondsToSelector:@selector(epcPopOverButton:rowIsDisabled:)]) {
		BOOL disabled = [self.delegate epcPopOverButton:self rowIsDisabled:row];
		if (disabled) {
			label.textColor = [UIColor grayColor];
		}
		else {
			label.textColor = [UIColor blackColor];
		}
	}
	
	// in this case it's not optional
	label.text = [self.delegate epcPopOverButton:self titleForRow:row forComponent:component];
	 
	return label;
}

@end
