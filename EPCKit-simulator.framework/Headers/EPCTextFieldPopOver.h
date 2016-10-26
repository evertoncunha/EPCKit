//
//  EPCTextFieldPopOver.h
//  EPCKit
//
//  Created by Everton Cunha on 23/02/16.
//  Copyright © 2016 Everton Cunha. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	EPCTextFieldPopOverStyleNumber = 0,
	EPCTextFieldPopOverStyleCurrency = 1,
	EPCTextFieldPopOverStylePercent = 2
} EPCTextFieldPopOverStyle;

@interface EPCTextFieldPopOver : UITextField <UITextFieldDelegate, UIPopoverControllerDelegate>

@property (nonatomic) NSNumberFormatter *numberFormatter;

@property (nonatomic) NSInteger lengthLimit;

@property (nonatomic) EPCTextFieldPopOverStyle style;

@property (copy) void(^handlerChangeTextBlock)(EPCTextFieldPopOver*);

@property (copy) void (^didDismissKeyboardBlock)(EPCTextFieldPopOver* txtField);

@property (copy) void (^keyboardWillAppearBlock)(EPCTextFieldPopOver* txtField);

@property (nonatomic) UIColor *keyboardKeyTextColor;

@property (nonatomic) UIColor *keyboardKeyBackgroundColor;

@property (nonatomic) UIColor *keyboardKeyBackgroundHighlightedColor;

@property (nonatomic) UIPopoverArrowDirection permittedArrowDirections;

- (NSNumber*)value;

- (void)setValue:(NSNumber*)value;

@end

@interface EPCTextFieldPopOverButton : UIButton

@property (nonatomic) UIColor *layerBackgroundColor;

@property (nonatomic) UIColor *layerBackgroundHighlightedColor;

@end
