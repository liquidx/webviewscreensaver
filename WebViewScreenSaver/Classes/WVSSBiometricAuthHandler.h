//
//  WVSSBiometricAuthHandler.h
//  WebViewScreenSaver
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

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

// Handles WKWebView delegates for the preview window, enabling passkey/WebAuthn
// login by providing a presentation anchor and allowing auth-related navigations.
@interface WVSSBiometricAuthHandler : NSObject <WKNavigationDelegate, WKUIDelegate>

@property(nonatomic, weak) NSWindow *presentingWindow;

- (instancetype)initWithWindow:(NSWindow *)window;

@end
