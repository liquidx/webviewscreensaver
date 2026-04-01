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

#import <LocalAuthentication/LocalAuthentication.h>
#import <AuthenticationServices/AuthenticationServices.h>

API_AVAILABLE(macos(12.0))
@interface WVSSBiometricAuthHandler () <ASAuthorizationControllerDelegate,
                                        ASAuthorizationControllerPresentationContextProviding>
@end

@implementation WVSSBiometricAuthHandler

- (instancetype)initWithWindow:(NSWindow *)window {
  self = [super init];
  if (self) {
    _presentingWindow = window;
  }
  return self;
}

#pragma mark - Biometric Availability

+ (BOOL)isBiometricAvailable {
  LAContext *context = [[LAContext alloc] init];
  NSError *error = nil;
  BOOL available = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                        error:&error];
  if (!available) {
    WVSSLog(@"Biometric auth not available: %@", error.localizedDescription);
  }
  return available;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                   completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                               NSURLCredential *_Nullable))completionHandler {
  NSString *method = challenge.protectionSpace.authenticationMethod;
  WVSSLog(@"Auth challenge received: %@", method);

  // For server trust (HTTPS certificate validation), use default handling.
  if ([method isEqualToString:NSURLAuthenticationMethodServerTrust]) {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    return;
  }

  // For HTTP basic/digest auth, prompt for biometric before showing credential dialog.
  if ([method isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
      [method isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
    [self authenticateWithBiometricForChallenge:challenge completionHandler:completionHandler];
    return;
  }

  completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)authenticateWithBiometricForChallenge:(NSURLAuthenticationChallenge *)challenge
                            completionHandler:
                                (void (^)(NSURLSessionAuthChallengeDisposition,
                                          NSURLCredential *_Nullable))completionHandler {
  LAContext *context = [[LAContext alloc] init];
  NSError *error = nil;

  if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
    WVSSLog(@"Biometrics unavailable, falling back to default: %@", error.localizedDescription);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    return;
  }

  NSString *reason =
      [NSString stringWithFormat:@"Authenticate to access %@", challenge.protectionSpace.host];
  [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
          localizedReason:reason
                    reply:^(BOOL success, NSError *_Nullable authError) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                          WVSSLog(@"Biometric auth succeeded for %@",
                                  challenge.protectionSpace.host);
                          // Use default handling - the system keychain can now provide credentials
                          // since the user has authenticated biometrically.
                          completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                        } else {
                          WVSSLog(@"Biometric auth failed: %@", authError.localizedDescription);
                          completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,
                                            nil);
                        }
                      });
                    }];
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
  // Allow popup navigations to load in the same web view (e.g. OAuth flows).
  if (navigationAction.targetFrame == nil) {
    [webView loadRequest:navigationAction.request];
  }
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:
    (ASAuthorizationController *)controller API_AVAILABLE(macos(12.0)) {
  return self.presentingWindow;
}

#pragma mark - ASAuthorizationControllerDelegate

- (void)authorizationController:(ASAuthorizationController *)controller
    didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(macos(12.0)) {
  WVSSLog(@"ASAuthorization completed: %@", authorization.credential);
}

- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(macos(12.0)) {
  WVSSLog(@"ASAuthorization failed: %@", error.localizedDescription);
}

@end
