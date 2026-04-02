//
//  WVSSBiometricAuthHandler.m
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

#import "WVSSBiometricAuthHandler.h"
#import "WVSSLog.h"

#import <AuthenticationServices/AuthenticationServices.h>

@interface WVSSBiometricAuthHandler () <ASWebAuthenticationPresentationContextProviding>
@end

@implementation WVSSBiometricAuthHandler

- (instancetype)initWithWindow:(NSWindow *)window {
  self = [super init];
  if (self) {
    _presentingWindow = window;
  }
  return self;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  // Allow all navigations so passkey and OAuth flows are not blocked.
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                   completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                               NSURLCredential *_Nullable))completionHandler {
  // Use default handling for all challenges (server trust, HTTP auth, etc.).
  // WebKit handles passkey/WebAuthn challenges internally.
  completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
  // Allow popup navigations (common in OAuth/passkey flows) to load in the
  // same web view rather than being silently dropped.
  if (navigationAction.targetFrame == nil) {
    [webView loadRequest:navigationAction.request];
  }
  return nil;
}

#pragma mark - ASWebAuthenticationPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:
    (ASWebAuthenticationSession *)session {
  return self.presentingWindow;
}

@end
