//
//  EPCFilterController.m
//
//  Created by Everton Cunha on 21/12/15.
//

#import "EPCFilterController.h"
#import "EPCPopoverController.h"
#import "EPCCategories.h"

@interface EPCFilterController() {
	
	NSArray
	*_arrFilters,
	*_arrFilterKeys,
	*_arrAllData;
	
	NSMutableArray
	*_arrPredicates,
	*_arrKeysThatAreArray;
}

@end

@implementation EPCFilterController

- (void)setFilterButtons:(NSArray *)filterButtons {
	
	_filterButtons = filterButtons;
	
	_arrKeysThatAreArray = [NSMutableArray array];
	
	_arrFilters = filterButtons;
	_arrFilterKeys = [filterButtons valueForKey:@"filterKey"];
	
	_arrPredicates = [NSMutableArray arrayWithCapacity:[_arrFilterKeys count]];
	
	for (int i = 0; i < [_arrFilters count]; i++) {
		EPCFilterButton *b = _arrFilters[i];
		
		[b addTarget:self action:@selector(tappedFilterButton:) forControlEvents:UIControlEventTouchUpInside];
		
		if (i > 0) {
			b.previousButton = _arrFilters[i-1];
		}
		if (i+1 < [_arrFilters count]) {
			b.nextButton = _arrFilters[i+1];
		}
	}
}

- (void)tappedFilterButton:(EPCFilterButton*)button {
	
	NSMutableArray *mut = [NSMutableArray array];
	if (self.textDoNotFilter) {
		[mut addObject:self.textDoNotFilter];
	}
	[mut addObjectsFromArray:button.tableViewData];
	
	Class popClass = nil;
	
	if (self.classForPopOver) {
		popClass = self.classForPopOver;
	}
	else {
		popClass = [EPCPopoverController class];
	}
	
	EPCPopoverController *popOver = [[popClass alloc] initWithStyle:UITableViewStylePlain tableViewData:mut stringSelector:nil width:button.frameWidth tableViewSelection:^(EPCPopoverController *popOverController, UITableView *tableView, NSArray *indexPaths) {
		
		[popOverController dismissPopoverAnimated:YES];
		
		NSInteger index = [[indexPaths firstObject] row];
		
		if (index == 0) {
			[button reset];
		}
		else {
			
			if (self.textDoNotFilter) {
				index--;
			}
			
			id data = button.tableViewData[index];
			
			button.selectedData = data;
			
			[button setTitle:data forState:UIControlStateNormal];
			
		}
		
		[self delegateFilterChanged];
		
	}];
	
	// selectables
	NSMutableArray *sels = [self selectableFiltersForButton:button];
	[sels addObject:[mut firstObject]];
	popOver.selectableData = sels;
	
	// header
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.frameWidth, button.frameHeight)];
	if (self.colorForPopOverHeaderBackground) {
		v.backgroundColor = self.colorForPopOverHeaderBackground;
	}
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, button.frameWidth-15, button.frameHeight)];
	if (self.fontForPopOverHeader) {
		label.font = self.fontForPopOverHeader;
	}
	label.textColor = self.colorForPopOverHeaderText? self.colorForPopOverHeaderText : [UIColor whiteColor];
	label.text = button.filterTitle;
	[v addSubview:label];
	popOver.tableViewController.tableView.tableHeaderView = v;
	
	
	[popOver presentInWindowRootViewControllerFromView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	
	if (button.selectedData) {
		[popOver setSelectedObject:button.selectedData];
	}
	else {
		[popOver setSelectedObject:[mut firstObject]];
	}
	
}

#pragma mark - DELEGATE

- (void)delegateFilterChanged {
	if ([self.delegate respondsToSelector:@selector(filterController:filterChangedToPredicate:)]) {
		[self.delegate filterController:self filterChangedToPredicate:[self predicateForActiveFilters]];
	}
}

#pragma mark - FILTER

- (NSMutableArray*)selectableFiltersForButton:(EPCFilterButton*)button {
	
	NSPredicate *predicate = [self predicateForActiveFiltersExcept:button];
	
	if (predicate) {
		NSArray *data = [_arrAllData filteredArrayUsingPredicate:predicate];
		
		NSString *key = _arrFilterKeys[[_arrFilters indexOfObject:button]];
		
		NSMutableArray *mutArr = [NSMutableArray array];
		
		for (id prod in data) {
			id obj = [prod valueForKey:key];
			
			if (obj && ![obj isKindOfClass:[NSNull class]]) {
				if ([obj isKindOfClass:[NSArray class]]) {
					if (![_arrKeysThatAreArray containsObject:key]) {
						[_arrKeysThatAreArray addObject:key];
					}
					for (NSString *s in obj) {
						if(![mutArr containsObject:s]) {
							[mutArr addObject:s];
						}
					}
				}
				else {
					if(![mutArr containsObject:obj]) {
						[mutArr addObject:obj];
					}
				}
				
			}
		}
		
		return mutArr;
	}
	
	return nil;
}

