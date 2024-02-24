//
//  WKWebViewPrivate.m
//  WebViewScreenSaver
//
//  Created by Alexandru Gologan on 24.02.2024.
//
//  Copyright 2024 Alexandru Gologan.
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

#import "WKWebViewPrivate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation WKWebView (Compat)

- (void)wvss_setWindowOcclusionDetectionEnabled:(BOOL)enabled {
  if ([self respondsToSelector:@selector(_setWindowOcclusionDetectionEnabled:)]) {
    [self _setWindowOcclusionDetectionEnabled:enabled];
  }
}

#pragma clang diagnostic pop

@end
