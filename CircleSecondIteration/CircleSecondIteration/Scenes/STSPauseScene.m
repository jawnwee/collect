//
//  STSPauseScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 6/2/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSPauseScene.h"
#import "STSOptionsScene.h"
#import "STSWelcomeScene.h"
#import "STSEndlessGameScene.h"
#import "ObjectAL.h"

@interface STSPauseScene ()

@property (nonatomic) SKSpriteNode *resume;
@property (nonatomic) SKSpriteNode *settings;
@property (nonatomic) SKSpriteNode *menu;

@end

@implementation STSPauseScene

@synthesize previousScene;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        self.backgroundColor = [SKColor colorWithRed:240.0 / 255.0 
                                               green:241.0 / 255.0  
                                                blue:238.0 / 255.0 
                                               alpha:1.0];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self createSceneContents];
    }
    return self;
}

- (void)createSceneContents {
    [self addResumeNode];
        [self addSettingsNode];
    [self addMenuNode];
}

#pragma mark - Sprite Nodes
- (void)addResumeNode {
    SKSpriteNode *resume = [SKSpriteNode spriteNodeWithImageNamed:@"Resume.png"];
    resume.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 50);
    resume.name = @"ResumeButton";
    [self addChild:resume];
}

- (void)addSettingsNode {
    SKSpriteNode *settings = [SKSpriteNode spriteNodeWithImageNamed:@"Settings.png"];
    settings.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    settings.name = @"SettingsButton";
    [self addChild:settings];
}

- (void)addMenuNode {
    SKSpriteNode *menu = [SKSpriteNode spriteNodeWithImageNamed:@"Menu.png"];
    menu.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 50);
    menu.name = @"MenuButton";
    [self addChild:menu];
}

# pragma mark - Handle touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Initialize touch and location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    // Scene transitions
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight
                                                  duration:0.3];


    // Touching the retry node presents game scene last played
    if ([node.name isEqualToString:@"ResumeButton"]) {
        self.previousScene.paused = NO;
        [self.view presentScene:self.previousScene transition:reveal];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    } else if ([node.name isEqualToString:@"SettingsButton"]) {
        STSOptionsScene *options = [[STSOptionsScene alloc] initWithSize:self.size];
        options.previousScene = self;
        SKTransition *optionTransition = [SKTransition pushWithDirection:SKTransitionDirectionLeft 
                                                                duration:0.3];
        [self.view presentScene:options transition:optionTransition];
    } else if ([node.name isEqualToString:@"MenuButton"]) {
        STSWelcomeScene *welcome = [[STSWelcomeScene alloc] initWithSize:self.size];
        [self.previousScene removeAllActions];
        [self.previousScene removeAllChildren];
        self.previousScene = nil;
        [[OALSimpleAudio sharedInstance] stopBg];
        [self.view presentScene:welcome transition:reveal];
    }
}

@end
