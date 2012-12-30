//
//  ETDMainViewController.m
//  8Tracks-Downloader
//
//  Created by Jose Miguel Salcido on 12/30/12.
//  Copyright (c) 2012 Dudes. All rights reserved.
//

#import "ETDMainViewController.h"

// --------------------------------------------------
//  CONSTANTS
// --------------------------------------------------
NSString * const kActionObtainPlayToken = @"opt";
NSString * const kActionObtainHTMLData = @"ohd";
NSString * const kActionObtainPlaylistData = @"opd";
NSString * const kActionObtainImageData = @"oid";
NSString * const kActionObtainSongData = @"osd";

NSString * const kJSONKeyForPlayToken = @"play_token";
NSString * const kJSONKeyForMix = @"mix";
NSString * const kJSONKeyForCoverURL = @"cover_urls";
NSString * const kJSONKeyForCoverURLPx = @"max200";
NSString * const kJSONKeyForDescription = @"description";
NSString * const kJSONKeyForName = @"name";
NSString * const kJSONKeyForUser = @"user";
NSString * const kJSONKeyForUserName = @"slug";


@implementation ETDMainViewController

@synthesize window;

// --------------------------------------------------
//  LOOK UP UI
// --------------------------------------------------
@synthesize playlistURLTextField;
@synthesize devAPIKeyTextField;
@synthesize lookUpButton;

// --------------------------------------------------
//  PLAYLIST UI
// --------------------------------------------------
@synthesize playlistImageView;
@synthesize playlistNameTextField;
@synthesize playlistAuthorTextField;
@synthesize playlistDescriptionTextField;
@synthesize playlistProgressIndicator;

// --------------------------------------------------
//  OTHER PROPERTIES
// --------------------------------------------------
@synthesize receivedData;

@synthesize actionToPerform;
@synthesize playToken;
@synthesize HTMLData;
@synthesize playlistId;

#pragma mark Interface Methods
// --------------------------------------------------
//  INTERFACE METHODS
// --------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        actionToPerform = @"";
        [self.playlistProgressIndicator setHidden:YES];
    }
    
    return self;
}

- (IBAction)lookUpAction:(id)sender
{
    // Some business rules here please
    if([[self.devAPIKeyTextField stringValue] isEmpty] ||
        [[self.playlistURLTextField stringValue] isEmpty]) {
        // NOTIFY THE USER.
        NSString *msg = @"There can not be empty fields.[end]Playlist URL or Dev API Key fields are empty";
        [self alertUserWithMsg:msg];
        NSLog(@"Some field are empty");
        return;
    } else {
        [self.lookUpButton setEnabled:NO];
        [self.playlistProgressIndicator setHidden:NO];
        [self.playlistProgressIndicator startAnimation:nil];
        [self lookUp];
    }
}

#pragma mark Private Methods
// --------------------------------------------------
//  PRIVATE METHODS
// --------------------------------------------------
#pragma mark UI Methods

-(void)lookUp
{
    [self startLoadingPlayTokenWithDevAPIKey:[devAPIKeyTextField stringValue]];
}

