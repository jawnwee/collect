//
//  STSMyScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSWelcomeScene.h"
#import "STSEndlessGameScene.h"

@implementation STSWelcomeScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addChild:[self addGameTitleNode]];
    }
    return self;
}

-(SKLabelNode *)addGameTitleNode{
    SKLabelNode *welcome = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    welcome.text = @"Tap to Begin";
    welcome.fontSize = 36.0;
    welcome.fontColor = [SKColor blackColor];
    welcome.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    return welcome;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                  duration:0.5];
    SKScene *newEndlessGameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
    [self.view presentScene:newEndlessGameScene transition:reveal];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
