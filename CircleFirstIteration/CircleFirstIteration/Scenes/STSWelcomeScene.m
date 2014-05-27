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

@end

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
    [self addChild:[self addWelcomeNode]];

}

- (SKLabelNode *)addWelcomeNode {
    SKLabelNode *welcome = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    welcome.text = @"Tap To Begin";
    welcome.fontSize = 36.0;
    welcome.fontColor = [SKColor blackColor];
    welcome.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    return welcome;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
    [self.view presentScene:gameScene];
}
@end
