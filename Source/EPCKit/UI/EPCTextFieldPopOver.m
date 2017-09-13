//
//  EPCTextFieldPopOver.m
//  EPCKit
//
//  Created by Everton Cunha on 23/02/16.
//  Copyright © 2016 Everton Cunha. All rights reserved.
//

#import "EPCTextFieldPopOver.h"
#import "EPCCategories.h"

@interface EPCTextFieldPopOver () {
	UIPopoverController
	*_tmpPopOver;
	
	NSMutableString
	*_realText;
	
	BOOL
	_changedArrowDirection;
}
@end

@implementation EPCTextFieldPopOver

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self start];
	}
	
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self start];
}

- (void)start {
	self.delegate = self;
	
	// dont display keyboard
	UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
	dummyView.backgroundColor = [UIColor clearColor];
	self.inputView = dummyView;
	
	_realText = [[NSMutableString alloc] initWithString:@""];
	
	if ([self respondsToSelector:@selector(inputAssistantItem)])
	{
		UITextInputAssistantItem *inputAssistantItem = [self inputAssistantItem];
		inputAssistantItem.leadingBarButtonGroups = @[];
		inputAssistantItem.trailingBarButtonGroups = @[];
	}
	
}

-(void)setDelegate:(id<UITextFieldDelegate>)delegate {
	[super setDelegate:self];
}

#pragma mark - TEXTFIELD DELEGATE

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	[self showPopOver];
	
	return YES;
}

#pragma mark - POPOVER DELEGATE

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	
	if (self.didDismissKeyboardBlock) {
		self.didDismissKeyboardBlock(self);
	}
	
	_tmpPopOver = nil;
	[self resignFirstResponder];
}

#pragma mark - OTHERS

- (void)showPopOver {
	_tmpPopOver = [[UIPopoverController alloc] initWithContentViewController:[self viewControllerForPopOver]];
	_tmpPopOver.delegate = self;
	CGRect fra = self.frame;
	fra.size.width +=10;
	fra.origin.x-=5;
	
	UIPopoverArrowDirection arrow = UIPopoverArrowDirectionAny;
	if (_changedArrowDirection) {
		arrow = self.permittedArrowDirections;
	}
	
	if (self.keyboardWillAppearBlock) {
		self.keyboardWillAppearBlock(self);
	}
	
	[_tmpPopOver presentPopoverFromRect:fra inView:self.superview permittedArrowDirections:arrow animated:YES];
}

