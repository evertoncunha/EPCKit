//
//  EPCFilterController.h
//
//  Created by Everton Cunha on 21/12/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EPCFilterButton, EPCFilterController;

@protocol EPCFilterControllerDelegate <NSObject>

- (void)filterController:(EPCFilterController*)filterController filterChangedToPredicate:(NSPredicate*)predicate;

@optional
- (NSArray*)filterControllerAdditionalPredicateArguments:(EPCFilterController*)filterController;

- (NSString*)filterControllerAdditionalPredicateString:(EPCFilterController*)filterController;

@end

@interface EPCFilterController : NSObject

@property (nonatomic, weak) IBOutlet id<EPCFilterControllerDelegate> delegate;

@property (nonatomic, weak) IBOutletCollection(UISearchBar) NSArray *searchBars;

@property (nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;

- (void)applyFilter;

- (void)clearFilters;

- (NSArray*)filteredDataFromData:(NSArray*)data;

- (NSPredicate*)predicateForActiveFiltersExcept:(EPCFilterButton*)exception;

- (void)selectIndex:(NSInteger)index forButton:(UIButton*)button;

- (void)setData:(NSArray*)data;

- (void)setEnabled:(BOOL)enabled;

#pragma mark - UI CUSTOMIZATION

@property (nonatomic) Class classForPopOver;

@property (nonatomic) UIFont *fontForPopOverHeader;

@property (nonatomic) UIColor *colorForPopOverHeaderBackground;

@property (nonatomic) UIColor *colorForPopOverHeaderText;

@property (nonnull) NSString *textDoNotFilter;

@end


#pragma mark - FILTER BUTTON

@interface EPCFilterButton : UIButton

@property (nonatomic) NSString *filterKey;

@property (nonatomic, readonly) NSString *filterTitle;

@property (nonatomic, weak) EPCFilterButton *nextButton;

@property (nonatomic, weak) EPCFilterButton *previousButton;

@property (nonatomic) NSArray *selectableData;

@property (nonatomic) id selectedData;

@property (nonatomic) NSArray *sortionArray;

@property (nonatomic) NSArray *tableViewData;

- (void)reset;

@end