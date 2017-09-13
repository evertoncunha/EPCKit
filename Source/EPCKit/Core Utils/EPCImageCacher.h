//
//  EPCImageCacher.h
//  Renner
//
//  Created by Everton Cunha on 27/08/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EPCImageCacher : NSObject
+ (void)saveImageData:(NSData*)imageData withKey:(NSString*)key toFolderName:(NSString*)folderName;
+ (UIImage*)imageForKey:(NSString*)key fromFolderName:(NSString*)folderName;
@end
