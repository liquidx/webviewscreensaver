//
//  WVSSConfig.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import "WVSSConfig.h"
#import "WVSSAddress.h"

// ScreenSaverDefault Keys
static NSString * const kScreenSaverFetchURLsKey = @"kScreenSaverFetchURLs";  // BOOL
static NSString * const kScreenSaverURLsURLKey = @"kScreenSaverURLsURL";  // NSString (URL)
static NSString * const kScreenSaverURLListKey = @"kScreenSaverURLList";  // NSArray of NSDictionary


@interface WVSSConfig ()
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) NSMutableArray *addresses;
@end

@implementation WVSSConfig

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  self = [super init];
  if (self) {
    self.userDefaults = userDefaults;

    self.addresses = [self loadAddressesFromUserDefaults:userDefaults];
    self.addressListURL = [userDefaults stringForKey:kScreenSaverURLsURLKey];
    self.shouldFetchAddressList = [userDefaults boolForKey:kScreenSaverFetchURLsKey];

    NSLog(@"Loaded Addresses: %@", self.addresses);

    if (!self.addresses) {
      self.addresses = [NSMutableArray array];
    }
  }
  return self;
}

- (NSMutableArray *)loadAddressesFromUserDefaults:(NSUserDefaults *)userDefaults {
  NSArray *addressesFromUserDefaults = [[userDefaults arrayForKey:kScreenSaverURLListKey] mutableCopy];
  NSMutableArray *addresses = [NSMutableArray array];
  for (NSDictionary *addressDictionary in addressesFromUserDefaults) {

    NSString *url = addressDictionary[kWVSSAddressURLKey];
    NSInteger time = [addressDictionary[kWVSSAddressTimeKey] integerValue];
    if (url) {
      WVSSAddress *address = [WVSSAddress addressWithURL:url duration:time];
      [addresses addObject:address];
    }
  }
  return addresses;
}

- (void)saveAddressesToUserDefaults:(NSUserDefaults *)userDefaults {
  NSMutableArray *addressesForUserDefaults = [NSMutableArray array];
  for (WVSSAddress *address in self.addresses) {
    [addressesForUserDefaults addObject:[address dictionaryRepresentation]];
  }
  NSLog(@"Saved Addresses: %@", addressesForUserDefaults);

  [userDefaults setObject:addressesForUserDefaults forKey:kScreenSaverURLListKey];
}

- (void)synchronize {
  [self saveAddressesToUserDefaults:self.userDefaults];
  [self.userDefaults setBool:self.shouldFetchAddressList forKey:kScreenSaverFetchURLsKey];

  if (self.addressListURL.length) {
    [self.userDefaults setObject:self.addressListURL forKey:kScreenSaverURLsURLKey];
  } else {
    [self.userDefaults removeObjectForKey:kScreenSaverURLsURLKey];
  }
  [self.userDefaults synchronize];

}

- (void)addAddressWithURL:(NSString *)url duration:(NSInteger)duration {
  WVSSAddress *address = [WVSSAddress addressWithURL:url duration:duration];
  [self.addresses addObject:address];
}


@end
