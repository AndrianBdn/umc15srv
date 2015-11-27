//
//  AppsService.m
//  mobilechallenge15-server
//
//  Created by Andrian Budantsov on 11/27/15.
//  Copyright © 2015 Andrian Budantsov. All rights reserved.
//

#import "AppsService.h"

@implementation AppsService

+ (BOOL)isNormalApp:(NSRunningApplication *)app {
    return app.activationPolicy == NSApplicationActivationPolicyRegular;
}

+ (NSArray *)appsList {
    return [[[NSWorkspace sharedWorkspace] runningApplications] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [self isNormalApp:(NSRunningApplication *)evaluatedObject];
    }]];
}


+ (NSRunningApplication *)appWithPid:(pid_t)pid {
    
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    
    if (!app || ![self isNormalApp:app])
        return nil;
    
    return app;
}


@end
