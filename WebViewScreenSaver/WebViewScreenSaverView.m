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
#import "WKWebViewPrivate.h"
#import <math.h>

// ScreenSaverDefaults module name.
static NSString *const kScreenSaverName = @"WebViewScreenSaver";

@interface WebViewScreenSaverView () <WVSSConfigControllerDelegate,
                                      WKUIDelegate,
                                      WKNavigationDelegate>

// Timer callback that loads the next URL in the URL list.
- (void)loadNext:(NSTimer *)timer;
- (void)teardownWebView;
- (void)updateWebViewFrame;
- (BOOL)isWebViewGeometryValid;
- (BOOL)isWebViewOnScreen;
- (void)forceWindowToScreen;
- (void)startLayoutGuard;
- (void)stopLayoutGuard;
- (void)showWebViewIfReady;

@end

@implementation WebViewScreenSaverView {
  NSTimer *_timer;
  NSTimer *_layoutGuard;
  WKWebView *_webView;
  NSInteger _currentIndex;
  BOOL _isPreview;
}

+ (BOOL)performGammaFade {
  return YES;
}

// Called by System Preferences/ScreenSaverEngine
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  NSUserDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
  self = [self initWithFrame:frame isPreview:isPreview prefsStore:prefs];
  
  [NSDistributedNotificationCenter.defaultCenter addObserver:self
                                                  selector:@selector(screensaverWillStop:)
                                                      name:@"com.apple.screensaver.willstop"
                                                    object:nil];
  
  return self;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview prefsStore:(NSUserDefaults *)prefs {
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self setAutoresizesSubviews:YES];

    _currentIndex = 0;
    _isPreview = isPreview;
    
    // Simplified preview
    if (_isPreview) {
      NSBundle *bundle = [NSBundle bundleForClass:self.class];
      NSImageView *logoView = [NSImageView imageViewWithImage:[bundle imageForResource:@"thumbnail"]];
      logoView.frame = self.bounds;
      logoView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
      [self addSubview:logoView];
    }

    // Load state from the preferences.
    self.configController = [[WVSSConfigController alloc] initWithUserDefaults:prefs];
    self.configController.delegate = self;
  }
  return self;
}

- (void)dealloc {
  [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
  [_timer invalidate];
  _timer = nil;
}

#pragma mark - Configure Sheet

- (BOOL)hasConfigureSheet {
  return YES;
}

- (NSWindow *)configureSheet {
  return [self.configController configureSheet];
}

- (void)configController:(WVSSConfigController *)configController
      dismissConfigSheet:(NSWindow *)sheet {
  if (_isPreview) {
    [self loadFromStart];
  }
  void (^endSheetBlock)(void) = ^{
    if ([NSApp respondsToSelector:@selector(endSheet:returnCode:)]) {
      [NSApp endSheet:sheet returnCode:NSModalResponseOK];
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
      [NSApp endSheet:sheet];
#pragma GCC diagnostic pop
    }
    [sheet orderOut:nil];
  };
  if (NSThread.isMainThread) {
    endSheetBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), endSheetBlock);
  }
}

#pragma mark ScreenSaverView

+ (WKWebView *)makeWebView:(NSRect)frame {
  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  WKPreferences *preferences = [[WKPreferences alloc] init];
  preferences.javaScriptCanOpenWindowsAutomatically = NO;
  configuration.preferences = preferences;
  
  WKWebView *webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
  webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
  NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
  webView.layer.backgroundColor = color.CGColor;
  [webView setValue:@(YES) forKey:@"drawsTransparentBackground"];  // Deprecated and internal but works
  
  return webView;
}

