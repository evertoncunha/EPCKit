//
//  EPCComboBox.h
//
//  Created by Everton Postay Cunha on 28/06/11.
//

#import <UIKit/UIKit.h>

@class ComboListShadowView;

@class EPCComboBox;

@protocol EPCComboBoxDelegate <NSObject>

@required
- (UIButton*)comboBoxButtonForComboBox:(EPCComboBox*)comboBox;

- (UITableViewCell *)comboBox:(EPCComboBox*)comboBox tableView:(UITableView*)tableView viewForRowAtIndex:(int)index;

- (NSInteger)numberOfRowsForComboBox:(EPCComboBox*)comboBox;

- (UIView*)comboBox:(EPCComboBox *)comboBox viewForSelectedItemWhileOpen:(BOOL)open;

@optional
- (void)comboBox:(EPCComboBox *)comboBox didSelectedRowAtIndex:(int)index;

@end

@interface EPCComboBox : UIView <UITableViewDataSource, UITableViewDelegate> {
    UIButton *button;
	UITableView *tableView;
	UIButton *selectedViewButton;
	
	ComboListShadowView *shadowView;
}

@property (nonatomic, assign) IBOutlet id<EPCComboBoxDelegate> delegate;

@property (nonatomic, readonly) int indexOfSelectedRow;

@property (nonatomic, assign) UIView *selectedView;

@property (nonatomic, readonly, getter = isOpen) BOOL open;

- (void)selectRowAtIndex:(int)index;

- (void)reloadData;

- (void)close;

- (void)open;

@end

// to get touches outside combobox
@interface ComboListShadowView : UIView

@property (nonatomic, assign) EPCComboBox *comboBoxView;

@end
