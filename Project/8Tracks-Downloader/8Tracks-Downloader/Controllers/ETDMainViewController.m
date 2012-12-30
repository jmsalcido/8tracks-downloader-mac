//
//  ETDMainViewController.m
//  8Tracks-Downloader
//
//  Created by Jose Miguel Salcido on 12/30/12.
//  Copyright (c) 2012 Dudes. All rights reserved.
//

#import "ETDMainViewController.h"

NSString * const kActionObtainPlayToken = @"play_token";
NSString * const kActionObtainHTMLData = @"html_data";

@implementation ETDMainViewController
@synthesize window;
@synthesize receivedData;

// --------------------------------------------------
//  INTERFACE METHODS
// --------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)lookUpAction:(id)sender
{
}

// --------------------------------------------------
//  PRIVATE METHODS
// --------------------------------------------------

-(void)startLoadingDataWithURL:(NSURL *)url action:(NSString *)kActionToPerform
{
    double timeOut = 60.0;
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeOut];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        receivedData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
    }
}

-(void)startLoadingPlayTokenWithDevAPIKey:(NSString *)devAPIKey
{
    NSString *urlString = [NSString stringWithFormat:@"http://8tracks.com/sets/new.json?api_key=%@",devAPIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self startLoadingDataWithURL:url action:kActionObtainPlayToken];
}

-(void)startLoadingHTMLDataWithURL:(NSString *)playlistURL
{
    NSString *urlString = [NSString stringWithFormat:@"%@",playlistURL];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self startLoadingDataWithURL:url action:kActionObtainPlayToken];
}

// --------------------------------------------------
//  PROTOCOL NSConnectionDelegate METHODS
// --------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    NSLog(@"Succeeded! Received %ld bytes of data",[receivedData length]);
}

@end
