//
//  STSViewController.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSViewController.h"
#import "STSWelcomeScene.h"
#import "STSHeroRotationScene.h"
#import "ObjectAL.h"
#import "ALAdView.h"

#define BACKGROUND_MUSIC_FILE @"background.mp3"

@interface STSViewController ()

@property (strong, nonatomic) ALAdView *banner;

@end

@implementation STSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // self.screenName = @"Game Loaded";
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    // skView.showsFPS = YES;
    // skView.showsNodeCount = YES;
    // skView.showsPhysics = YES;

    // (Mandatory) Add the ad into current view
    [self.view addSubview:self.banner];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) 
                                                 name:@"hideAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) 
                                                 name:@"showAd" object:nil];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
        [OALSimpleAudio sharedInstance].allowIpod = NO;
        [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_FILE loop:YES];
    } else {
        [OALSimpleAudio sharedInstance].allowIpod = YES;
        [OALSimpleAudio sharedInstance].useHardwareIfAvailable = NO;
    }
    // Use NSUserDefaults to launch tutorial only once
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"tutorialFinished"]) {
        STSHeroRotationScene *heroRotationScene = [[STSHeroRotationScene alloc] initWithSize:skView.bounds.size];
        heroRotationScene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:heroRotationScene];
    } else {
        STSWelcomeScene *scene = [[STSWelcomeScene alloc] initWithSize:skView.bounds.size];
        [skView presentScene:scene];
    }
}

- (void)handleNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"hideAd"]) {
        [self hidesBanner];
    } else if ([notification.name isEqualToString:@"showAd"]) {
        [self showBanner];
    }
}

-(void)hidesBanner {
    // [self.banner removeFromSuperview];
}


-(void)showBanner {
//    self.banner = [[ALAdView alloc] initWithSize:[ALAdSize sizeBanner]];
//    CGFloat y = self.view.frame.size.height - 50;
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    self.banner.frame = CGRectMake(0, y, width, 50);
//
//    [self.view addSubview:self.banner];
//    double rand = arc4random() % 100;
//    if (rand <= 66) {
//        [self.banner loadNextAd];
//    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
