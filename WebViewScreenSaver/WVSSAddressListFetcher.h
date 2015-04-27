//
//  WVSSAddressFetcher.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import <Foundation/Foundation.h>

@protocol WVSSAddressListFetcherDelegate;

@interface WVSSAddressListFetcher : NSObject
@property(nonatomic, weak) id<WVSSAddressListFetcherDelegate> delegate;

- (id)initWithURL:(NSString *)url;
@end

@protocol WVSSAddressListFetcherDelegate <NSObject>
- (void)addressListFetcher:(WVSSAddressListFetcher *)fetcher
          didFailWithError:(NSError *)error;

- (void)addressListFetcher:(WVSSAddressListFetcher *)fetcher
        didFinishWithArray:(NSArray *)response;
@end
