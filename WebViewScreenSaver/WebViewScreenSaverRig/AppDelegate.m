//
//  AppDelegate.m
//  WebViewScreenSaverRig
//
//  Created by Alastair Tse on 26/04/2015.
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

#import "AppDelegate.h"
#import "WVSSConfigController.h"
#import "WebViewScreenSaverView.h"

@interface AppDelegate () <WVSSConfigControllerDelegate>

@property(weak) IBOutlet NSWindow *window;
@property(strong) WVSSConfigController *configController;
@end

@implementation AppDelegate {
  WVSSConfig *_config;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  _config = [[WVSSConfig alloc] initWithUserDefaults:userDefaults];

  [self reloadWebView];
  [self.window makeKeyWindow];

  [self performSelector:@selector(showPreferences:) withObject:nil afterDelay:0];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

- (void)configController:(WVSSConfigController *)configController
      dismissConfigSheet:(NSWindow *)sheet {
  [self reloadWebView];
  [sheet close];
  self.configController = nil;
}

- (IBAction)showPreferences:(id)sender {
  self.configController = [[WVSSConfigController alloc] initWithConfig:_config];
  self.configController.delegate = self;
  [self.window beginSheet:self.configController.sheet completionHandler:nil];
}

- (IBAction)reloadWebView {
  WebViewScreenSaverView *wvsv;

  // Remove the older webview
  if ([self.window.contentView subviews]) {
    wvsv = (WebViewScreenSaverView *)[[self.window.contentView subviews] firstObject];
    [wvsv stopAnimation];
    [wvsv removeFromSuperview];
  }

  // Recreate the subview.
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSRect bounds = [self.window.contentView bounds];
  wvsv = [[WebViewScreenSaverView alloc] initWithFrame:bounds isPreview:NO prefsStore:userDefaults];
  wvsv.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [self.window.contentView addSubview:wvsv];
  [wvsv startAnimation];
}

@end
