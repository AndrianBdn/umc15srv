//
//  AppsService.h
//  mobilechallenge15-server
//
//  Created by Andrian Budantsov on 11/27/15.
//  Copyright © 2015 Andrian Budantsov. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface AppsService : NSObject

+ (NSArray *)appsList;
+ (NSRunningApplication *)appWithPid:(pid_t)pid;

@end
