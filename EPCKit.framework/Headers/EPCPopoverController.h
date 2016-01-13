//
//  UIPopoverControllerWithTableView.h
//
//  Created by Everton Cunha on 10/11/14.
//

#import <UIKit/UIKit.h>

@interface EPCPopoverController : UIPopoverController <UITableViewDataSource, UITableViewDelegate>

@property (copy) void(^didDismissPopoverBlock)();

@property (copy) void(^willDismissPopoverBlock)(EPCPopoverController*popOverController, NSArray *indexPaths);

@property (nonatomic) NSArray *tableViewData;

@property (nonatomic) SEL stringSelector;

@property (nonatomic) CGFloat tableViewWidth;

/*! Default is YES */
@property (nonatomic) BOOL cellCheckmarkEnabled;

@property (nonatomic) UIFont *textFont;

@property (nonatomic) BOOL allowsMultipleSelection;

@property (nonatomic) NSArray *cellImages;

@property (nonatomic, readonly) UITableViewController *tableViewController;

@property (nonatomic) UITableViewCellSelectionStyle cellSelectionStyle;

@property (nonatomic) NSArray *selectableData;

@property (nonatomic) BOOL singleSelectionAllowsDeselection;

- (UIDatePicker*)datePicker;

- (instancetype)initWithStyle:(UITableViewStyle)style tableViewData:(NSArray*)tableViewData stringSelector:(SEL)stringSelector width:(CGFloat)width tableViewSelection:(void(^)(EPCPopoverController *popOverController, UITableView *tableView, NSArray *indexPaths))didSelectRowBlock;

- (instancetype)initWithDatePickerMode:(UIDatePickerMode)pickerMode minimumDate:(NSDate*)minimunDate maximumDate:(NSDate*)maximumDate selectedDate:(NSDate*)selectedDate datePickerValueChanged:(void(^)(EPCPopoverController *popOverController, NSDate *date))block;

/*! With extra view at bottom */
- (instancetype)initWithDatePickerMode:(UIDatePickerMode)pickerMode minimumDate:(NSDate*)minimunDate maximumDate:(NSDate*)maximumDate selectedDate:(NSDate*)selectedDate bottomView:(UIView*)bottomView datePickerValueChanged:(void(^)(EPCPopoverController *popOverController, NSDate *date))block;

- (instancetype)initWithDatePickerMode:(UIDatePickerMode)pickerMode locale:(NSLocale*)locale minimumDate:(NSDate*)minimunDate maximumDate:(NSDate*)maximumDate selectedDate:(NSDate*)selectedDate bottomView:(UIView*)bottomView datePickerValueChanged:(void(^)(EPCPopoverController *popOverController, NSDate *date))block;

- (instancetype)initWithText:(NSString*)text;

- (instancetype)initWithText:(NSString *)text width:(float)width;

- (instancetype)initWithText:(NSString *)text width:(float)width font:(UIFont*)font;

- (instancetype)initWithView:(UIView *)view;

- (void)presentInWindowRootViewControllerFromView:(UIView*)sender permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

- (void)presentInWindowRootViewControllerFromView:(UIView*)sender rect:(CGRect)rect permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)position;

- (void)selectRowsAtIndexPaths:(NSMutableArray*)indexPaths;

- (NSIndexPath*)indexPathForSelectedRow;

- (void)setSelectedObject:(id)object;
@end