- (void)startAnimation {
  [super startAnimation];
  
  if (_isPreview) return;

  [self teardownWebView];

  // Create the webview for the screensaver.
  _webView = [self.class makeWebView:self.bounds];
  _webView.UIDelegate = self;
  _webView.navigationDelegate = self;
  _webView.hidden = YES;
  // Sonoma ScreenSaverEngine view hierarchy occludes webview pausing animations and JS.
  [_webView wvss_setWindowOcclusionDetectionEnabled: NO];
  [self addSubview:_webView];
  [self updateWebViewFrame];
  [self startLayoutGuard];

  if (_currentIndex < [[self selectedURLs] count]) {
    [self loadFromStart];
  }
}

- (void)stopAnimation {
  [super stopAnimation];
  
  [self teardownWebView];
}

#pragma mark Loading URLs

- (void)loadFromStart {
  _currentIndex = -1;
  [self loadNext:nil];
}

- (void)loadNext:(NSTimer *)timer {
  WVSSAddress *address = WVSSAddress.defaultAddress;
  NSInteger nextIndex = _currentIndex;

  // Last element, fetchURLs if they exist.
  if (_currentIndex == [[self selectedURLs] count] - 1) {
    [self.configController fetchAddresses];
  }

  // Progress the URL counter.
  if ([[self selectedURLs] count] > 0) {
    nextIndex = (_currentIndex + 1) % [[self selectedURLs] count];
    address = [self addressForIndex:nextIndex];
  }
  [self.class loadAddress:address target:_webView];
  [_timer invalidate];
  
  if (address.duration < 0) return;  // Infinite
  _timer = [NSTimer scheduledTimerWithTimeInterval:address.duration
                                            target:self
                                          selector:@selector(loadNext:)
                                          userInfo:nil
                                           repeats:NO];
  _currentIndex = nextIndex;
}

