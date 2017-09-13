//
//
//

#import <UIKit/UIKit.h>

typedef void(^EPCPickerBlock)(id value, NSInteger row);

typedef enum
{
	kPickerItem,
	kPickerDate
} PickerType;

@interface EPCPicker : NSObject<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, readwrite) NSInteger selectedRow;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, readwrite) PickerType pickerType;
@property (nonatomic, strong) UIColor *selectTintColor, *closeTintColor;

// date picker
@property (nonatomic, strong) NSDate *minimumDate, *maximumDate, *startDate;
@property (nonatomic, readonly) NSDate* date;


/*
 NSDate, NSNotFound
 or items[row], row
 */
- (id)initWithHandler:(void(^)(id value, NSInteger row))handler;


-(void)showInView:(UIView*)view;
-(void)showFromTabBar:(UITabBar*)tabBar;
-(void)showFromCGRect:(CGRect)rect inView:(UIView*)view  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirection;
@end

