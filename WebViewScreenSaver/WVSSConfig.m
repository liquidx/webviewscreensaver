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
// Keys for the dictionaries in kScreenSaverURLList.
static NSString * const kScreenSaverURLKey = @"kScreenSaverURL";
static NSString * const kScreenSaverTimeKey = @"kScreenSaverTime";


@interface WVSSConfig ()
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) NSMutableArray *addresses;
@end

@implementation WVSSConfig

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  self = [super init];
  if (self) {
    self.userDefaults = userDefaults;

    self.addresses = [[userDefaults arrayForKey:kScreenSaverURLListKey] mutableCopy];
    self.addressListURL = [userDefaults stringForKey:kScreenSaverURLsURLKey];
    self.shouldFetchAddressList = [userDefaults boolForKey:kScreenSaverFetchURLsKey];

    if (!self.addresses) {
      self.addresses = [NSMutableArray array];
    }
  }
  return self;
}

- (void)synchronize {
  [self.userDefaults setObject:self.addresses forKey:kScreenSaverURLListKey];
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
