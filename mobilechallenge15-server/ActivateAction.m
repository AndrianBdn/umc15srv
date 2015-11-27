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

#import "ActivateAction.h"
#import "AppsService.h"
#import <AppKit/AppKit.h>
#import "JSONResponse.h"
#import "CodeStringReponse.h"

@implementation ActivateAction {
    int pid;
}

+ (id)actionWithPath:(NSString *)path {
    
    ActivateAction *action = [[[self class] alloc] init];
    
    NSScanner *scanner = [NSScanner scannerWithString:path];
    if (![scanner scanString:@"/apps/" intoString:nil])
        return nil;
    
    if (![scanner scanInt:&(action->pid)])
        return nil;
    
    if (![scanner scanString:@"/activate" intoString:nil])
        return nil;
    
    if (![scanner isAtEnd])
        return nil;
    
    return action;
}

- (NSObject<HTTPResponse> *)execute {
    
    NSRunningApplication *app = [AppsService appWithPid:pid];
    
    [app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
    
    if (!app)
        return [[CodeStringReponse alloc] initWithString:@"app not found" code:404];
    
    return [[JSONResponse alloc] initWithJSONObject:@{@"success" : @"true"}];
}


@end
