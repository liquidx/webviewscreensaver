//
//  WVSSAddress.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import "WVSSAddress.h"

static NSTimeInterval const kDefaultDuration = 5 * 60.0;
static NSString * const kScreenSaverDefaultURL = @"http://www.google.com/";

@implementation WVSSAddress

+ (WVSSAddress *)addressWithURL:(NSString *)url duration:(NSInteger)duration {
  WVSSAddress *address = [[[self class] alloc] init];
  address.url = url;
  address.duration = duration;
  return address;
}

+ (WVSSAddress *)defaultAddress {
  return [self addressWithURL:kScreenSaverDefaultURL duration:kDefaultDuration];
}

+ (NSString *)defaultAddressURL {
  return kScreenSaverDefaultURL;
}

+ (NSInteger)defaultDuration {
  return kDefaultDuration;
}

- (NSDictionary *)dictionaryRepresentation {
  return @{@"url": self.url, @"duration": @(self.duration)};
}

@end
