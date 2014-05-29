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

@implementation STSWelcomeScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addChild:[self addGameTitleNode]];
        [self addChild:[self addPlayButton]];
    }
    return self;
}

- (SKSpriteNode *)addGameTitleNode{
    SKTexture *gameTitleTexture = [SKTexture textureWithImageNamed:@"ShieldUp_Title_Image.png"];
    SKSpriteNode *gameTitleNode = [SKSpriteNode spriteNodeWithTexture:gameTitleTexture];
    gameTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-80);
    
    return gameTitleNode;
}

- (SKSpriteNode *)addPlayButton{
    SKTexture *playButtonTexture = [SKTexture textureWithImageNamed:@"Play_Button.png"];
    SKSpriteNode *playButtonNode = [SKSpriteNode spriteNodeWithTexture:playButtonTexture];
    playButtonNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame)	);
    playButtonNode.name = @"playButton";
    return playButtonNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    if ([node.name isEqualToString:@"playButton"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.5];
        SKScene *newEndlessGameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
        [self.view presentScene:newEndlessGameScene transition:reveal];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
