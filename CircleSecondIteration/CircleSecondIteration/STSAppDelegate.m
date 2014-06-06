//
//  STSAppDelegate.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "ALSdk.h"
#import "ALInterstitialAd.h"
#import "STSAppDelegate.h"
#import "STSEndlessGameScene.h"
#import "STSPauseScene.h"
#import "ObjectAL/ObjectAL.h"

@implementation STSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Crashlytics startWithAPIKey:@"15cff1e39186231362a287dbc7407a93ea1631de"];
    [ALSdk initializeSdk];
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
    view.scene.paused = YES;
    if ([view.scene isKindOfClass:[STSEndlessGameScene class]]) {
        STSPauseScene *pause = [[STSPauseScene alloc] initWithSize:view.scene.size];
        pause.previousScene = (STSEndlessGameScene *)view.scene;
        [view presentScene:pause];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = NO;
    view.scene.paused = YES;
    if ([OALSimpleAudio sharedInstance].interrupted) {
        [OALSimpleAudio sharedInstance].manuallySuspended = YES;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"musicToggle"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundToggle"];
    }
        NSLog(@"%d", [OALSimpleAudio sharedInstance].interrupted);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
