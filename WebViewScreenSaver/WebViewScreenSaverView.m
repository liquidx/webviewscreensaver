//
//  WebViewScreenSaverView.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 8/8/10.
//
//  Copyright 2015 Alastair Tse.
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
#import "WVSSAddress.h"

// ScreenSaverDefaults module name.
static NSString * const kScreenSaverName = @"WebViewScreenSaver";
// Default intervals.
static NSTimeInterval const kOneMinute = 60.0;


@interface WebViewScreenSaverView () <
  WVSSConfigControllerDelegate,
  WebEditingDelegate,
  WebFrameLoadDelegate,
  WebPolicyDelegate,
  WebUIDelegate>
// Timer callback that loads the next URL in the URL list.
- (void)loadNext:(NSTimer *)timer;
// Returns the URL for the index in the preferences.
- (NSString *)urlForIndex:(NSInteger)index;
// Returns the time interval in the preferences.
- (NSTimeInterval)timeIntervalForIndex:(NSInteger)index;
@end


@implementation WebViewScreenSaverView {
  NSTimer *_timer;
  WebView *_webView;
  NSInteger _currentIndex;
  BOOL _isPreview;
}

+ (BOOL)performGammaFade {
  return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  NSUserDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
  return [self initWithFrame:frame isPreview:isPreview prefsStore:prefs];
}


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview prefsStore:(NSUserDefaults *)prefs {
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self setAutoresizesSubviews:YES];

    _currentIndex = 0;
    _isPreview = isPreview;

    // Load state from the preferences.
    self.configController = [[WVSSConfigController alloc] initWithUserDefaults:prefs];
    self.configController.delegate = self;
  }
  return self;
}

- (void)dealloc {
  [_webView setFrameLoadDelegate:nil];
  [_webView setPolicyDelegate:nil];
  [_webView setUIDelegate:nil];
  [_webView setEditingDelegate:nil];
  [_webView close];
  [_timer invalidate];
  _timer = nil;
}

#pragma mark - Configure Sheet

- (BOOL)hasConfigureSheet {
  return YES;
}

//- (void)setFrame:(NSRect)frameRect {
//  [super setFrame:frameRect];
//}

- (NSWindow *)configureSheet {
  return [self.configController configureSheet];
}

- (void)configController:(WVSSConfigController *)configController dismissConfigSheet:(NSWindow *)sheet {
  if (_isPreview) {
    [self loadFromStart];
  }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  [[NSApplication sharedApplication] endSheet:sheet];
#pragma GCC diagnostic pop
}

#pragma mark ScreenSaverView

- (void)startAnimation {
  [super startAnimation];

  //NSLog(@"startAnimation: %d %@", [NSThread isMainThread], [NSThread currentThread]);

  // Create the webview for the screensaver.
  _webView = [[WebView alloc] initWithFrame:[self bounds]];
  [_webView setFrameLoadDelegate:self];
  [_webView setShouldUpdateWhileOffscreen:YES];
  [_webView setPolicyDelegate:self];
  [_webView setUIDelegate:self];
  [_webView setEditingDelegate:self];
  [_webView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
  [_webView setAutoresizesSubviews:YES];
  [_webView setDrawsBackground:NO];
  [self addSubview:_webView];

  NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
  [[_webView layer] setBackgroundColor:color.CGColor];

  if (!_isPreview && _currentIndex < [[self selectedURLs] count]) {
    [self loadFromStart];
  }
}

- (void)stopAnimation {
  [super stopAnimation];
  [_timer invalidate];
  _timer = nil;
  [_webView removeFromSuperview];
  [_webView close];
  _webView = nil;
}

#pragma mark Loading URLs

- (void)loadFromStart {
  NSTimeInterval duration = [WVSSAddress defaultDuration];
  NSString *url = [WVSSAddress defaultAddressURL];
  _currentIndex = 0;

  if ([[self selectedURLs] count]) {
    duration = [self timeIntervalForIndex:_currentIndex];
    url = [self urlForIndex:_currentIndex];
  }

  [self loadURLThing:url];
  [_timer invalidate];
  _timer = [NSTimer scheduledTimerWithTimeInterval:duration
                                            target:self
                                          selector:@selector(loadNext:)
                                          userInfo:nil
                                           repeats:NO];
}

- (void)loadNext:(NSTimer *)timer {
  NSTimeInterval duration = [WVSSAddress defaultDuration];
  NSString *url = [WVSSAddress defaultAddressURL];
  NSInteger nextIndex = _currentIndex;

  // Last element, fetchURLs if they exist.
  if (_currentIndex == [[self selectedURLs] count] - 1) {
    [self.configController fetchAddresses];
  }

  // Progress the URL counter.
  if ([[self selectedURLs] count] > 0) {
    nextIndex = (_currentIndex + 1) % [[self selectedURLs] count];
    duration = [self timeIntervalForIndex:nextIndex];
    url = [self urlForIndex:nextIndex];
  }
  [self loadURLThing:url];
  [_timer invalidate];
  _timer = [NSTimer scheduledTimerWithTimeInterval:duration
                                            target:self
                                          selector:@selector(loadNext:)
                                          userInfo:nil
                                           repeats:NO];
  _currentIndex = nextIndex;
}

- (void)loadURLThing:(NSString *)url {
  NSString *javascriptPrefix = @"javascript:";

  if ([url isKindOfClass:[NSURL class]]) {
    url = [(NSURL *)url absoluteString];
  }

  if([url hasPrefix:javascriptPrefix]) {
    [_webView stringByEvaluatingJavaScriptFromString:url];
  } else {
    [_webView setMainFrameURL:url];
  }
}

- (NSArray *)selectedURLs {
  return self.configController.addresses;
}


- (NSString *)urlForIndex:(NSInteger)index {
  WVSSAddress *address = [self.configController.addresses objectAtIndex:index];
  return address.url;
}

- (NSTimeInterval)timeIntervalForIndex:(NSInteger)index {
  WVSSAddress *address = [self.configController.addresses objectAtIndex:index];
  if (address) {
    return (NSTimeInterval)address.duration;
  } else {
    return kOneMinute;
  }
}

- (void)animateOneFrame {
  [super animateOneFrame];
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

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame {
  NSLog(@"unableToImplement: %@", error);
}

#pragma mark WebUIDelegate

- (NSResponder *)webViewFirstResponder:(WebView *)sender {
  return self;
}

- (void)webViewClose:(WebView *)sender {
  return;
}

- (BOOL)webViewIsResizable:(WebView *)sender {
  return NO;
}

- (BOOL)webViewIsStatusBarVisible:(WebView *)sender {
  return NO;
}

- (void)webViewRunModal:(WebView *)sender {
  return;
}

- (void)webViewShow:(WebView *)sender {
  return;
}

- (void)webViewUnfocus:(WebView *)sender {
  return;
}


@end
