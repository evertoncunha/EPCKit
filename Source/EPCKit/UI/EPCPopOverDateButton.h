//
//  EPCPopOverDateButton.h
//  Ramarim-iOS
//
//  Created by Everton Cunha on 22/11/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPCPopOverDateButton;

@protocol EPCPopOverDateButtonDelegate <NSObject>
@optional
- (void)epcPopOverDateButtonDelegate:(EPCPopOverDateButton*)epcPopOverDateButton dateChangedOfDatePicker:(UIDatePicker*)datePicker;

- (void)epcPopOverDateButtonDelegate:(EPCPopOverDateButton*)epcPopOverDateButton dismissedPopOverController:(UIPopoverController*)popOverController datePicker:(UIDatePicker*)datePicker;
- (NSDate*)epcPopOverDateButtonDelegate:(EPCPopOverDateButton*)epcPopOverDateButton minimumDateForDatePicker:(UIDatePicker*)datePicker;
- (NSDate*)epcPopOverDateButtonDelegate:(EPCPopOverDateButton*)epcPopOverDateButton maximumDateForDatePicker:(UIDatePicker*)datePicker;
- (void)epcPopOverDateButtonDelegate:(EPCPopOverDateButton*)epcPopOverDateButton didPresentDatePicker:(UIDatePicker*)datePicker popOverController:(UIPopoverController*)popOverController;
@end

@interface EPCPopOverDateButton : UIButton <UIPopoverControllerDelegate> {
	UIPopoverController *_filterPopOver;
	UIDatePicker *_datePicker;
}

@property (readwrite) UIPopoverArrowDirection permittedArrowDirections;
@property (assign) IBOutlet id<EPCPopOverDateButtonDelegate> delegate;
@property (readwrite) float popOverWidth;
@property (copy) NSString *popOverTitle;
@property (readwrite) UIDatePickerMode datePickerMode;
@end
