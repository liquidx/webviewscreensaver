//
//  WVSSAddressFetcher.m
//  WebViewScreenSaver
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

#import "WVSSAddressListFetcher.h"

@interface WVSSAddressListFetcher () {
  NSURLSessionTask *_task;
}

@end

@implementation WVSSAddressListFetcher

- (id)initWithURL:(NSString *)url {
  self = [super init];
  if (self) {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    _task = [NSURLSession.sharedSession dataTaskWithRequest:request
                                          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self didFinishLoading:data error:error];
      });
    }];
    [_task resume];
  }
  return self;
}

- (void)didFinishLoading:(NSData *)data error:(NSError *)error {
  if (error != nil) {
    NSLog(@"Unable to fetch URLs: %@", error);
    [self.delegate addressListFetcher:self didFailWithError:error];
    return;
  }
  
  NSError *jsonError = nil;
  id response = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&jsonError];
  if (jsonError) {
    NSLog(@"Unable to read connection data: %@", jsonError);
    [self.delegate addressListFetcher:self didFailWithError:jsonError];
    return;
  }

  if (![response isKindOfClass:[NSArray class]]) {
    NSLog(@"Expected array but got %@", [response class]);
    [self.delegate addressListFetcher:self didFailWithError:nil];
    return;
  }

  [self.delegate addressListFetcher:self didFinishWithArray:response];
  NSLog(@"fetching URLS finished");
}

@end
