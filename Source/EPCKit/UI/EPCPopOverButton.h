//
//  EPCPopOverButton.h
//  Ramarim-iOS
//
//  Created by Everton Cunha on 21/11/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPCPopOverButton;

@protocol EPCPopOverButtonDelegate <NSObject>
@required
-(NSInteger)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
-(NSInteger)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton numberOfComponentsInPickerView:(UIPickerView *)pickerView;

@optional

-(void)epcPopOverButton:(EPCPopOverButton *)epcpopOverButton willPresentPickerView:(UIPickerView*)pickerView;

-(BOOL)epcPopOverButton:(EPCPopOverButton *)epcPopOverButton rowIsDisabled:(NSInteger)row;

-(void)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;

-(NSString*)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton titleForRow:(NSInteger)row forComponent:(NSInteger)component;

-(void)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

-(UIView *)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)epcPopOverButton:(EPCPopOverButton*)epcPopOverButton didPresentPickerView:(UIPickerView*)pickerView popOverController:(UIPopoverController*)popOverController;
@end

@interface EPCPopOverButton : UIButton <UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate> {
	UIPopoverController *_filterPopOver;
}

@property (readwrite) UIPopoverArrowDirection permittedArrowDirections;
@property (assign) IBOutlet id<EPCPopOverButtonDelegate> delegate;
@property (readwrite) float popOverWidth;
@property (copy) NSString *popOverTitle;

- (void)showPopOver;

@end