- (NSPredicate*)predicateForActiveFiltersExcept:(EPCFilterButton*)exception {
	
	NSMutableString *mut = [NSMutableString string];
	
	NSString *extraStr = nil;
	if ([self.delegate respondsToSelector:@selector(filterControllerAdditionalPredicateString:)]) {
		extraStr = [self.delegate filterControllerAdditionalPredicateString:self];
	}
	if ([extraStr length] > 0) {
		[mut appendString:extraStr];
		[mut appendString:@" "];
	}
	
	NSMutableArray *arguments = [NSMutableArray array];
	
	NSArray *extraArg = nil;
	if ([self.delegate respondsToSelector:@selector(filterControllerAdditionalPredicateArguments:)]) {
		extraArg = [self.delegate filterControllerAdditionalPredicateArguments:self];
	}
	if ([extraArg count] > 0) {
		[arguments addObjectsFromArray:extraArg];
	}
	
	for (int i = 0; i < [_arrFilters count]; i++) {
		
		EPCFilterButton *btn = _arrFilters[i];
		
		if (!exception || btn!=exception) {
			
			if (btn.selectedData) {
				NSString *key = _arrFilterKeys[i];
				
				if ([mut length] > 0) {
					[mut appendString:@" AND "];
				}
				if ([_arrKeysThatAreArray containsObject:key]) {
					[mut appendString:@"%@ IN "];
					[mut appendString:key];
				}
				else {
					[mut appendString:key];
					[mut appendString:@" = %@"];
				}
				[arguments addObject:btn.selectedData];
			}
		}
	}
	
	if ([mut length] > 0) {
		if ([arguments count] > 0) {
			return [NSPredicate predicateWithFormat:mut argumentArray:arguments];
		}
		else {
			return [NSPredicate predicateWithFormat:mut];
		}
	}
	
	return nil;
}

- (NSPredicate*)predicateForActiveFilters {
	return [self predicateForActiveFiltersExcept:nil];
}

#pragma mark - PUBLIC

- (void)selectIndex:(NSInteger)index forButton:(EPCFilterButton*)button {
	
	if (index < button.tableViewData.count && index >= 0) {
		id data = button.tableViewData[index];
		
		button.selectedData = data;
		
		[button setTitle:data forState:UIControlStateNormal];
	}
	else {
		[button reset];
	}
	
}

- (void)applyFilter {
	[self delegateFilterChanged];
}

- (void)setEnabled:(BOOL)enabled {
	for (UIButton *btn in _filterButtons) {
		if ([btn isKindOfClass:[UIButton class]]) {
			btn.enabled = enabled;
		}
	}
	for (UISearchBar *searchBar in self.searchBars) {
		searchBar.userInteractionEnabled = enabled;
		searchBar.alpha = enabled?1:0.75f;
	}
}

- (NSArray*)filteredDataFromData:(NSArray*)data {
	NSPredicate *pred = [self predicateForActiveFilters];
	if (pred) {
		data = [data filteredArrayUsingPredicate:pred];
	}
	return data;
}

- (void)clearFilters {
	for (int i = 0; i < [_arrFilters count]; i++) {
		EPCFilterButton *btn = _arrFilters[i];
		[btn reset];
	}
	for (UISearchBar *searchBar in self.searchBars) {
		searchBar.text = nil;
	}
}

- (void)setData:(NSArray*)data {
	
	_arrAllData = data;
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	for (int i = 0; i < [_arrFilterKeys count]; i++) {
		
		NSString *key = _arrFilterKeys[i];
		NSMutableArray *mutArr = [dict objectForKey:key];
		if (!mutArr) {
			mutArr = [NSMutableArray array];
			dict[key] = mutArr;
		}
		
		for (id prod in data) {
			id obj = [prod valueForKey:key];
			if (obj && ![obj isKindOfClass:[NSNull class]]) {
				if ([obj isKindOfClass:[NSArray class]]) {
					if (![_arrKeysThatAreArray containsObject:key]) {
						[_arrKeysThatAreArray addObject:key];
					}
					for (NSString *s in obj) {
						if(![mutArr containsObject:s]) {
							[mutArr addObject:s];
						}
					}
				}
				else {
					if(![mutArr containsObject:obj]) {
						[mutArr addObject:obj];
					}
				}
			}
		}
	}
	
	for (int i = 0; i < [_arrFilters count]; i++) {
		EPCFilterButton *btn = _arrFilters[i];
		NSString *key = _arrFilterKeys[i];
		btn.tableViewData = dict[key];
		if (btn.selectedData && ![btn.tableViewData containsObject:btn.selectedData]) {
			btn.selectedData = nil;
		}
	}
	
}

@end

@interface EPCFilterButton() {
	NSString
	*_strTitle;
}
@end

@implementation EPCFilterButton

- (NSString *)filterTitle {
	return _strTitle;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	_strTitle = [self titleForState:UIControlStateNormal];
}

- (void)reset {
	[self setTitle:_strTitle forState:UIControlStateNormal];
	self.selectedData = nil;
}

- (void)setTableViewData:(NSArray *)tableViewData {
	if (self.sortionArray) {
		tableViewData = [tableViewData sortedArrayUsingArray:self.sortionArray];
	}
	else {
		tableViewData = [tableViewData sortedArrayUsingSelector:@selector(compare:)];
	}
	_tableViewData = tableViewData;
	
	self.enabled = [tableViewData count]>0;
	
	if ([tableViewData count] == 0) {
		[self reset];
	}
	else {
		NSString *title = [self titleForState:UIControlStateNormal];
		if (![title isEqualToString:_strTitle]) {
			if (![tableViewData containsObject:title]) {
				[self reset];
			}
		}
	}
}

@end
