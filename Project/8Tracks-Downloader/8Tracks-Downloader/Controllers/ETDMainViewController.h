//
//  ETDMainViewController.h
//  8Tracks-Downloader
//
//  Created by Jose Miguel Salcido on 12/30/12.
//  Copyright (c) 2012 Dudes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <YAJL/YAJL.h>

extern NSString * const kActionObtainPlayToken;
extern NSString * const kActionObtainHTMLData;

@interface ETDMainViewController : NSViewController <NSURLConnectionDelegate>

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *playlistURLTextField;
@property (strong) IBOutlet NSTextField *devAPIKeyTextField;

@property (strong) NSMutableData *receivedData;

- (IBAction)lookUpAction:(id)sender;

@end