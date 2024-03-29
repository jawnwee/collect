//
//  STSMyScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSWelcomeScene.h"
#import "STSEndlessGameScene.h"
#import "STSGameOverScene.h"
#import "STSOptionsScene.h"
#import "STSInformationScene.h"
#import "ObjectAL.h"
#import "GAIDictionaryBuilder.h"
#import "STSTimedGameScene.h"

#define BACKGROUND_MUSIC_LEVEL_1 @"background.mp3"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface STSWelcomeScene ()

@property SKSpriteNode *ozone;

@end

@implementation STSWelcomeScene

#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        self.backgroundColor = [SKColor colorWithRed:245.0 / 255.0 green:144.0 / 255.0 
                                                blue:68.0 / 255.0 alpha:1.0];
        
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addGameTitleNode];
        [self addHero];
        [self addTimedMode];
        [self addPlayButton];
        [self addOptionMenu];
        [self addOzoneLayer];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"] && 
            ![OALSimpleAudio sharedInstance].bgPlaying) {

        [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_LEVEL_1 loop:YES];
    }

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WelcomeScene"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma - Adding Sprite Nodes
- (void)addGameTitleNode {
    SKTexture *gameTitleTexture = [SKTexture textureWithImageNamed:@"Ozone_Title.png"];
    SKSpriteNode *gameTitleNode = [SKSpriteNode spriteNodeWithTexture:gameTitleTexture];
    gameTitleNode.position = CGPointMake(CGRectGetMidX(self.frame)+ 65.0 ,
                                         self.frame.size.height - 100.0);
    [self addChild: gameTitleNode];
}

- (void)addHero {
    SKTexture *ozoneTexture = [SKTexture textureWithImageNamed:@"Ozone_Title_Hero.png"];
    self.ozone = [SKSpriteNode spriteNodeWithTexture:ozoneTexture];
    self.ozone.position = CGPointMake(-1.0, 0.4);
    SKTexture *ozoneShadowTexture =[SKTexture textureWithImageNamed:@"Ozone_Title_Hero_Shadow.png"];
    SKSpriteNode *ozoneShadow = [SKSpriteNode spriteNodeWithTexture:ozoneShadowTexture];

    ozoneShadow.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0 ,
                                      self.frame.size.height - 100.0);
    [self addChild:ozoneShadow];
    [ozoneShadow addChild: self.ozone];

    SKAction *waitDuration = [SKAction waitForDuration:2.0];
    [self.ozone runAction:waitDuration];
    SKAction *rotation = [SKAction rotateByAngle: M_PI * 2.0 duration:4.0];
    SKAction *wait = [SKAction waitForDuration:1.0];
    SKAction *rotationBack = [SKAction rotateByAngle: -M_PI * 2.0 duration:4.0];
    [self.ozone runAction:[SKAction repeatActionForever:
                      [SKAction sequence:@[rotation, wait, rotationBack, wait]]]];
    }

- (void)addPlayButton {
    SKTexture *playButtonTexture = [SKTexture textureWithImageNamed:@"Play_Button.png"];
    SKSpriteNode *playButtonNode = [SKSpriteNode spriteNodeWithTexture:playButtonTexture];
    if (IS_WIDESCREEN) {
        playButtonNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                              CGRectGetMidY(self.frame) + 50.0);
    } else {
        playButtonNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                              CGRectGetMidY(self.frame) + 30.0);
    }
    playButtonNode.name = @"playButton";
    [self addChild:playButtonNode];
}

- (void)addOptionMenu {
    SKTexture *optionButtonTexture = [SKTexture textureWithImageNamed:@"Options_Button.png"];
    SKSpriteNode *optionButtonNode = [SKSpriteNode spriteNodeWithTexture:optionButtonTexture];
    if (IS_WIDESCREEN) {
        optionButtonNode.position = CGPointMake(CGRectGetMidX(self.frame) + 100.0,
                                              CGRectGetMidY(self.frame) + 15.0);
    } else {
        optionButtonNode.position = CGPointMake(CGRectGetMidX(self.frame) + 100.0,
                                                CGRectGetMidY(self.frame) - 5.0);
    }
    optionButtonNode.name = @"OptionMenu";
    [self addChild:optionButtonNode];
}

