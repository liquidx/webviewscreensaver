//
//  WVSSAddress.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import <Foundation/Foundation.h>

@interface WVSSAddress : NSObject
@property(nonatomic, strong) NSString *url;
@property(nonatomic, assign) NSInteger duration;

+ (NSString *)defaultAddressURL;
+ (NSInteger)defaultDuration;

+ (WVSSAddress *)addressWithURL:(NSString *)url duration:(NSInteger)duration;
+ (WVSSAddress *)defaultAddress;

- (NSDictionary *)dictionaryRepresentation;

@end
