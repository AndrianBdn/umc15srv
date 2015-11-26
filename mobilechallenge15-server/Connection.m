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



typedef struct { NSInteger pid; CGSize size; } pid_and_size_t;
NSString *HTTPBearerToken;


@interface DataHeaderResponse : HTTPDataResponse
@property(nonatomic, strong) NSDictionary *httpHeaders;
@property(nonatomic) NSInteger status;
@end
@implementation DataHeaderResponse
- (instancetype)initWithData:(NSData *)aData
{
    self = [super initWithData:aData];
    if (self) {
        self.status = 200;
    }
    return self;
}
@end


@implementation Connection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    DataHeaderResponse *currentResponse = nil;
    
    
    if ([path isEqualToString:@"/"])
    {
        NSString *computerName = [[NSHost currentHost] localizedName];
        NSString *currentTime = [[NSDate date] description];
        
        
        NSString *response = [NSString stringWithFormat:@"%@ %@", computerName, currentTime];
        currentResponse = [[DataHeaderResponse alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        currentResponse.httpHeaders = @{@"Content-type" : @"text/plain"};
        return currentResponse;
        
    }
    else if ([path isEqualToString:@"/apps"]) {
        
        NSMutableArray *responseArray = [NSMutableArray array];
        
        for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
            if (app.activationPolicy == NSApplicationActivationPolicyRegular) {
                [responseArray addObject:
                 @{
                   @"name" : app.localizedName,
                   @"pid" : @(app.processIdentifier),
                   @"alive" : @([app.launchDate timeIntervalSinceNow])
                   }];
                
            }
        }
        
        NSError *error = nil;
        NSData *jsonResponse = [NSJSONSerialization dataWithJSONObject:responseArray options:NSJSONWritingPrettyPrinted error:&error];
        currentResponse = [[DataHeaderResponse alloc] initWithData:jsonResponse];
        NSCAssert(error == nil, @"error encoding json");
        
        
    }
    else if ([path hasPrefix:@"/icon/"]) {
        
        NSString *pidAndSizeString = [path substringFromIndex:6];
        pid_and_size_t pidAndSize = [[self class] parsePidAndSize:pidAndSizeString];
        
        NSImage *iconImage = [[self class] iconImageWithPid:pidAndSize.pid];
        
        NSData *pngIconData = nil;
        if (iconImage) {
            pngIconData = [[self class] dataWithPNGEncodedImage:iconImage size:pidAndSize.size];
            
            if (pngIconData) {
                currentResponse = [[DataHeaderResponse alloc] initWithData:pngIconData];
                currentResponse.httpHeaders = @{ @"content-type" : @"image/png" };
            }
            else {
                return [[CodeStringReponse alloc] initWithString:@"unable to encode icon to PNG #fail" code:500];
            }
            
        }
        else {
            return [[CodeStringReponse alloc] initWithString:@"unable to find app" code:500];
        }
        
        
    }
    else if ([path hasPrefix:@"/activate/"]) {
        NSString *pid = [path substringFromIndex:[@"/activate/" length]];
        NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier: (pid_t)[pid integerValue]];
        
        if (app) {
            [app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
            currentResponse = [[DataHeaderResponse alloc] initWithData:[NSData data]];
            currentResponse.status = 201;
            
        }
        else {
            currentResponse = [[DataHeaderResponse alloc] initWithData:[@"unable to find app #fail" dataUsingEncoding:NSUTF8StringEncoding]];
            currentResponse.status = 404;
        }
        
        
    }
    else {
        currentResponse = [[DataHeaderResponse alloc] initWithData:[@"bad request" dataUsingEncoding:NSUTF8StringEncoding]];
        currentResponse.status = 400;
    }
    
    
    return currentResponse;
}

+ (pid_and_size_t)parsePidAndSize:(NSString *)source {
    pid_and_size_t retval;
    retval.pid = 0;
    retval.size = CGSizeMake(256, 256);
    
    NSArray *parts = [source componentsSeparatedByString:@"/"];
    if ([parts count] > 0)
        retval.pid = [[parts objectAtIndex:0] integerValue];
    
    if ([parts count] > 1) {
        NSInteger sqSide = [[parts objectAtIndex:1] integerValue];
        if (sqSide > 0 && sqSide <= 1024) {
            retval.size = CGSizeMake(sqSide, sqSide);
        }
    }
    
    return retval;
}

+ (NSImage *)iconImageWithPid:(NSInteger)pid {
    if (pid == 0)
        return nil;
    
    NSImage *image = nil;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (app.processIdentifier == pid) {
            image = app.icon;
        }
    }
    
    return image;
}

+ (NSData *)dataWithPNGEncodedImage:(NSImage *)image size:(CGSize)size {
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:NULL
                                pixelsWide:size.width
                                pixelsHigh:size.height
                                bitsPerSample:8
                                samplesPerPixel:4
                                hasAlpha:YES
                                isPlanar:NO
                                colorSpaceName:NSCalibratedRGBColorSpace
                                bytesPerRow:0
                                bitsPerPixel:0];
    [newRep setSize:size];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:newRep]];
    [image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:@{}];
    return pngData;
}

@end