- (UIViewController*)viewControllerForPopOver {
	UIViewController *viewC = [[UIViewController alloc] init];
	
	CGRect frame = CGRectMake(0, 0, 196, 260);
	viewC.view.frame = frame;
	
	viewC.preferredContentSize = frame.size;
	
	int margin = 4;
	
	int size = 60;
	
	CGRect bfra = CGRectMake(frame.size.width-(margin+size), margin, size, size);
	
	for (int i = 9; i >= 0; i--) {
		
		UIButton *btn = [self keyButton];
		
		if (i==0) {
			bfra.origin.x = margin;
		}
		
		btn.frame = bfra;
		
		if (i == 0) {
			btn.frameWidth+=bfra.size.width+margin;
			bfra.origin.x += btn.frameWidth + margin;
		}
		
		[btn setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
		
		[btn addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
		
		[viewC.view addSubview:btn];
		
		if (i!=0 && (i-1)%3 == 0) {
			bfra.origin.x=frame.size.width-(margin+size);
			bfra.origin.y+=bfra.size.height + margin;
		}
		else {
			if (i != 0) {
				bfra.origin.x-=bfra.size.width + margin;
			}
		}
	}
	
	UIButton *btn = [self keyButton];
	btn.frame = bfra;
	UIImage *img = [UIImage imageNamed:@"btn-keyboard-del"];
	[btn setImage:img forState:UIControlStateNormal];
	[btn setImage:[img imageTintedWithColor:self.keyboardKeyTextColor] forState:UIControlStateHighlighted];
	[viewC.view addSubview:btn];
	[btn addTarget:self action:@selector(tappedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
	
	
	viewC.view.frameWidth += 20;
	viewC.view.frameHeight += 20;
	viewC.preferredContentSize = viewC.view.frame.size;
	for (UIView *v in viewC.view.subviews) {
		v.frameX += 10;
		v.frameY+= 10;
	}
	return viewC;
	
}

- (UIButton*)keyButton {
	EPCTextFieldPopOverButton *btn = [EPCTextFieldPopOverButton buttonWithType:UIButtonTypeCustom];
	
	[btn.layer setBackgroundColor:[self.keyboardKeyBackgroundColor CGColor]];
	[btn.layer setCornerRadius:8.0f];
	
	btn.layerBackgroundHighlightedColor = self.keyboardKeyBackgroundHighlightedColor;
	btn.layerBackgroundColor = self.keyboardKeyBackgroundColor;
	
	[[self class] applyShadowInLayer:btn.layer];
	
	UIFont *font = [UIFont systemFontOfSize:55];
	assert(font);
	[btn.titleLabel setFont:font];
	
	[btn setTitleColor:self.keyboardKeyTextColor forState:UIControlStateHighlighted];
	
	return btn;
}

+ (void)applyShadowInLayer:(CALayer *)layer {
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(-3, 3);
	layer.shadowRadius = 3;
	layer.shadowOpacity = 0.6;
}

- (void)tappedButton:(UIButton*)button {
	
	if (_realText.length < self.lengthLimit || self.lengthLimit == 0) {
		
		NSString *s = [self valueForKeyButton:button];
		if (_realText.length == 1 && [self.value doubleValue] == 0 && [s doubleValue] == 0) {
			
		}
		else {
			
			[self deleteZerosAtLeft];
			
			[_realText appendString:s];
			
			[self updateText];
		}
	}
}

- (void)tappedDeleteButton:(UIButton*)button {
	if (_realText.length > 0) {
		
		if (_realText.length==1 && ![_realText isEqualToString:@"0"]) {
			[_realText insertString:@"0" atIndex:0];
		}
		
		[_realText deleteCharactersInRange:NSMakeRange(_realText.length-1, 1)];
		
	}
	
	[self updateText];
	
	if (_handlerChangeTextBlock) {
		_handlerChangeTextBlock((id)self);
	}
}

- (void)updateText {
	
	if (_realText.length == 0) {
		self.text = nil;
	}
	else {
		NSDecimalNumber *decimal = [self decimalNumberFromText:_realText];
		
		self.text = [self.numberFormatter stringFromNumber:decimal];
	}
	
	if (_handlerChangeTextBlock) {
		_handlerChangeTextBlock((id)self);
	}
}

- (NSNumber *)value {
	
	if (self.text.length>0) {
		return [self.numberFormatter numberFromString:self.text];
	}
	
	return [self.numberFormatter numberFromString:self.placeholder];
}

- (void)setValue:(NSNumber *)value {
	self.text = [self.numberFormatter stringFromNumber:value];
	NSString * strippedNumber = [self.text stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [self.text length])];
	NSMutableString *rt = [NSMutableString stringWithString:strippedNumber];
	_realText = rt;
	[self deleteZerosAtLeft];
}

- (void)deleteZerosAtLeft {
	while (_realText.length>0 && [[_realText substringToIndex:1] isEqualToString:@"0"]) {
		[_realText deleteCharactersInRange:NSMakeRange(0, 1)];
	}
}

- (UIColor *)keyboardKeyTextColor {
	if (!_keyboardKeyTextColor) {
		return [UIColor whiteColor];
	}
	return _keyboardKeyTextColor;
}

- (UIColor *)keyboardKeyBackgroundColor {
	if (!_keyboardKeyBackgroundColor) {
		return [UIColor lightGrayColor];
	}
	return _keyboardKeyBackgroundColor;
}

- (UIColor *)keyboardKeyBackgroundHighlightedColor {
	if (!_keyboardKeyBackgroundHighlightedColor) {
		return [UIColor grayColor];
	}
	return _keyboardKeyBackgroundHighlightedColor;
}

- (NSNumberFormatter *)numberFormatter {
	if (!_numberFormatter) {
		
		_numberFormatter = [[NSNumberFormatter alloc] init];
		[_numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"pt_BR"]];
		
		switch (self.style) {
			case EPCTextFieldPopOverStyleNumber:
				[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
				break;
			case EPCTextFieldPopOverStyleCurrency:
				[_numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[_numberFormatter setCurrencySymbol:@"R$ "];
				[_numberFormatter setRoundingMode:NSNumberFormatterRoundDown];
				break;
			case EPCTextFieldPopOverStylePercent:
				[_numberFormatter setRoundingMode:NSNumberFormatterRoundDown];
				[_numberFormatter setPositiveSuffix:@"%"];
				[_numberFormatter setMaximumFractionDigits:2];
				[_numberFormatter setMinimumIntegerDigits:1];
				[_numberFormatter setMinimumFractionDigits:2];
				break;
			default:
				break;
		}
	}
	return _numberFormatter;
}

- (NSString*)valueForKeyButton:(UIButton*)button {
	return [button titleForState:UIControlStateNormal];
}

- (NSDecimalNumber*)decimalNumberFromText:(NSString*)text {
	if (self.style == EPCTextFieldPopOverStyleNumber) {
		return [NSDecimalNumber decimalNumberWithString:text];
	}
	return [[NSDecimalNumber decimalNumberWithString:text] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
}

- (void)setPermittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
	_changedArrowDirection = YES;
	_permittedArrowDirections = permittedArrowDirections;
}

@end


@implementation EPCTextFieldPopOverButton

- (void)setHighlighted:(BOOL)highlighted{
	[super setHighlighted:highlighted];
	
	if (highlighted) {
		self.layer.backgroundColor = [self.layerBackgroundHighlightedColor CGColor];
	}
	else{
		self.layer.backgroundColor = [self.layerBackgroundColor CGColor];
	}
	[EPCTextFieldPopOver applyShadowInLayer:self.layer];
}

@end