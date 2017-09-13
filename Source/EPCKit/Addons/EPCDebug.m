//
//  EPCDebug.m
//
//  Created by Everton Postay Cunha on 24/07/12.
//

#import "EPCDebug.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

@implementation EPCDebug

+ (void)load {
#ifdef DEBUG
	[self swizzle:[UIViewController class] orig:NSSelectorFromString(@"dealloc") new:@selector(myDealloc)];
#endif
}

+ (void)swizzle:(Class)c orig:(SEL)orig new:(SEL)new
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
		method_exchangeImplementations(origMethod, newMethod);
}

@end

@implementation UIViewController (DeallocDebugger)

- (void)myDealloc
{
    NSLog(@"[%@ dealloc]", NSStringFromClass([self class]));
    [self myDealloc];
}
@end