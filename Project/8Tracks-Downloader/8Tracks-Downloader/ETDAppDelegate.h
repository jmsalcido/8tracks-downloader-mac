//
//  ETDAppDelegate.h
//  8Tracks-Downloader
//
//  Created by Jose Miguel Salcido on 12/30/12.
//  Copyright (c) 2012 Dudes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ETDMainViewController.h"

@interface ETDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet ETDMainViewController *mainViewController;

@end
