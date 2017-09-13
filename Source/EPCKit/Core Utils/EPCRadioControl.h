//
//  EPCRadioControl.h
//
//  Created by Everton Postay Cunha on 14/06/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EPCRadioControl : NSObject {
}

- (id)initWithButtons:(NSArray *)btns;

@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, readonly) UIButton *selectedButton;
@end
