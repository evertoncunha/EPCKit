//
//  EPCSheetTableVC.h
//
//  Created by Everton Cunha on 16/01/15.
//

#import <UIKit/UIKit.h>

@class EPCSheetTableVC, EPCSheetData;

@protocol EPCSheetTableVCDelegate <NSObject>

@optional

- (NSInteger)sheetTableVC:(EPCSheetTableVC*)sheetTableVC numberOfRowsInSection:(NSInteger)section;

- (id)sheetTableVC:(EPCSheetTableVC*)sheetTableVC objectForRowAtIndexPath:(NSIndexPath*)indexPath;

- (NSArray*)sheetTableVC:(EPCSheetTableVC*)sheetTableVC objectsForRowAtIndexPath:(NSIndexPath*)indexPath;

- (UIButton*)sheetTableVC:(EPCSheetTableVC*)sheetTableVC buttonForRowAtIndexPath:(NSIndexPath*)indexPath existingButton:(UIButton*)existingButton sheetData:(EPCSheetData*)sheetData;

@end

@interface EPCSheetTableVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *sheetData;

@property (nonatomic, weak) id<EPCSheetTableVCDelegate> delegate;

@property (nonatomic, weak) id<EPCSheetTableVCDelegate> buttonDelegate;

@property (nonatomic, weak) id<UITableViewDelegate> tableViewDelegate;

@property (nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) NSNumberFormatter *currencyFormatter;

@property (nonatomic, weak) UITableView *tableView;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end

@interface EPCSheetData : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) int width;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) SEL selector;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) BOOL currency;
@property (nonatomic) BOOL button;
@property (nonatomic) BOOL sortAsc;
@property (nonatomic) BOOL startSelected;
@property (nonatomic) NSString *identifier;

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width;

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width fontSize:(CGFloat)fontSize;

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width textAlignment:(NSTextAlignment)textAlignment currency:(BOOL)currency fontSize:(CGFloat)fontSize;

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width asc:(BOOL)asct;

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width textAlignment:(NSTextAlignment)textAlignment currency:(BOOL)currency asc:(BOOL)asc;

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width textAlignment:(NSTextAlignment)textAlignment currency:(BOOL)currency;

+ (instancetype)sheetDataWithTitle:(NSString*)title button:(BOOL)button width:(int)width;

+ (instancetype)sheetDataWithTitle:(NSString*)title button:(BOOL)button selector:(SEL)selector width:(int)width;

@end
