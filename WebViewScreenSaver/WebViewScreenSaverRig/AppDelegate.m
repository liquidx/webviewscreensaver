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

@property (weak) IBOutlet NSWindow *window;
@property(strong) WVSSConfigController *configController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  self.configController = [[WVSSConfigController alloc] initWithUserDefaults:userDefaults];
  self.configController.delegate = self;

  NSWindow *window = [self.configController configureSheet];
  [self.window addChildWindow:window ordered:NSWindowAbove];

  WebViewScreenSaverView *wvsv = [[WebViewScreenSaverView alloc] initWithFrame:window.frame];
  wvsv.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  self.window.contentView = wvsv;

  [wvsv startAnimation];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

- (void)configController:(WVSSConfigController *)configController dismissConfigSheet:(NSWindow *)sheet {
  [sheet close];
}

@end
