//
//  WVSSConfig.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import <Foundation/Foundation.h>

@class WVSSAddress;

@interface WVSSConfig : NSObject

@property(nonatomic, strong, readonly) NSMutableArray *addresses;
@property(nonatomic, strong) NSString *addressListURL;
@property(nonatomic, assign) BOOL shouldFetchAddressList;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;
- (void)synchronize;

@end
