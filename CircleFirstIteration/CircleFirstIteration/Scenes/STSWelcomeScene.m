//
//  STSWelcome.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSWelcomeScene.h"
#import "STSEndlessGameScene.h"

@interface STSWelcomeScene ()

@property BOOL contentCreated;
@property (nonatomic, strong) SKSpriteNode *playNode;
@end

static inline float distFormula(CGPoint a, CGPoint b){
    return sqrtf(powf(a.x-b.x, 2.0) + powf(a.y-b.y,2));
}

@implementation STSWelcomeScene

- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createContents];
        self.contentCreated = YES;
    }
}

- (void)createContents {
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.playNode = [self addPlayNode];
    [self addChild:self.playNode];
    [self addChild:[self addGameTitleNode]];
}

- (SKSpriteNode *)addPlayNode {
    SKTexture *playTexture = [SKTexture textureWithImageNamed:@"Play.png"];
    SKSpriteNode *playNode = [[SKSpriteNode alloc] initWithTexture:playTexture];
    playNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    return playNode;
}

- (SKSpriteNode *)addGameTitleNode {
    SKTexture *gameTitleTexture = [SKTexture textureWithImageNamed:@"landing_page_game_title.png"];
    SKSpriteNode *gameTitleNode = [[SKSpriteNode alloc] initWithTexture:gameTitleTexture];
    gameTitleNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height-60);
    
    return gameTitleNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if (distFormula(touchLocation,self.playNode.position)<self.playNode.size.width/2) {
        STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
        [self.view presentScene:gameScene];
    }
}

@end
