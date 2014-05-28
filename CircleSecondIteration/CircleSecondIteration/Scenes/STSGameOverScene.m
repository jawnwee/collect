//
//  STSGameOverScene.m
//  CircleSecondIteration
//
//  Created by Matthew Chiang on 5/28/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSGameOverScene.h"
#import "STSEndlessGameScene.h"
#import "STSWelcomeScene.h"

@interface STSGameOverScene ()

@property (nonatomic) SKLabelNode *retry;
@property (nonatomic) SKLabelNode *menu;

@end

static inline float distFormula(CGPoint a, CGPoint b) {
    return sqrtf(powf(a.x - b.x, 2.0) + powf(a.y - b.y, 2.0));
}

@implementation STSGameOverScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addChild:[self addGameOverNode]];
        [self addRetryNode];
        [self addMenuNode];
        [self addChild:self.retry];
        [self addChild:self.menu];
    }
    return self;
}

- (SKLabelNode *)addGameOverNode {
    SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    gameOver.text = @"Game Over";
    gameOver.fontSize = 36.0;
    gameOver.fontColor = [SKColor blackColor];
    gameOver.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 150);

    return gameOver;
}

- (void)addRetryNode {
    self.retry = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.retry.text = @"Retry";
    self.retry.fontSize = 30.0;
    self.retry.fontColor = [SKColor blackColor];
    self.retry.position = CGPointMake(CGRectGetMidX(self.frame) / 2, 
                                      CGRectGetMidY(self.frame) / 2);

}

- (void)addMenuNode {
    self.menu = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.menu.text = @"Menu";
    self.menu.fontSize = 30.0;
    self.menu.fontColor = [SKColor blackColor];
    self.menu.position = CGPointMake(CGRectGetMidX(self.frame) * 1.5, 
                                     CGRectGetMidY(self.frame) / 2);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Initialize touch and location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    // Scene transitions
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                  duration:0.5];

    // Touching the retry node presents game scene last played
    if (location.x >= self.retry.frame.origin.x &&
        location.x <= self.retry.frame.origin.x + self.retry.frame.size.width &&
        location.y >= self.retry.frame.origin.y &&
        location.y <= self.retry.frame.origin.y + self.retry.frame.size.height) {

        STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
        [self.view presentScene:gameScene transition:reveal];
    }

    // Touching the menu node presents the welcome scene
    if (location.x >= self.menu.frame.origin.x &&
        location.x <= self.menu.frame.origin.x + self.menu.frame.size.width &&
        location.y >= self.menu.frame.origin.y &&
        location.y <= self.retry.frame.origin.y + self.retry.frame.size.height) {

        STSWelcomeScene *welcomeScene = [[STSWelcomeScene alloc] initWithSize:self.size];
        [self.view presentScene:welcomeScene transition:reveal];
    }
}

@end
