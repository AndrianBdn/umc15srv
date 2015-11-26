//
//  main.m
//  mobilechallenge15-server
//
//  Created by Mobile Challange Guy on 11/25/15.
//  Copyright © 2015 Mobile Challange Guy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTTPServer.h>
#import <HTTPConnection.h>
#import <HTTPDataResponse.h>
#import <HTTPLogging.h>
#import <HTTPErrorResponse.h>
#import <AppKit/AppKit.h>


static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;
typedef struct { NSInteger pid; CGSize size; } pid_and_size_t;

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

@interface Connection : HTTPConnection
@end
@implementation Connection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSString *filePath = [self filePathForURI:path];
    NSString *documentRoot = [config documentRoot];
    
    if (![filePath hasPrefix:documentRoot])  {
        return nil;
    }
    
    NSString *relativePath = [filePath substringFromIndex:[documentRoot length]];
    
    DataHeaderResponse *currentResponse = nil;

    
    if ([relativePath isEqualToString:@"/index.html"])
    {
        HTTPLogVerbose(@"%@[%p]: Serving up dynamic content", THIS_FILE, self);
        
        NSString *computerName = [[NSHost currentHost] localizedName];
        NSString *currentTime = [[NSDate date] description];
        
        
        NSString *response = [NSString stringWithFormat:@"%@ %@", computerName, currentTime];
        currentResponse = [[DataHeaderResponse alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];

        
        currentResponse.httpHeaders = @{@"Content-type" : @"text/plain"};
        return currentResponse;
      
    }
    else if ([relativePath isEqualToString:@"/apps"]) {

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
    else if ([relativePath hasPrefix:@"/icon/"]) {

        NSString *pidAndSizeString = [relativePath substringFromIndex:6];
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
                currentResponse = [[DataHeaderResponse alloc] initWithData:[@"unable to encode icon to PNG #fail" dataUsingEncoding:NSUTF8StringEncoding]];
                currentResponse.status = 500;
            }

        }
        else {
            currentResponse = [[DataHeaderResponse alloc] initWithData:[@"unable to find app #fail" dataUsingEncoding:NSUTF8StringEncoding]];
            currentResponse.status = 404;
        }

        
    }
    else if ([relativePath hasPrefix:@"/activate/"]) {
        NSString *pid = [relativePath substringFromIndex:[@"/activate/" length]];
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


int main(int argc, const char * argv[]) {
    @autoreleasepool {

        NSLog(@"Hello, World!");
        
        UInt16 serverPort = 9091;
        
        HTTPServer *httpServer = [[HTTPServer alloc] init];
        [httpServer setConnectionClass:[Connection class]];
        [httpServer setPort:serverPort];
        [httpServer setDocumentRoot:NSTemporaryDirectory()];
        NSError *error = nil;
        [httpServer start:&error];
        NSCAssert(error == nil, @"error starting HTTP server");
        
        [[NSRunLoop currentRunLoop] run];

        
        
    }
    return 0;
}
