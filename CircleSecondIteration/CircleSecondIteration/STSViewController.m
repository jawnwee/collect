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

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    // skView.showsPhysics = YES;

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
