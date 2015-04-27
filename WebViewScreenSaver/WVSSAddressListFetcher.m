//
//  WVSSAddressFetcher.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import "WVSSAddressListFetcher.h"

@interface WVSSAddressListFetcher ()
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;
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
