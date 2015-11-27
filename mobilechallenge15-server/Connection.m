// MobileChallange15-Server
// Copyright (C) 2015 Andrian Budantsov
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#import <AppKit/AppKit.h>
#import <HTTPDataResponse.h>
#import <HTTPLogging.h>
#import <HTTPMessage.h>
#import <HTTPErrorResponse.h>
#import "Connection.h"
#import "CodeStringReponse.h"
#import "ImageResponse.h"
#import "JSONResponse.h"

#import "RootAction.h"
#import "AppsAction.h"
#import "IconAction.h"
#import "NotFoundAction.h"
#import "ActivateAction.h"

NSString *HTTPBearerToken;


@implementation Connection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    return [method isEqualToString:@"GET"] || [method isEqualToString:@"POST"];
}

+ (BOOL)authorizeRequest:(HTTPMessage *)request {
    // lowercasing everything to make things easier
    
    NSString *authHeader = [[request headerField:@"authorization"] lowercaseString];
    NSString *authGold = [[NSString stringWithFormat:@"Bearer %@", HTTPBearerToken] lowercaseString];
    
    if (!authHeader)
        return NO;
    
    // vulnerable to timing attacks
    return [authHeader isEqualToString:authGold];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    
    if (![[self class] authorizeRequest:request]) {
        return [[CodeStringReponse alloc] initWithString:@"wrong bearer token" code:403];
    }
    
    BOOL get = [method isEqualToString:@"GET"];
    BOOL post = [method isEqualToString:@"POST"];
    
    NSObject <HTTPResponse> *response = nil;
    
    (get && (response = [[RootAction actionWithPath:path] execute])) ||
    (get && (response = [[AppsAction actionWithPath:path] execute])) ||
    (get && (response = [[IconAction actionWithPath:path] execute])) ||
    (get && (response = [[NotFoundAction actionWithPath:path] execute])) ||
    (post && (response = [[ActivateAction actionWithPath:path] execute]));
    
    return response;
}




@end
