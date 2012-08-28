//
//  WebViewScreenSaverView.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 8/8/10.
//
//  Copyright 2010 Alastair Tse.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "WebViewScreenSaverView.h"

// ScreenSaverDefaults module name.
static NSString * const kScreenSaverName = @"WebViewScreenSaver";
// ScreenSaverDefault Keys
static NSString * const kScreenSaverURLsURLKey = @"kScreenSaverURLsURL";  // NSString (URL)
static NSString * const kScreenSaverURLListKey = @"kScreenSaverURLList";  // NSArray of NSDictionary
// Keys for the dictionaries in kScreenSaverURLList.
static NSString * const kScreenSaverURLKey = @"kScreenSaverURL";
static NSString * const kScreenSaverTimeKey = @"kScreenSaverTime";
// Default intervals.
static NSTimeInterval const kOneMinute = 60.0;
static NSTimeInterval const kDefaultDuration = 5 * 60.0;
static NSString * const kScreenSaverDefaultURL = @"http://www.google.com/";
// Configuration sheet columns.
static NSString * const kTableColumnURL = @"url";
static NSString * const kTableColumnTime = @"time";

@interface WebViewScreenSaverView ()
// Timer callback that loads the next URL in the URL list.
- (void)loadNext:(NSTimer *)timer;
// Returns the URL for the index in the preferences.
- (NSString *)urlForIndex:(NSInteger)index;
// Returns the time interval in the preferences.
- (NSTimeInterval)timeIntervalForIndex:(NSInteger)index;
// Sets the URL in the preferences at index.
- (void)setURL:(NSString *)url forIndex:(NSInteger)index;
// Sets the time interval in the preferences at the index.
- (void)setTimeInterval:(NSTimeInterval)timeInterval forIndex:(NSInteger)index;

// Fetches URLs from the URLsURL
- (void)fetchURLs;
@end


@implementation WebViewScreenSaverView

@synthesize connection = connection_;
@synthesize receivedData = receivedData_;
@synthesize sheet = sheet_;
@synthesize urls = urls_;
@synthesize urlList = urlList_;
@synthesize urlsURL = urlsURL_;
@synthesize urlsURLField = urlsURLField_;

