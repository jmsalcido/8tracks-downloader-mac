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
NSString * const kJSONKeyForCoverURLPx = @"sq100";
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
        // This must hide the progress indicator, not working, it is weird.
        [self.playlistProgressIndicator setHidden:YES];
    }
    
    return self;
}

- (IBAction)lookUpAction:(id)sender
{
    // Some more business rules here please
    if([[self.devAPIKeyTextField stringValue] isEmpty] ||
        [[self.playlistURLTextField stringValue] isEmpty]) {
        
        // Notify the user
        // It is a rule that every message shall contain a "Title" and a "Description"
        // We shall send a single NSString, the Title is before the tag [end]
        // description is after the tag.
        NSString *msg = @"There cannot be empty fields.[end]Playlist URL or Dev API Key fields are empty";
        [self alertUserWithMsg:msg];
        return;
    } else {
        // Look Up Button shall be disabled (only 1 request per click)
        [self.lookUpButton setEnabled:NO];
        
        // Show the progress indicator and start the animation
        [self.playlistProgressIndicator setHidden:NO];
        [self.playlistProgressIndicator startAnimation:nil];
        
        // Start loading data.
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
    // Load the play token first (we don't need more data than the developer API key)
    [self startLoadingPlayTokenWithDevAPIKey:[devAPIKeyTextField stringValue]];
}

-(void)alertUserWithMsg:(NSString *)msg
{
    // NSArray that contains the "Title" and the "Description"
    NSArray *msgArray = [msg componentsSeparatedByString:@"[end]"];
    
    // Alloc memory for our NSAlert (not MODAL, is a SHEET-MODAL DIALOG)
    NSAlert *alertView = [[NSAlert alloc] init];
    
    // Set all the dialog properties
    [alertView addButtonWithTitle:@"OK"];
    [alertView setMessageText:[msgArray objectAtIndex:0]]; // this is why title is FIRST
    [alertView setAlertStyle:NSWarningAlertStyle];
    [alertView setInformativeText:[msgArray objectAtIndex:1]]; // this is why description is SECOND
    
    // This is to call the dialog as a SHEET MODAL DIALOG, not a MODAL ONE (ugly)
    [alertView beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    
}

-(void)updateUI:(id)object
{
    // Convert the object to the desired type
    // jmsalcido: I was thinking bout using a "model" to follow the MVC pattern
    // jmsalcido: but it is... working.
    NSDictionary *dict = object;
    
    // Obtain the cool properties (using constants always)
    self.playlistNameTextField.stringValue = [dict valueForKey:kJSONKeyForName];
    self.playlistDescriptionTextField.stringValue = [dict valueForKey:kJSONKeyForDescription];
    self.playlistAuthorTextField.stringValue = [[dict valueForKey:kJSONKeyForUser] valueForKey:kJSONKeyForUserName];
    
    // Create the NSURL with the thumbImageURL
    NSURL *URLImage = [[NSURL alloc] initWithString:[[dict valueForKey:kJSONKeyForCoverURL] valueForKey:kJSONKeyForCoverURLPx]];
    
    // Retrieve the Image from the interkatz
    [self startLoadingDataWithURL:URLImage action:kActionObtainImageData];
    
    // Stop animation for the Progress Indicator and hide it, also
    // enable the Look Up Button again!
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
    
    // Create the connection with the request
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

// --------------------------------------------------
// GENERIC METHODS startLoadingXXX:
//    Always calling the master race method:
//      -(void)startLoadingDataWithURL:action:
//
//    Because of... the SUN.
//    jmsalcido: Actually, because I did not know
//        that I could use different NSURLConnection
//        and compare them at didFinishLoadingData...
//
//        But, this approach works fine too!
//
// --------------------------------------------------
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
// PSSST: Copypasted from Apple Developers.
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

// This method is not copypasted
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Welp, this line is copypasted.
    NSLog(@"Succeeded! Received %ld bytes of data",[receivedData length]);
    
    // Transform NSData to NSString
    NSString *dataString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if([actionToPerform isEqualToString:kActionObtainPlayToken]) {
        
        #pragma mark Did Obtain Play Token
        // --------------------------------------------------
        
        // Using Framework YAJL get a NSDictionary and get the value
        playToken = [[receivedData yajl_JSON] valueForKey:kJSONKeyForPlayToken];
        
        // Also, startLoadingHTMLData now.
        [self startLoadingHTMLDataWithURL:[playlistURLTextField stringValue]];
        
    } else if([actionToPerform isEqualToString:kActionObtainHTMLData]) {
        
        #pragma mark Did Obtain HTML Data
        // --------------------------------------------------
        
        // Obtain playlistId from HTML.
        HTMLData = dataString;
        playlistId = [self obtainPlaylistIdWithHTMLString:dataString];
        
        // Also, startLoadingPlaylistData
        [self startLoadingPlaylistDataWithId:playlistId devAPIKey:[devAPIKeyTextField stringValue]];
        
    } else if([actionToPerform isEqualToString:kActionObtainPlaylistData]) {
        
        #pragma mark Did Obtain Playlist Data
        // --------------------------------------------------
        
        // I do not remember if we shall use other info, but lets comment this line.
        //NSDictionary *mainDictionary = [receivedData yajl_JSON];
        
        // Obtain the mix dictionary
        NSDictionary *mix = [[receivedData yajl_JSON] valueForKey:kJSONKeyForMix];
        
        // Update the UI
        [self updateUI:mix];
        
    } else if([actionToPerform isEqualToString:kActionObtainImageData]) {
        
        #pragma mark Did Obtain Image Data
        // --------------------------------------------------
        
        // Update NSImageView
        NSImage *image = [[NSImage alloc] initWithData:receivedData];
        [self.playlistImageView setImage:image];
        
    } else if([actionToPerform isEqualToString:kActionObtainSongData]) {
        
        #pragma mark Did Obtain Song Data
        // --------------------------------------------------
        
        // TODO
        NSLog(@"%@",[receivedData yajl_JSON]);
        
    } else {
        
        // At least it shall print what did NSURLConnection receive.
        NSLog(@"%@", dataString);
        
    }
}

@end
