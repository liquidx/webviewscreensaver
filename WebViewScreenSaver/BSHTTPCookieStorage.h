//
//  BSHTTPCookieStorage.h
//
//      Created by Sasmito Adibowo on 02-07-12.
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

#import <Foundation/Foundation.h>


/**
 Stores cookies.
 */
@interface BSHTTPCookieStorage : NSObject<NSCoding,NSCopying>

- (NSArray *)cookiesForURL:(NSURL *)theURL;

- (void)setCookie:(NSHTTPCookie *)aCookie;

/**
 Removes all stored cookies from this storage
 */

-(void) reset;

-(void) loadCookies:(id<NSFastEnumeration>) cookies;
-(void) handleCookiesInRequest:(NSMutableURLRequest*) request;
-(void) handleCookiesInResponse:(NSHTTPURLResponse*) response;


@end


// ---


@interface NSHTTPCookie (BSHTTPCookieStorage) <NSCoding>

@end

// ---
