//
//  EPCDropView.m
//
//  Created by Everton Cunha on 16/11/12.
//  Copyright (c) 2012 Everton Postay Cunha. All rights reserved.
//

#import "EPCDropView.h"
#import	"EPCDefines.h"

@implementation EPCDropView

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:
								   NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	[self checkFilesFromSender:sender];
	
	if (_allowing) {
		if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
			== NSDragOperationGeneric) {
			if ([self.delegate respondsToSelector:@selector(dropView:dragEnteredHoldingAlt:)]) {
				[self.delegate dropView:self dragEnteredHoldingAlt:NO];
			}
			return NSDragOperationCopy;
		}
		else if ((NSDragOperationCopy & [sender draggingSourceOperationMask]) == NSDragOperationCopy) {
			if ([self.delegate respondsToSelector:@selector(dropView:dragEnteredHoldingAlt:)]) {
				[self.delegate dropView:self dragEnteredHoldingAlt:YES];
			}
			return NSDragOperationCopy;
		}
	}
    
	return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
	
	if (_allowing) {
		if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
			== NSDragOperationGeneric) {
			_holdingAlt = NO;
			return NSDragOperationCopy;
		}
		else if ((NSDragOperationCopy & [sender draggingSourceOperationMask]) == NSDragOperationCopy) {
			_holdingAlt = YES;
			return NSDragOperationCopy;
		}
	}
	
	return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	return _allowing;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	if ([self.delegate respondsToSelector:@selector(dropView:didReceiveFiles:holdingAlt:)]) {
		[self.delegate dropView:self didReceiveFiles:_fileArray holdingAlt:_holdingAlt];
	}
	if ([self.delegate respondsToSelector:@selector(dropView:dragEndedAccepting:)]) {
		[self.delegate dropView:self dragEndedAccepting:YES];
	}
	[self clearFileArray];
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
	[self clearFileArray];
	if ([self.delegate respondsToSelector:@selector(dropView:dragEndedAccepting:)]) {
		[self.delegate dropView:self dragEndedAccepting:NO];
	}
}

- (void)clearFileArray {
	_fileArray = nil;
}

- (void)checkFilesFromSender:(id <NSDraggingInfo>)sender {
	[self clearFileArray];
	if (!_fileArray) {
		NSPasteboard *paste = [sender draggingPasteboard];
		_fileArray = [paste propertyListForType:NSFilenamesPboardType];
		_allowing = [self allowsFiles:_fileArray];
	}
}

- (BOOL)allowsFiles:(NSArray*)files {
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString* path in files) {
		NSString *ext = [path pathExtension];
		if ([ext length] == 0) {
			BOOL isDir = NO;
			if([fm fileExistsAtPath:path isDirectory:&isDir]) {
				if (isDir) {
					return self.allowFolders;
				}
			}
		}
		else {
			if ([self.supportedFileExtensions containsObject:ext]) {
				return YES;
			}
		}
	}
	return NO;
}

- (NSArray*)filteredFilesFromArray:(NSArray*)array {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString* path in array) {
		NSString *ext = [path pathExtension];
		if ([ext length] == 0) {
			BOOL *isDir = NO;
			if([fm fileExistsAtPath:path isDirectory:isDir]) {
				if (isDir) {
					if (self.allowFolders) {
						[result addObject:path];
					}
				}
			}
		}
		else {
			if ([self.supportedFileExtensions containsObject:ext]) {
				[result addObject:path];
			}
		}
	}
	return result;
}
@end
