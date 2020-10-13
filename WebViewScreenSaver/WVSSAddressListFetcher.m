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

@interface WVSSAddressListFetcher ()
@property(nonatomic, strong) NSMutableData *receivedData;
@property(nonatomic, strong) NSURLConnection *connection;
@end

@implementation WVSSAddressListFetcher

- (id)initWithURL:(NSString *)url {
  self = [super init];
  if (self) {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.connection cancel];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];
    NSLog(@"fetching URLs started");
  }
  return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"Unable to fetch URLs: %@", error);
  self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSError *jsonError = nil;
  id response = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                options:NSJSONReadingMutableContainers
                                                  error:&jsonError];
  if (jsonError) {
    NSLog(@"Unable to read connection data: %@", jsonError);
    self.connection = nil;
    [self.delegate addressListFetcher:self didFailWithError:jsonError];
    return;
  }

  if (![response isKindOfClass:[NSArray class]]) {
    NSLog(@"Expected array but got %@", [response class]);
    self.connection = nil;
    [self.delegate addressListFetcher:self didFailWithError:nil];
    return;
  }

  [self.delegate addressListFetcher:self didFinishWithArray:response];
  self.connection = nil;
  NSLog(@"fetching URLS finished");
}

@end
