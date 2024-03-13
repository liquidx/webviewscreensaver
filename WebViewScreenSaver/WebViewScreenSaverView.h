//
//  WebViewScreenSaverView.h
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

// Codesign:
// http://www.wurst-wasser.net/wiki/index.php/How_To_codesign_a_Screen_Saver_for_Yosemite

#import <Foundation/Foundation.h>
#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>
#import "WVSSConfigController.h"
#import "WVSSAddress.h"

// A simple screen saver that is a configurable webview driven from a list
// of URLs.
@interface WebViewScreenSaverView : ScreenSaverView

@property (nonatomic, strong) WVSSConfigController *configController;

+ (WKWebView *)makeWebView:(NSRect)frame;
+ (void)loadAddress:(WVSSAddress *)address target:(WKWebView *)webView;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview prefsStore:(NSUserDefaults *)prefs;

@end
