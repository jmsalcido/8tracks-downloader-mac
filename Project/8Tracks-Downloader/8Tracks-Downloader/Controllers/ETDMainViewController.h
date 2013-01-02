//
//  ETDMainViewController.h
//  8Tracks-Downloader
//
//  Created by Jose Miguel Salcido on 12/30/12.
//  Copyright (c) 2012 Dudes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <YAJL/YAJL.h>
#import "NSString+ETDString.h"

// --------------------------------------------------
//  CONSTANTS
// --------------------------------------------------
extern NSString * const kActionObtainPlayToken;
extern NSString * const kActionObtainHTMLData;
extern NSString * const kActionObtainPlaylistData;
extern NSString * const kActionObtainImageData;
extern NSString * const kActionObtainSongData;

extern NSString * const kJSONKeyForPlayToken;
extern NSString * const kJSONKeyForMix;
extern NSString * const kJSONKeyForCoverURL;
extern NSString * const kJSONKeyForCoverURLPx;
extern NSString * const kJSONKeyForDescription;
extern NSString * const kJSONKeyForName;
extern NSString * const kJSONKeyForUser;
extern NSString * const kJSONKeyForUserName;

@interface ETDMainViewController : NSViewController <NSURLConnectionDelegate>

@property (strong) IBOutlet NSWindow *window;

// --------------------------------------------------
//  LOOK UP UI
// --------------------------------------------------
@property (strong) IBOutlet NSTextField *playlistURLTextField;
@property (strong) IBOutlet NSTextField *devAPIKeyTextField;
@property (strong) IBOutlet NSButton *lookUpButton;

// --------------------------------------------------
//  PLAYLIST UI
// --------------------------------------------------
@property (strong) IBOutlet NSImageView *playlistImageView;
@property (strong) IBOutlet NSTextField *playlistNameTextField;
@property (strong) IBOutlet NSTextField *playlistAuthorTextField;
@property (strong) IBOutlet NSTextField *playlistDescriptionTextField;
@property (strong) IBOutlet NSProgressIndicator *playlistProgressIndicator;

// --------------------------------------------------
//  DOWNLOAD UI
// --------------------------------------------------
@property (strong) IBOutlet NSPathControl *pathControl;
@property (strong) IBOutlet NSButton *downloadButton;
@property (strong) IBOutlet NSTextView *logDownloadsTextView;

// --------------------------------------------------
//  OTHER PROPERTIES
// --------------------------------------------------
@property (strong) NSMutableData *receivedData;
@property NSInteger download_size;

@property (strong) NSString *actionToPerform;
@property (strong) NSString *playToken;
@property (strong) NSString *HTMLData;
@property (strong) NSString *playlistId;

// --------------------------------------------------
//  INTERFACE METHODS
// --------------------------------------------------
- (IBAction)lookUpAction:(id)sender;

@end