+ (BOOL)performGammaFade {
  return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    currentIndex_ = 0;
    
    // Create the webview for the screensaver.
    webView_ = [[WebView alloc] initWithFrame:[self bounds]];
    [webView_ setFrameLoadDelegate:self];
    [webView_ setShouldUpdateWhileOffscreen:YES];
    [webView_ setPolicyDelegate:self];
    [webView_ setUIDelegate:self];
    [webView_ setEditingDelegate:self];
    [webView_ setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [webView_ setAutoresizesSubviews:YES];
    [webView_ setDrawsBackground:NO];
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
    [[webView_ layer] setBackgroundColor:color.CGColor];
    
    // Load state from the preferences.
    ScreenSaverDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
    self.urls = [[[prefs arrayForKey:kScreenSaverURLListKey] mutableCopy] autorelease];
    self.urlsURL = [prefs stringForKey:kScreenSaverURLsURLKey];
    
    // If there are no URLs set, add a single default URL entry and save it.
    if (![self.urls count] || ![[self.urls objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
      self.urls = [[[NSMutableArray alloc] init] autorelease];
      [self addRow:nil];
      [prefs setObject:self.urls forKey:kScreenSaverURLListKey];
      [prefs synchronize];      
    }
    
    // Fetch URLs if we're using the URLsURL.
    [self fetchURLs];
    
    if (currentIndex_ < [urls_ count]) {
      [webView_ setMainFrameURL:[self urlForIndex:currentIndex_]];
      NSTimeInterval nextRefresh = [self timeIntervalForIndex:currentIndex_];
      [NSTimer scheduledTimerWithTimeInterval:nextRefresh
                                       target:self
                                     selector:@selector(loadNext:)
                                     userInfo:nil
                                      repeats:NO];
    }

    [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self setAutoresizesSubviews:YES];
    [self addSubview:webView_];
  }
  return self;
}

- (void)dealloc {
  NSLog(@"dealloc");
  [sheet_ release];
  [webView_ setPolicyDelegate:nil];
  [webView_ setUIDelegate:nil];
  [webView_ setEditingDelegate:nil];
  [webView_ close];
  [webView_ release];
  self.urlsURL = nil;
  self.urls = nil;
  self.urlsURLField = nil;
  self.urlList = nil;
  self.receivedData = nil;
  [super dealloc];
}

- (BOOL)hasConfigureSheet {
  return YES;
}

//- (void)setFrame:(NSRect)frameRect {
//  [super setFrame:frameRect];
//}

- (NSWindow *)configureSheet {
  if (!sheet_) {
    if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) {
      NSLog(@"Unable to load configuration sheet");
    }
    
    // If there is a urlListURL.
    if (self.urlsURL.length) {
      self.urlsURLField.stringValue = self.urlsURL;
    } else {
      self.urlsURLField.stringValue = @"";
    }
  }
  return sheet_;
}

#pragma mark Loading URLs

- (void)loadNext:(NSTimer *)timer {
  NSTimeInterval duration = kDefaultDuration;
  NSString *url = kScreenSaverDefaultURL;
  NSInteger nextIndex = currentIndex_;
  
  // Last element, fetchURLs if they exist.
//  if (currentIndex_ == [urls_ count] - 1) {
//    [self fetchURLs];
//  }

  // Progress the URL counter.
  if ([urls_ count] > 0) {
    nextIndex = (currentIndex_ + 1) % [urls_ count];
    duration = [self timeIntervalForIndex:nextIndex];
    url = [self urlForIndex:nextIndex];
  }
  [webView_ setMainFrameURL:url];
  [NSTimer scheduledTimerWithTimeInterval:duration
                                   target:self
                                 selector:@selector(loadNext:)
                                 userInfo:nil
                                  repeats:NO];
  currentIndex_ = nextIndex;
}

- (NSString *)urlForIndex:(NSInteger)index {
  if (index < [self.urls count]) {
    NSDictionary *urlObject = [self.urls objectAtIndex:index];
    return [urlObject objectForKey:kScreenSaverURLKey];
  }
  return nil;
}

- (NSTimeInterval)timeIntervalForIndex:(NSInteger)index {
  if (index < [urls_ count]) {
    NSDictionary *urlObject = [urls_ objectAtIndex:index];
    NSNumber *seconds = [urlObject objectForKey:kScreenSaverTimeKey];
    return [seconds floatValue];
  }
  return kOneMinute;
}

- (void)setURL:(NSString *)url forIndex:(NSInteger)index {
  if (index < [urls_ count]) {
    NSMutableDictionary *urlObject = [[urls_ objectAtIndex:index] mutableCopy];
    [urlObject setObject:url forKey:kScreenSaverURLKey];
    [urls_ replaceObjectAtIndex:index withObject:urlObject];
    [urlObject release];
  }
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval forIndex:(NSInteger)index {
  if (index < [urls_ count]) {
    NSMutableDictionary *urlObject = [[urls_ objectAtIndex:index] mutableCopy];
    [urlObject setObject:[NSNumber numberWithFloat:timeInterval]
                  forKey:kScreenSaverTimeKey];
    [urls_ replaceObjectAtIndex:index withObject:urlObject];
    [urlObject release];    
  }
}

- (void)fetchURLs {
  NSLog(@"fetching URLs");
  if (!self.urlsURL.length) return;
  if (!([self.urlsURL hasPrefix:@"http://"] || [self.urlsURL hasPrefix:@"https://"])) return;

  NSURL *url = [NSURL URLWithString:self.urlsURL];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [self.connection cancel];
  self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
  [self.connection start];
  NSLog(@"fetching URLs started");
}

#pragma mark NSURLConnection

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"Unable to fetch URLs: %@", error);
  self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSError *jsonError = nil;
  id response = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                options:NSJSONReadingMutableContainers
                                                  error:&jsonError];
  if (jsonError) {
    NSLog(@"Unable to read connection data: %@", jsonError);
    self.connection = nil;
    return;
  }
  
  if ([response isKindOfClass:[NSArray class]]) {
    self.urls = [[response mutableCopy] autorelease];
    [self.urlList reloadData];
    
    currentIndex_ = -1;
    [self loadNext:nil];
  }
  self.connection = nil;
  NSLog(@"fetching URLS finished");
}



