//
//  EPCTabScrollView.h
//
//  Created by Everton Cunha on 24/12/14.
//

#import <UIKit/UIKit.h>

@interface EPCTabScrollView : UIScrollView

@property (nonatomic, strong) NSArray *viewControllers;

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
@end

@interface UIViewController (EPCTabScrollView)
- (EPCTabScrollView*)tabScrollView;
@end