-(void)alertUserWithMsg:(NSString *)msg
{
    NSArray *msgArray = [msg componentsSeparatedByString:@"[end]"];
    NSAlert *alertView = [[NSAlert alloc] init];
    [alertView addButtonWithTitle:@"OK"];
    [alertView setMessageText:[msgArray objectAtIndex:0]];
    [alertView setAlertStyle:NSWarningAlertStyle];
    [alertView setInformativeText:[msgArray objectAtIndex:1]];
    [alertView beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    
}

-(void)updateUI:(id)object
{
    NSDictionary *dict = object;
    self.playlistNameTextField.stringValue = [dict valueForKey:kJSONKeyForName];
    self.playlistDescriptionTextField.stringValue = [dict valueForKey:kJSONKeyForDescription];
    self.playlistAuthorTextField.stringValue = [[dict valueForKey:kJSONKeyForUser] valueForKey:kJSONKeyForUserName];
    NSURL *URLImage = [[NSURL alloc] initWithString:[[dict valueForKey:kJSONKeyForCoverURL] valueForKey:kJSONKeyForCoverURLPx]];
    [self startLoadingDataWithURL:URLImage action:kActionObtainImageData];
    [self.playlistProgressIndicator stopAnimation:nil];
    [self.playlistProgressIndicator setHidden:YES];
    [self.lookUpButton setEnabled:YES];
}

#pragma mark String Methods

-(NSString *)obtainPlaylistIdWithHTMLString:(NSString *)HTMLString
{
    // Position of the chunk of data that contains playlistId
    NSInteger position = 1;
    
    // Var playlistId is appended after this string
    NSString *stringToSearch = @"mixes/";
    
    // Split the HTMLString into n chunks, playlistId is at position
    NSArray *arrayContainingPlaylistId = [HTMLString componentsSeparatedByString:stringToSearch];
    
    // Var playlistId is appended after this string
    stringToSearch = @"/";
    
    // Split the chunk into n objects
    arrayContainingPlaylistId = [[arrayContainingPlaylistId objectAtIndex:position] componentsSeparatedByString:stringToSearch];
    
    // Var playlistId is at this position
    position = 0;
    
    // Obtain playlistId
    return [arrayContainingPlaylistId objectAtIndex:position];
}

#pragma mark startLoading
// --------------------------------------------------

-(void)startLoadingDataWithURL:(NSURL *)url action:(NSString *)kActionToPerform
{
    // Connection time out after this time var
    double timeOut = 60.0;
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeOut];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        receivedData = [NSMutableData data];
        actionToPerform = kActionToPerform;
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
    [self startLoadingDataWithURL:url action:kActionObtainHTMLData];
}

-(void)startLoadingPlaylistDataWithId:(NSString *)_playlistId devAPIKey:(NSString *)devAPIKey
{
    NSString *urlString = [NSString stringWithFormat:@"http://8tracks.com/mixes/%@.json?api_key=%@",_playlistId,devAPIKey];
    NSURL *url = [NSURL URLWithString:urlString];
    [self startLoadingDataWithURL:url action:kActionObtainPlaylistData];
}

-(void)startLoadingSongDataWithToken:(NSString *)_playToken playlistId:(NSString *)playListId devAPIKey:(NSString *)devAPIKey
{
    NSString *urlString = [NSString stringWithFormat:@"http://8tracks.com/sets/%@/play?mix_id=%@&format=jsonh&api_key=%@",_playToken,playListId,devAPIKey];
    NSURL *url = [NSURL URLWithString:urlString];
    [self startLoadingDataWithURL:url action:kActionObtainSongData];
}

#pragma mark NSConnectionDelegate methods
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
    
    NSString *dataString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if([actionToPerform isEqualToString:kActionObtainPlayToken]) {
        
        playToken = [[receivedData yajl_JSON] valueForKey:kJSONKeyForPlayToken];
        [self startLoadingHTMLDataWithURL:[playlistURLTextField stringValue]];
        
    } else if([actionToPerform isEqualToString:kActionObtainHTMLData]) {
        
        HTMLData = dataString;
        playlistId = [self obtainPlaylistIdWithHTMLString:dataString];
        
        [self startLoadingPlaylistDataWithId:playlistId devAPIKey:[devAPIKeyTextField stringValue]];
        
    } else if([actionToPerform isEqualToString:kActionObtainPlaylistData]) {
        
        NSDictionary *mainDictionary = [receivedData yajl_JSON];
        NSDictionary *mix = [mainDictionary valueForKey:kJSONKeyForMix];
        [self updateUI:mix];
        
    } else if([actionToPerform isEqualToString:kActionObtainImageData]) {
        
        NSImage *image = [[NSImage alloc] initWithData:receivedData];
        [self.playlistImageView setImage:image];
        
    } else if([actionToPerform isEqualToString:kActionObtainSongData]) {
        
        NSLog(@"%@",[receivedData yajl_JSON]);
        
    } else {
        
        // At least lets see what did we receive.
        NSLog(@"%@", dataString);
        
    }
}

@end