#pragma mark NSTableView

- (id)tableView:(NSTableView *)aTableView
      objectValueForTableColumn:(NSTableColumn *)aTableColumn
      row:(NSInteger)rowIndex {
  if ([[aTableColumn identifier] isEqual:kTableColumnURL]) {
    return [self urlForIndex:rowIndex];
  } else if ([[aTableColumn identifier] isEqual:kTableColumnTime]) {
    NSTimeInterval seconds = [self timeIntervalForIndex:rowIndex];
    return [NSNumber numberWithInt:(seconds / kOneMinute)];
  }
  return nil;
}  

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex {
  if (rowIndex < [urls_ count]) {
    if ([[aTableColumn identifier] isEqual:kTableColumnURL] &&
        [anObject isKindOfClass:[NSString class]]) {
      [self setURL:anObject forIndex:rowIndex];
    } else if ([[aTableColumn identifier] isEqual:kTableColumnTime] &&
               [anObject isKindOfClass:[NSString class]]) {
      NSInteger minutes = [anObject intValue];
      [self setTimeInterval:(minutes * kOneMinute) forIndex:rowIndex];
    }
  }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  return [urls_ count];
}

- (IBAction)addRow:(id)sender {
  NSDictionary *urlSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                              kScreenSaverDefaultURL,
                              kScreenSaverURLKey,
                              [NSNumber numberWithFloat:kDefaultDuration],
                              kScreenSaverTimeKey,
                              nil];
  [self.urls addObject:urlSetting];
  [self.urlList reloadData];
}

- (IBAction)removeRow:(id)sender {
  NSInteger row = [urlList_ selectedRow];
  if (row != NSNotFound) {
    [urls_ removeObjectAtIndex:row];
    [urlList_ reloadData];
  }
}

#pragma mark Focus Overrides

// A bunch of methods that captures all the input events to prevent
// the webview from getting any keyboard focus.

- (NSView *)hitTest:(NSPoint)aPoint {
  return self;
}

- (void)keyDown:(NSEvent *)theEvent {
  return;
}

- (void)keyUp:(NSEvent *)theEvent {
  return;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)resignFirstResponder {
  return NO;
}

#pragma mark Sheet

- (IBAction)dismissConfigSheet:(id)sender {
  // Save preferences.
  ScreenSaverDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
  [prefs setObject:self.urls forKey:kScreenSaverURLListKey];
  
  self.urlsURL = self.urlsURLField.stringValue;
  if (self.urlsURL.length) {
    [prefs setObject:self.urlsURL forKey:kScreenSaverURLsURLKey];
    [self fetchURLs];
  } else {
    [prefs removeObjectForKey:kScreenSaverURLsURLKey];
  }
  
  [prefs synchronize];

  if ([self.urls count]) {
    [webView_ setMainFrameURL:[self urlForIndex:0]];
  }
  
  [[NSApplication sharedApplication] endSheet:sheet_];
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView
    decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
    request:(NSURLRequest *)request
    newFrameName:(NSString *)frameName
    decisionListener:(id < WebPolicyDecisionListener >)listener {
  // Don't open new windows.
  [listener ignore];
}
     
- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame {
  [webView resignFirstResponder];
  [[[webView mainFrame] frameView] setAllowsScrolling:NO];
  //[webView setDrawsBackground:YES];
}
       
#pragma mark WebUIDelegate

- (NSResponder *)webViewFirstResponder:(WebView *)sender {
  return self;
}

- (void)webViewClose:(WebView *)sender {
  return;
}

@end
