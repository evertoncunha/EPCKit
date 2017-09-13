//
//  EPCImageCacher.m
//  Renner
//
//  Created by Everton Cunha on 27/08/12.
//  Copyright (c) 2012 Ring. All rights reserved.
//

#import "EPCImageCacher.h"
#import "EPCCategories.h"

@implementation EPCImageCacher

+ (void)saveImageData:(NSData*)imageData withKey:(NSString*)key toFolderName:(NSString*)folderName {
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:imageData, @"imageData", key, @"key", folderName, @"folderName", nil];
	
	EPCImageCacher *obj = [[EPCImageCacher new] autorelease];
	[obj performSelectorInBackground:@selector(threadToWriteImageFile:) withObject:dict];
}

+ (UIImage*)imageForKey:(NSString*)key fromFolderName:(NSString*)folderName {
	NSString *filePath = [[UIApplication cacheDirectoryPath] stringByAppendingPathComponent:[folderName stringByAppendingPathComponent:key]];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filePath]) {
		return [UIImage imageWithContentsOfFile:filePath];
	}
	return nil;
}

+ (void)removeAllCachedImagesFromFolderName:(NSString*)folderName
{
	NSError *error = nil;
	
	NSString *docPath = [[UIApplication cacheDirectoryPath] stringByAppendingPathComponent:folderName];
	
	// delete directory
	if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:docPath error:&error];
	}
}


- (void)threadToWriteImageFile:(NSDictionary*)dict {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	@try {
		NSData *data = [dict objectForKey:@"imageData"];
		NSString *key = [dict objectForKey:@"key"];
		NSString *folderName = [dict objectForKey:@"folderName"];
		NSString *folderPath = [UIApplication cacheDirectoryPath];
		if (folderName)
			folderPath = [folderPath stringByAppendingPathComponent:folderName];
		
		// create foder
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		if (![fm fileExistsAtPath:folderPath]) {
			if(![fm createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error])
				NSLog(@"Error creating folder. %@", error);
		}
		
		if (!error) {	
			NSString *filePath = [folderPath stringByAppendingPathComponent:key];
			
			NSError *error = nil;
			if ([fm fileExistsAtPath:filePath])
				[fm removeItemAtPath:filePath error:&error];

			if (!error && ![data writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
				NSLog(@"Error writing file. %@", error);
			}
		}
		
	}
	@catch (NSException *exception) {
		NSLog(@"%s Exception: %@", __PRETTY_FUNCTION__, exception);
	}
	
	[pool drain];
}

@end
