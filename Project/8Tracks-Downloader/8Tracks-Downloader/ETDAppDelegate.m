//
//  ETDAppDelegate.m
//  8Tracks-Downloader
//
//  Created by Jose Miguel Salcido on 12/30/12.
//  Copyright (c) 2012 Dudes. All rights reserved.
//

#import "ETDAppDelegate.h"

@implementation ETDAppDelegate

@synthesize mainViewController;
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainViewController = [[ETDMainViewController alloc] initWithNibName:@"ETDMainViewController" bundle:nil];
    [self.window.contentView addSubview:self.mainViewController.view];
}

@end
