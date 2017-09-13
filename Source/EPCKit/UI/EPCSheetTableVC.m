//
//  SheetTableVC.m
//
//  Created by Everton Cunha on 16/01/15.
//

#import "EPCSheetTableVC.h"
#import "EPCCategories.h"
#import "EPCDefines.h"

@interface EPCSheetTableVC () {
	UITableViewStyle _tableViewStyle;
}

@end

@implementation EPCSheetTableVC

#pragma mark - TO OVERRIDE

- (NSString*)currencyForNumber:(NSNumber*)number {
	if (self.currencyFormatter) {
		return [self.currencyFormatter stringFromNumber:number];
	}
	return [number stringValue];
}

- (NSString*)stringForDate:(NSDate*)date {
	if (self.dateFormatter){
		return [self.dateFormatter stringFromDate:date];
	}
	return [date description];
}

- (id)subviewForHeaderSheetData:(EPCSheetData*)data frame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textAlignment = data.textAlignment;
	label.text = data.title;
	return label;
}

- (UILabel*)labelForCellSubviewSheetData:(EPCSheetData*)sheet frame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textAlignment = sheet.textAlignment;
	return label;
}

- (UIImageView*)imageViewForCellSubviewSheetData:(EPCSheetData*)sheet frame:(CGRect)frame {
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
	imgView.contentMode = UIViewContentModeCenter;
	return imgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (UIView*)viewForHeaderForSection:(NSInteger)section {
	NSInteger height = [self tableView:self.tableView heightForHeaderInSection:section];
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, height)];
	return view;
}

- (int)marginBetweenHeaderLabels {
	return 0;
}

- (UITableViewCell*)newCellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	return [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
}

#pragma mark - PRIVATE

- (instancetype)initWithStyle:(UITableViewStyle)style {
	self = [self init];
	
	if (self) {
		_tableViewStyle = style;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:_tableViewStyle];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:tableView];
	self.tableView = tableView;
}

- (void)setObject:(id)object forView:(id)view currency:(BOOL)currency {
	if (currency && [object isKindOfClass:[NSNumber class]]) {
		UILabel *lbl = view;
		lbl.text = [self.currencyFormatter stringFromNumber:object];
	}
	else {
		[self setObject:object forView:view];
	}
}

- (void)setObject:(id)object forView:(id)view {
	if ([object isKindOfClass:[NSString class]]) {
		UILabel *lbl = view;
		lbl.text = object;
	}
	else if ([object isKindOfClass:[NSNumber class]]) {
		UILabel *lbl = view;
		lbl.text = [object stringValue];
	}
	if ([object isKindOfClass:[NSDate class]]) {
		NSString *txt = [self stringForDate:object];
		UILabel *lbl = view;
		lbl.text = txt;
	}
	else if ([object isKindOfClass:[UIImage class]]) {
		UIImageView *imgv = view;
		imgv.image = object;
	}
	else if (!object) {
		if ([view isKindOfClass:[UILabel class]]) {
			[(UILabel*)view setText:nil];
		}
		else if ([view isKindOfClass:[UIImageView class]]) {
			[(UIImageView*)view setImage:nil];
		}
	}

}

- (UIView*)subviewForObject:(id)object frame:(CGRect)frame sheetData:(EPCSheetData*)sheet {
	
	id view = nil;
	
	if ([object isKindOfClass:[UIImage class]]) {
		view = [self imageViewForCellSubviewSheetData:sheet frame:frame];
	}
	else {
		view = [self labelForCellSubviewSheetData:sheet frame:frame];
	}
	
	return view;
}

