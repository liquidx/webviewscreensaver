//
//  BSHTTPCookieStorage.m
//
//  Created by Sasmito Adibowo on 02-07-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//  http://basilsalad.com
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


// this is ARC code.
#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif

#import "BSHTTPCookieStorage.h"


@interface BSHTTPCookieStorage()

/*
 Cookie storage is stored in the order of
 domain -> path -> name
 
 This one stores cookies that are subdomain specific
 */
@property (nonatomic,strong,readonly) NSMutableDictionary* subdomainCookies;

/*
 Cookie storage is stored in the order of
 domain -> path -> name
 
 This one stores cookies global for a domain.
 */
@property (nonatomic,strong,readonly) NSMutableDictionary* domainGlobalCookies;


@end


@implementation BSHTTPCookieStorage

@synthesize subdomainCookies = _subdomainCookies;
@synthesize domainGlobalCookies = _domainGlobalCookies;

- (void)setCookie:(NSHTTPCookie *)aCookie
{
  // only domain names are case insensitive
  NSString* domain = [[aCookie domain] lowercaseString];
  NSString* path = [aCookie path];
  NSString* name = [aCookie name];
  
  NSMutableDictionary* domainStorage = [domain hasPrefix:@"."] ? self.domainGlobalCookies : self.subdomainCookies;
  
  NSMutableDictionary* pathStorage = [domainStorage objectForKey:domain];
  if (!pathStorage) {
    pathStorage = [NSMutableDictionary new];
    [domainStorage setObject:pathStorage forKey:domain];
  }
  NSMutableDictionary* nameStorage = [pathStorage objectForKey:path];
  if (!nameStorage) {
    nameStorage = [NSMutableDictionary new];
    [pathStorage setObject:nameStorage forKey:path];
  }
  
  [nameStorage setObject:aCookie forKey:name];
}


- (NSArray *)cookiesForURL:(NSURL *)theURL
{
  NSMutableArray* resultCookies = [NSMutableArray new];
  NSString* cookiePath = [theURL path];
  
  void (^cookieFinder)(NSString*,NSDictionary*) = ^(NSString* domainKey,NSDictionary* domainStorage) {
    NSMutableDictionary* pathStorage = [domainStorage objectForKey:domainKey];
    if (!pathStorage) {
      return;
    }
    for (NSString* path in pathStorage) {
      if ([path isEqualToString:@"/"] || [cookiePath hasPrefix:path]) {
        NSMutableDictionary* nameStorage = [pathStorage objectForKey:path];
        [resultCookies addObjectsFromArray:[nameStorage allValues]];
      }
    }
  };
  
  NSString* cookieDomain = [[theURL host] lowercaseString];
  
  cookieFinder(cookieDomain,self.subdomainCookies);
  
  // delete the fist subdomain
  NSRange range = [cookieDomain rangeOfString:@"."];
  if (range.location != NSNotFound) {
    NSString* globalDomain = [cookieDomain substringFromIndex:range.location];
    cookieFinder(globalDomain,self.domainGlobalCookies);
  }
  
  return resultCookies;
}


-(void) loadCookies:(id<NSFastEnumeration>) cookies
{
  for (NSHTTPCookie* cookie in cookies) {
    [self setCookie:cookie];
  }
}


-(void) handleCookiesInRequest:(NSMutableURLRequest*) request
{
  NSURL* url = request.URL;
  NSArray* cookies = [self cookiesForURL:url];
  NSDictionary* headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
  
  NSUInteger count = [headers count];
  __unsafe_unretained id keys[count], values[count];
  [headers getObjects:values andKeys:keys];
  
  for (NSUInteger i=0;i<count;i++) {
    [request setValue:values[i] forHTTPHeaderField:keys[i]];
  }
}


-(void) handleCookiesInResponse:(NSHTTPURLResponse*) response
{
  NSURL* url = response.URL;
  NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:url];
  [self loadCookies:cookies];
}


#pragma mark Property Access

-(NSMutableDictionary *)subdomainCookies
{
  if (!_subdomainCookies) {
    _subdomainCookies = [NSMutableDictionary new];
  }
  return _subdomainCookies;
}


-(NSMutableDictionary *)domainGlobalCookies
{
  if (!_domainGlobalCookies) {
    _domainGlobalCookies = [NSMutableDictionary new];
  }
  return _domainGlobalCookies;
}


-(void)reset
{
  [self.subdomainCookies removeAllObjects];
  [self.domainGlobalCookies removeAllObjects];
}


#pragma mark NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [self init]) {
    _domainGlobalCookies = [aDecoder decodeObjectForKey:@"domainGlobalCookies"];
    _subdomainCookies = [aDecoder decodeObjectForKey:@"subdomainCookies"];
  }
  return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
  if (_domainGlobalCookies) {
    [aCoder encodeObject:_domainGlobalCookies forKey:@"domainGlobalCookies"];
  }
  
  if (_subdomainCookies) {
    [aCoder encodeObject:_subdomainCookies forKey:@"subdomainCookies"];
  }
}


#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone
{
  BSHTTPCookieStorage* copy = [[[self class] allocWithZone:zone] init];
  if (copy) {
    copy->_subdomainCookies = [self.subdomainCookies mutableCopy];
    copy->_domainGlobalCookies = [self.domainGlobalCookies mutableCopy];
  }
  return copy;
}

@end

// ---

@implementation NSHTTPCookie (BSHTTPCookieStorage)

-(id)initWithCoder:(NSCoder *)aDecoder
{
  NSDictionary* cookieProperties = [aDecoder decodeObjectForKey:@"cookieProperties"];
  if (![cookieProperties isKindOfClass:[NSDictionary class]]) {
    // cookies are always immutable, so there's no point to return anything here if its properties cannot be found.
    return nil;
  }
  self = [self initWithProperties:cookieProperties];
  return self;
}


-(void) encodeWithCoder:(NSCoder *)aCoder
{
  NSDictionary* cookieProperties = self.properties;
  if (cookieProperties) {
    [aCoder encodeObject:cookieProperties forKey:@"cookieProperties"];
  }
}

@end

// ---