- (void)addTimedMode {
    SKTexture *timedTexture = [SKTexture textureWithImageNamed:@"Timed_Button.png"];
    SKSpriteNode *timedMode = [SKSpriteNode spriteNodeWithTexture:timedTexture];
    if (IS_WIDESCREEN) {
        timedMode.position = CGPointMake(CGRectGetMidX(self.frame) - 100.0,
                                                CGRectGetMidY(self.frame) + 15.0);
    } else {
        timedMode.position = CGPointMake(CGRectGetMidX(self.frame) - 100.0,
                                               CGRectGetMidY(self.frame) - 5.0);

    }
    timedMode.name = @"TimedButton";
    [self addChild:timedMode];
}

- (void)addOzoneLayer {
    SKTexture *ozoneLayerTexture = [SKTexture textureWithImageNamed:@"Ozone_Layer.png"];
    SKSpriteNode *ozoneLayerNode = [SKSpriteNode spriteNodeWithTexture:ozoneLayerTexture];
    if (IS_WIDESCREEN) {
        ozoneLayerNode.position = CGPointMake(CGRectGetMidX(self.frame), -40.0);
    } else {
        ozoneLayerNode.position = CGPointMake(CGRectGetMidX(self.frame), -80.0);
    }
    ozoneLayerNode.name = @"OzoneLayer";
    [self addChild:ozoneLayerNode];
}

#pragma mark - Scene Transitions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    if ([node.name isEqualToString:@"playButton"]) {
        // Google Analytics
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

        [tracker set:kGAIScreenName value:@"WelcomeScene"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                              action:@"touch"
                                                               label:@"EndlessGameButton"
                                                               value:nil] build]];
        STSEndlessGameScene *newEndlessGame = [[STSEndlessGameScene alloc]initWithSize:self.size];
        [self transitionToGameScene:newEndlessGame];
    }

    // Set up option menu
    if ([node.name isEqualToString:@"OptionMenu"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.3];
        STSOptionsScene *newOptionsScene = [[STSOptionsScene alloc] initWithSize:self.size];
        newOptionsScene.previousScene = self;
        [self.view presentScene:newOptionsScene transition:reveal];
    }

    // Setup timed game mode
    if ([node.name isEqualToString:@"TimedButton"]) {

        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

        [tracker set:kGAIScreenName value:@"WelcomeScene"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                              action:@"touch"
                                                               label:@"TimedGameButton"
                                                               value:nil] build]];

        STSTimedGameScene *newEndlessGame = [[STSTimedGameScene alloc]initWithSize:self.size];
        [self transitionToGameScene:newEndlessGame];

    }
}

- (void)transitionToGameScene:(SKScene *)scene {

    SKAction *waitShort = [SKAction waitForDuration:0.1];
    SKAction *removeFromParent = [SKAction removeFromParent];

    // Bouncing motion for the lower half sprites
    SKAction *lowerBounceUp = [SKAction moveByX:0.0 y:20.0 duration:0.5];
    SKAction *lowerBounceDown = [SKAction moveByX:0.0 y:-500.0 duration:0.3];
    SKAction *lowerBounceSequence =[SKAction sequence:@[lowerBounceUp, waitShort,
                                                       lowerBounceDown, removeFromParent]];

    // Bounce motion for the upper half sprites
    SKAction *upperBounceDown = [SKAction moveByX:0.0 y:-20.0 duration:0.5];
    SKAction *upperBounceUp = [SKAction moveByX:0.0 y:500.0 duration:0.3];
    SKAction *upperBounceSequence =[SKAction sequence:@[upperBounceDown, waitShort,
                                                     upperBounceUp, removeFromParent]];

    // Animation to make squeeze and pull out for all children nodes
    for (NSInteger i = 0; i < self.children.count; i++) {
        SKNode *node = [self.children objectAtIndex:i];
        if ([node.name isEqualToString:@"TimedButton"] ||
                   [node.name isEqualToString:@"playButton"] || 
                   [node.name isEqualToString:@"OptionMenu"]) {
            [node runAction:lowerBounceSequence];
        } else if (![node.name isEqualToString:@"OzoneLayer"]){
            [node runAction:upperBounceSequence];
        }
    }
    SKNode *lastNode = [self childNodeWithName:@"OzoneLayer"];
    [lastNode runAction:lowerBounceSequence completion:^{
        [self.view presentScene:scene];
    }];
}

#pragma mark - Pause Logic
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // If the scene is currently paused, change it to unpaused
    if (self.paused) {
        self.paused = !self.paused;
    }
}

@end
