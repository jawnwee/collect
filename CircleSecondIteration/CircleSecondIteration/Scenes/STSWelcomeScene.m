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
@import AVFoundation;

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

        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background"
                                                            withExtension:@"mp3"];
        self.welcomeBackgroundMusicPlayer = [[AVAudioPlayer alloc]
                                                    initWithContentsOfURL:backgroundMusicURL
                                                    error:&error];
        self.welcomeBackgroundMusicPlayer.numberOfLoops = -1;
        [self.welcomeBackgroundMusicPlayer prepareToPlay];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [self.welcomeBackgroundMusicPlayer play];
        }

        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addGameTitleNode];
        [self addHero];
        [self addCompanyInfo];
        [self addPlayButton];
        [self addOptionMenu];
        [self addOzoneLayer];

    }
    return self;
}


- (void)didMoveToView:(SKView *)view {
    // Play music depending on toggle
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
        [self.welcomeBackgroundMusicPlayer stop];
    } else {
        [self.welcomeBackgroundMusicPlayer play];
    }
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
    playButtonNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) + 50.0);
    playButtonNode.name = @"playButton";
    [self addChild:playButtonNode];
}

- (void)addOptionMenu {
    SKTexture *optionButtonTexture = [SKTexture textureWithImageNamed:@"Options_Button.png"];
    SKSpriteNode *optionButtonNode = [SKSpriteNode spriteNodeWithTexture:optionButtonTexture];
    optionButtonNode.position = CGPointMake(CGRectGetMidX(self.frame) + 100.0,
                                          CGRectGetMidY(self.frame) + 15.0);
    optionButtonNode.name = @"OptionMenu";
    [self addChild:optionButtonNode];
}

- (void)addCompanyInfo {
    SKTexture *companyInfoTexture = [SKTexture textureWithImageNamed:@"Company_Info.png"];
    SKSpriteNode *companyInfoNode = [SKSpriteNode spriteNodeWithTexture:companyInfoTexture];
    companyInfoNode.position = CGPointMake(CGRectGetMidX(self.frame) - 100.0,
                                            CGRectGetMidY(self.frame) + 15.0);
    companyInfoNode.name = @"CompanyInfo";
    [self addChild:companyInfoNode];
}

- (void)addOzoneLayer {
    SKTexture *ozoneLayerTexture = [SKTexture textureWithImageNamed:@"Ozone_Layer.png"];
    SKSpriteNode *ozoneLayerNode = [SKSpriteNode spriteNodeWithTexture:ozoneLayerTexture];
    ozoneLayerNode.position = CGPointMake(CGRectGetMidX(self.frame), -40.0);
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
        [self transitionToEndlessGameScene];
    }

    // Set up option menu
    if ([node.name isEqualToString:@"OptionMenu"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.3];
        STSOptionsScene *newOptionsScene = [[STSOptionsScene alloc] initWithSize:self.size];
        newOptionsScene.previousScene = self.scene;
        [self.view presentScene:newOptionsScene transition:reveal];
    }

    // TODO add company info scene
    if ([node.name isEqualToString:@"CompanyInfo"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight
                                                      duration:0.3];
        STSInformationScene *newInformationScene = [[STSInformationScene alloc] initWithSize:self.size];
        newInformationScene.previousScene = self.scene;
        [self.view presentScene:newInformationScene transition:reveal];
    }
}

- (void)transitionToEndlessGameScene {

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

    // Holy fuck this is messy
    for (NSInteger i = 0; i < self.children.count; i++) {
        SKNode *node = [self.children objectAtIndex:i];
        if (i + 1 == self.children.count) {
            if ([node.name isEqualToString:@"CompanyInfo"] ||
                [node.name isEqualToString:@"playButton"] ||
                [node.name isEqualToString:@"OptionMenu"] ||
                [node.name isEqualToString:@"OzoneLayer"]) {
                [node runAction:lowerBounceSequence completion:^{
                    STSEndlessGameScene *newEndlessGameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
                    newEndlessGameScene.previousScene = self;
                    [self.view presentScene:newEndlessGameScene];
                }];
            } else {
                [node runAction:upperBounceSequence completion:^{
                    STSEndlessGameScene *newEndlessGameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
                    newEndlessGameScene.previousScene = self;
                    [self.view presentScene:newEndlessGameScene];
                }];
            }
        } else {
            if ([node.name isEqualToString:@"CompanyInfo"] ||
                       [node.name isEqualToString:@"playButton"] || 
                       [node.name isEqualToString:@"OptionMenu"] ||
                       [node.name isEqualToString:@"OzoneLayer"]) {
                [node runAction:lowerBounceSequence];
            } else {
                [node runAction:upperBounceSequence];
            }
        }
    }
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