+ (void)loadAddress:(WVSSAddress *)address target:(WKWebView *)webView {
  NSString *urlString = address.url;
  NSURL *url = [NSURL URLWithString:urlString];

  if (url.scheme == nil) {
    NSString *escapedUrlString =
        [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
    url = [NSURL URLWithString:[@"file://" stringByAppendingString:escapedUrlString]];
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

  if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
    [webView loadRequest:request];
  } else if ([url.scheme isEqualToString:@"file"] || url.scheme == nil) {
    [webView loadFileURL:url allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
  } else {
    // no-op
  }
}

- (NSArray *)selectedURLs {
  return self.configController.addresses;
}

- (WVSSAddress *)addressForIndex:(NSInteger)index {
  return [self.configController.addresses objectAtIndex:index];
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

- (BOOL)acceptsFirstResponder {
  return NO;
}

- (BOOL)resignFirstResponder {
  return NO;
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  // Don't open new windows.
  if (navigationAction.targetFrame == nil) {
    decisionHandler(WKNavigationActionPolicyCancel);
  }
  decisionHandler(WKNavigationActionPolicyAllow);
}

// Inspired by: https://github.com/JohnCoates/Aerial/commit/8c78e7cc4f77f4417371966ae7666125d87496d1
- (void)screensaverWillStop:(NSNotification *)notification {
  if (@available(macOS 14.0, *)) {
    if (!_isPreview) {
      [self teardownWebView];
      exit(0);
    }
  }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
  [super resizeSubviewsWithOldSize:oldBoundsSize];
  [self updateWebViewFrame];
}

- (void)viewDidMoveToWindow {
  [super viewDidMoveToWindow];
  [self updateWebViewFrame];
}

- (void)teardownWebView {
  [_timer invalidate];
  _timer = nil;
  [self stopLayoutGuard];
  if (_webView) {
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
  }
}

- (void)updateWebViewFrame {
  if (_webView == nil) return;
  NSRect bounds = self.bounds;
  if (!NSEqualRects(bounds, _webView.frame)) {
    _webView.frame = bounds;
  }
  [self showWebViewIfReady];
}

- (BOOL)isWebViewGeometryValid {
  if (_webView == nil) return YES;
  NSRect bounds = NSIntegralRectWithOptions(self.bounds, NSAlignAllEdgesOutward);
  NSRect frame = NSIntegralRectWithOptions(_webView.frame, NSAlignAllEdgesOutward);
  CGFloat epsilon = 0.5;
  BOOL sizeMatches = (fabs(NSWidth(bounds) - NSWidth(frame)) <= epsilon) &&
                     (fabs(NSHeight(bounds) - NSHeight(frame)) <= epsilon);
  BOOL originMatches = (fabs(NSMinX(bounds) - NSMinX(frame)) <= epsilon) &&
                       (fabs(NSMinY(bounds) - NSMinY(frame)) <= epsilon);
  return sizeMatches && originMatches;
}

- (void)startLayoutGuard {
  if (_layoutGuard || _webView == nil) return;
  _layoutGuard =
      [NSTimer scheduledTimerWithTimeInterval:1.0
                                       target:self
                                     selector:@selector(layoutGuardFired:)
                                     userInfo:nil
                                      repeats:YES];
  _layoutGuard.tolerance = 0.2;
  [[NSRunLoop mainRunLoop] addTimer:_layoutGuard forMode:NSRunLoopCommonModes];
}

- (void)stopLayoutGuard {
  [_layoutGuard invalidate];
  _layoutGuard = nil;
}

- (void)layoutGuardFired:(NSTimer *)timer {
  if (_webView == nil) return;
  BOOL geometryOK = [self isWebViewGeometryValid];
  BOOL onScreen = [self isWebViewOnScreen];
  if (geometryOK && onScreen) return;

  [self updateWebViewFrame];
  if (!onScreen) {
    [self forceWindowToScreen];
  }
  geometryOK = [self isWebViewGeometryValid];
  onScreen = [self isWebViewOnScreen];
  if (!(geometryOK && onScreen)) {
    [_webView removeFromSuperview];
    [self addSubview:_webView];
    [self updateWebViewFrame];
    [self forceWindowToScreen];
    [_webView wvss_setWindowOcclusionDetectionEnabled:NO];
  }
  if ([self isWebViewGeometryValid] && [self isWebViewOnScreen]) {
    [self showWebViewIfReady];
  }
}

- (NSScreen *)targetScreen {
  NSScreen *screen = self.window.screen;
  if (!screen) screen = NSScreen.mainScreen;
  if (!screen) screen = NSScreen.screens.firstObject;
  return screen;
}

- (BOOL)isWebViewOnScreen {
  if (_webView == nil) return YES;
  NSScreen *screen = [self targetScreen];
  if (!screen) return YES;
  NSRect expected = screen.frame;
  NSRect viewInWindow = [self convertRect:_webView.frame toView:nil];
  NSRect viewOnScreen = self.window ? [self.window convertRectToScreen:viewInWindow] : viewInWindow;
  NSRect intersection = NSIntersectionRect(expected, viewOnScreen);
  CGFloat epsilon = 0.5;
  BOOL coversWidth = (NSWidth(intersection) + epsilon) >= NSWidth(viewOnScreen);
  BOOL coversHeight = (NSHeight(intersection) + epsilon) >= NSHeight(viewOnScreen);
  return coversWidth && coversHeight;
}

- (void)forceWindowToScreen {
  NSScreen *screen = [self targetScreen];
  if (!screen) return;
  NSRect screenFrame = screen.frame;
  if (self.window && !NSEqualRects(self.window.frame, screenFrame)) {
    [self.window setFrame:screenFrame display:NO];
  }
  if (self.superview) {
    self.frame = self.superview.bounds;
  } else {
    self.frame = NSMakeRect(0, 0, NSWidth(screenFrame), NSHeight(screenFrame));
  }
  [self updateWebViewFrame];
}

- (void)showWebViewIfReady {
  if (_webView == nil || !_webView.isHidden) return;
  if ([self isWebViewGeometryValid] && [self isWebViewOnScreen]) {
    _webView.hidden = NO;
    [_webView setNeedsDisplay:YES];
  }
}

@end
