//
//  EPCDropView.h
//
//  Created by Everton Cunha on 16/11/12.
//  Copyright (c) 2012 Everton Postay Cunha. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EPCDropView;

@protocol EPCDropViewDelegate <NSObject>
@optional

/* 
 Files are already filtered with supported file extensions
 */
- (void)dropView:(EPCDropView*)dropView didReceiveFiles:(NSArray*)files holdingAlt:(BOOL)holdingAlt;

/*
 Drag above view started
 */
- (void)dropView:(EPCDropView *)dropView dragEnteredHoldingAlt:(BOOL)holdingAlt;

/*
 Drag ended: accepting, denied or exiting the view
 */
- (void)dropView:(EPCDropView *)dropView dragEndedAccepting:(BOOL)accepting;
@end

@interface EPCDropView : NSView {
	BOOL _holdingAlt;
	
	NSArray *_fileArray;
	
	BOOL _allowing;
}

@property (nonatomic,weak) IBOutlet id<EPCDropViewDelegate> delegate;
@property (nonatomic,retain) NSArray *supportedFileExtensions;
@property (nonatomic,readwrite) BOOL allowFolders;

@end
