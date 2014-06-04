//
//  STSTransitionToEndlessGameScene.m
//  Ozone!
//
//  Created by Yujun Cho on 6/2/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSTransitionToEndlessGameScene.h"
#import "STSEndlessGameScene.h"

@implementation STSTransitionToEndlessGameScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.backgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                               green:241.0 / 255.0
                                                blue:238.0 / 255.0
                                               alpha:1.0];
        [self addText];
        [self playGame];
    }
    
    return self;
}

#pragma mark - Creating Sprites
- (void)addText{
    //initialize first line of message
    SKLabelNode *firstMessage = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    firstMessage.fontColor = [SKColor blackColor];
    firstMessage.fontSize = 16.0;
    firstMessage.text = @"Good Job!";
    firstMessage.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 70);
    
    //initialize second line of message
    SKLabelNode *secondMessage = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    secondMessage.fontColor = [SKColor blackColor];
    secondMessage.fontSize = 16.0;
    secondMessage.text = @"Get ready to play.";
    secondMessage.position = CGPointMake(firstMessage.position.x, firstMessage.position.y - 20);
    
    //initialize third line of message
    SKLabelNode *thirdMessage = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    thirdMessage.fontColor = [SKColor blackColor];
    thirdMessage.fontSize = 16.0;
    thirdMessage.text = @"Be careful out there!";
    thirdMessage.position = CGPointMake(firstMessage.position.x, firstMessage.position.y - 40);
    
    //add the message to the scene
    [self addChild:firstMessage];
    [self addChild:secondMessage];
    [self addChild:thirdMessage];
}

- (void)playGame{
    //initialize playGame button. for now pretend the message says "Start"
    SKSpriteNode *playGame = [SKSpriteNode spriteNodeWithImageNamed:@"Resume.png"];
    playGame.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    playGame.name = @"playGame";
    [self addChild:playGame];
}

#pragma mark - transition scenes
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //logic to change scenes once button is touched
    if ([node.name isEqualToString:@"playGame"]) {
        STSEndlessGameScene *newEndlessGameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
        [self.view presentScene:newEndlessGameScene];
    }
}
@end
