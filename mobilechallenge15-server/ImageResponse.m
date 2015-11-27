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
#import "ImageResponse.h"

@implementation ImageResponse

- (id)initWithImage:(NSImage *)image size:(CGSize)size {
    NSData *imageData = [[self class] dataWithPNGEncodedImage:image size:size];
    
    if (!imageData)
        return nil;
    
    return [super initWithData:imageData];
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

- (NSDictionary *)httpHeaders {
    return  @{@"Content-type" : @"image/png"};
}


@end
