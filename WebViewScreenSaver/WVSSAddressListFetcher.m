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
#import "WVSSAddress.h"
#import "WVSSLog.h"

NSExceptionName const WVSSInvalidArgumentException = @"WVSSInvalidArgumentException";

@interface WVSSAddressListFetcher () {
  NSURLSessionTask *_task;
}

@end

@implementation WVSSAddressListFetcher

- (id)initWithURL:(NSString *)url {
  self = [super init];
  if (self) {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    _task = [NSURLSession.sharedSession
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                              NSError *_Nullable error) {
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
    [self.delegate addressListFetcher:self didFailWithError:error];
    return;
  }

  NSError *jsonError = nil;
  id response = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&jsonError];
  if (jsonError) {
    [self.delegate addressListFetcher:self didFailWithError:jsonError];
    return;
  }

  NSMutableArray *parsed = [[NSMutableArray alloc] init];

  @try {
    expectClass(response, NSArray.class);
    for (NSDictionary *item in (NSArray *)response) {
      expectClass(item, NSDictionary.class);

      id url = item[@"url"];
      id duration = item[@"duration"];

      expectClass(url, NSString.class);
      expectClass(duration, NSNumber.class);

      [parsed addObject:[WVSSAddress addressWithURL:url duration:[(NSNumber *)duration intValue]]];
    }

    [self.delegate addressListFetcher:self didFinishWithArray:parsed];
  } @catch (NSException *exception) {
    if ([exception.name isEqualToString:WVSSInvalidArgumentException]) {
      NSError *error = [NSError errorWithDomain:WVSSInvalidArgumentException
                                           code:-1
                                       userInfo:@{NSLocalizedDescriptionKey : exception.reason}];
      [self.delegate addressListFetcher:self didFailWithError:error];
    } else {
      [exception raise];
    }
  }

  WVSSLog(@"fetching URLS finished");
}

void expectClass(id target, Class aclass) {
  if (![target isKindOfClass:aclass]) {
    NSString *reason =
        [NSString stringWithFormat:@"Expected %@ but got %@", NSStringFromClass(aclass),
                                   NSStringFromClass([target class])];
    NSException *exc = [NSException exceptionWithName:WVSSInvalidArgumentException
                                               reason:reason
                                             userInfo:nil];
    [exc raise];
  }
}

@end
