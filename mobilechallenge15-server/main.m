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


#import <Foundation/Foundation.h>
#import <HTTPServer.h>
#import "Connection.h"

void SetupAuthorization(void);
void CopySerialNumber(CFStringRef *serialNumber);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        UInt16 serverPort = 9091;

        SetupAuthorization();
        
        HTTPServer *httpServer = [[HTTPServer alloc] init];
        [httpServer setConnectionClass:[Connection class]];
        [httpServer setPort:serverPort];
        [httpServer setDocumentRoot:NSTemporaryDirectory()];
        [httpServer setType:@"_mch15._tcp."];
        
        NSError *error = nil;
        [httpServer start:&error];
        NSCAssert(error == nil, @"error starting HTTP server");

        if (!error) {
            printf("The server is running on *:%d\n", serverPort);
            printf("Use Bearer token %s for Authorization header\n", [HTTPBearerToken cStringUsingEncoding:NSUTF8StringEncoding]);
            printf("Press Ctrl-C to quit\n");
        }
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

void SetupAuthorization(void) {
    
    CFStringRef serial = NULL;
    CopySerialNumber(&serial);
    if (serial) {
        NSString *tmp = (__bridge NSString *)serial;
        NSInteger index = [tmp length] - 6;
        index = index < 0 ? 0 : index;
        HTTPBearerToken = [tmp substringFromIndex:index];
        CFRelease(serial);
    }
    
    if (!HTTPBearerToken)
        HTTPBearerToken = [NSString stringWithFormat:@"%d", rand()];

}


void CopySerialNumber(CFStringRef *serialNumber)
{
    if (serialNumber != NULL) {
        *serialNumber = NULL;
        
        io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                     IOServiceMatching("IOPlatformExpertDevice"));
        
        if (platformExpert) {
            CFTypeRef serialNumberAsCFString =
            IORegistryEntryCreateCFProperty(platformExpert,
                                            CFSTR(kIOPlatformSerialNumberKey),
                                            kCFAllocatorDefault, 0);
            if (serialNumberAsCFString) {
                *serialNumber = serialNumberAsCFString;
            }
            
            IOObjectRelease(platformExpert);
        }
    }
}

