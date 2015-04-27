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

// Keys for the dictionaries in kScreenSaverURLList - string values should not be changed.
NSString * const kWVSSAddressURLKey = @"kScreenSaverURL";
NSString * const kWVSSAddressTimeKey = @"kScreenSaverTime";

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
  return @{kWVSSAddressURLKey: self.url, kWVSSAddressTimeKey: @(self.duration)};
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ : %@ for %ld>", [self className], self.url, self.duration];
}

@end