- (UIView *)headerForSection:(NSInteger)section {
	
	UIView *view = [self viewForHeaderForSection:section];
	
	NSInteger height = view.frameHeight;
	
	int x = 0;
	int margin = [self marginBetweenHeaderLabels];
	
	for (EPCSheetData *data in self.sheetData) {
		UIView *label = [self subviewForHeaderSheetData:data frame:CGRectMake(x, 0, data.width, height)];
		[view addSubview:label];
		
		x+= data.width + margin;
	}
	
	view.frameWidth = x;
	
	return view;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [self headerForSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.delegate sheetTableVC:self numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *identifier = @"c";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	id dataObject = [self.delegate sheetTableVC:self objectForRowAtIndexPath:indexPath];
	
	NSInteger height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
	
	if (!cell) {
		
		cell = [self newCellWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		
		int x = 0;
		int margin = [self marginBetweenHeaderLabels];
		
		for (int i = 0; i < [self.sheetData count]; i++) {
			EPCSheetData *data = self.sheetData[i];
			UIView *view = nil;
			CGRect frame = CGRectMake(x, 0, data.width, height);
			if (data.button) {
				view = [[UIView alloc] initWithFrame:frame];
				view.backgroundColor = [UIColor clearColor];
				UIButton *b = nil;
				if ([self.delegate respondsToSelector:@selector(sheetTableVC:buttonForRowAtIndexPath:existingButton:sheetData:)]) {
					b = [self.delegate sheetTableVC:self buttonForRowAtIndexPath:indexPath existingButton:nil sheetData:data];
				}
				else {
					b = [self.buttonDelegate sheetTableVC:self buttonForRowAtIndexPath:indexPath existingButton:nil sheetData:data];
				}
				[view addSubview:b];
			}
			else {
				id obj = nil;
				
				if ([dataObject respondsToSelector:data.selector]) {
					obj = [dataObject objectForSelector:data.selector];
				}
				else {
					DLog(@"!!! %@ %@ SELECTOR NOT FOUND: %@", NSStringFromClass([dataObject class]), dataObject, NSStringFromSelector(data.selector));
					obj = @"<FAULT>";
				}
				
				view = [self subviewForObject:obj frame:frame sheetData:data];
				
			}
			[cell.contentView addSubview:view];
			x+= view.frame.size.width + margin;
		}
	}
	
	if ([self.delegate respondsToSelector:@selector(sheetTableVC:objectsForRowAtIndexPath:)]) {
		NSArray *arr = [self.delegate sheetTableVC:self objectsForRowAtIndexPath:indexPath];
		for (int i = 0; i < [arr count]; i++) {
			id obj = arr[i];
			UIView *view = cell.contentView.subviews[i];
			[self setObject:obj forView:view];
		}
	}
	else {
		for (int i = 0; i < [self.sheetData count]; i++) {
			EPCSheetData *data = self.sheetData[i];
			if (data.button) {
				UIView *view = [cell.contentView subviews][i];
				UIButton *ob = [[view subviews] firstObject];
				
				UIButton *b = nil;
				if ([self.delegate respondsToSelector:@selector(sheetTableVC:buttonForRowAtIndexPath:existingButton:sheetData:)]) {
					b = [self.delegate sheetTableVC:self buttonForRowAtIndexPath:indexPath existingButton:ob sheetData:data];
				}
				else {
					b = [self.buttonDelegate sheetTableVC:self buttonForRowAtIndexPath:indexPath existingButton:ob sheetData:data];
				}
				if (ob!=b) {
					[ob removeFromSuperview];
					if (b) {
						[view addSubview:b];
					}
				}
			}
			else {
				id obj = nil;
				if ([dataObject respondsToSelector:data.selector]) {
					obj = [dataObject objectForSelector:data.selector];
				}
				else {
					DLog(@"!!! %@ %@ SELECTOR NOT FOUND: %@", NSStringFromClass([dataObject class]), dataObject, NSStringFromSelector(data.selector));
					obj = @"<FAULT>";
				}
				UIView *view = [cell.contentView subviews][i];
				[self setObject:obj forView:view currency:data.currency];
			}
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
		[self.tableViewDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

@end

@implementation EPCSheetData

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width {
	return [self sheetDataWithTitle:title selector:selector width:width textAlignment:NSTextAlignmentCenter currency:NO];
}

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width fontSize:(CGFloat)fontSize {
	EPCSheetData *data = [self sheetDataWithTitle:title selector:selector width:width textAlignment:NSTextAlignmentCenter currency:NO];
	data.fontSize = fontSize;
	return data;
}
+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width textAlignment:(NSTextAlignment)textAlignment currency:(BOOL)currency fontSize:(CGFloat)fontSize{
	EPCSheetData *data = [self sheetDataWithTitle:title selector:selector width:width textAlignment:textAlignment currency:currency];
	data.fontSize = fontSize;
	return data;
}
+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width textAlignment:(NSTextAlignment)textAlignment currency:(BOOL)currency{
	
	EPCSheetData *data = [[EPCSheetData alloc] init];
	data.title = title;
	data.selector = selector;
	data.width = width;
	data.textAlignment = textAlignment;
	data.currency = currency;
	return data;
}
+ (instancetype)sheetDataWithTitle:(NSString*)title button:(BOOL)button selector:(SEL)selector width:(int)width {
	EPCSheetData *data = [self sheetDataWithTitle:title button:button width:width];
	data.selector = selector;
	return data;
}

+ (instancetype)sheetDataWithTitle:(NSString*)title button:(BOOL)button width:(int)width {
	EPCSheetData *data = [[EPCSheetData alloc] init];
	data.title = title;
	data.width = width;
	data.button = button;
	data.textAlignment = NSTextAlignmentCenter;
	return data;
}

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width asc:(BOOL)asc {
	EPCSheetData *data = [self sheetDataWithTitle:title selector:selector width:width];
	data.sortAsc = asc;
	return data;
}

+ (instancetype)sheetDataWithTitle:(NSString*)title selector:(SEL)selector width:(int)width textAlignment:(NSTextAlignment)textAlignment currency:(BOOL)currency asc:(BOOL)asc {
	EPCSheetData *data = [self sheetDataWithTitle:title selector:selector width:width textAlignment:NSTextAlignmentCenter currency:NO];
	data.sortAsc = asc;
	return data;
}
@end
