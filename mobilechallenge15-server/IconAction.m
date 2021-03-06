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

#import "IconAction.h"
#import "AppsService.h"
#import <AppKit/AppKit.h>
#import "ImageResponse.h"
#import "CodeStringReponse.h"

@implementation IconAction {
    int pid;
    NSInteger iconSidePx;
}

+ (id)actionWithPath:(NSString *)path {

    IconAction *action = [[[self class] alloc] init];
    
    NSScanner *scanner = [NSScanner scannerWithString:path];
    if (![scanner scanString:@"/apps/" intoString:nil])
        return nil;
    
    if (![scanner scanInt:&(action->pid)])
        return nil;

    if (![scanner scanString:@"/icon/" intoString:nil])
        return nil;

    if (![scanner scanInteger:&(action->iconSidePx)])
        return nil;
    
    if (action->iconSidePx > 1024)
        action->iconSidePx = 1024;

    if (![scanner scanString:@".png" intoString:nil])
        return nil;

    return action;
}


- (NSObject<HTTPResponse> *)execute {

    NSImage *iconImage = [[self class] iconImageWithPid:pid];
    
    if (iconImage) {
        return [[ImageResponse alloc] initWithImage:iconImage size:CGSizeMake(iconSidePx, iconSidePx)];
    }
    else {
        return [[CodeStringReponse alloc] initWithString:@"unable to find app" code:500];
    }
    
}

+ (NSImage *)iconImageWithPid:(int)pid {
    
    return [[AppsService appWithPid:pid] icon];
}


@end
