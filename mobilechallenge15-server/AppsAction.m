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

#import "AppsAction.h"
#import "AppsService.h"
#import "JSONResponse.h"

@implementation AppsAction

+ (AppsAction *)actionWithPath:(NSString *)path {
    if (![path isEqualToString:@"/apps"])
        return nil;
    
    return [[[self class] alloc] init];
}

- (NSObject<HTTPResponse> *)execute {
    
    NSMutableArray *responseArray = [NSMutableArray array];
    
    for (NSRunningApplication *app in [AppsService appsList]) {
        [responseArray addObject:
         @{
           @"name" : app.localizedName,
           @"pid" : @(app.processIdentifier),
           @"alive" : @([app.launchDate timeIntervalSinceNow]),
           @"active" : @([app isActive])
           }];
            
    }
    
    return [[JSONResponse alloc] initWithJSONObject:responseArray];
}


@end
