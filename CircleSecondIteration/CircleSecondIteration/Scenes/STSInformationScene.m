//
//  STSInformationScene.m
//  CircleSecondIteration
//
//  Created by Yujun Cho on 6/1/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSInformationScene.h"
#import "STSWelcomeScene.h"

@interface STSInformationScene ()

@property (nonatomic) SKSpriteNode *logo;
@property (nonatomic) SKLabelNode *exitLabel;

@end

@implementation STSInformationScene

# pragma mark - Initialize scene contents

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addLogo];
        [self addExitLabel];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {

}

#pragma mark - Add Buttons

- (void)addLogo {
    
    self.logo = [SKSpriteNode spriteNodeWithImageNamed:@"OzoneOddLookLogo.png"];
    self.logo.position = CGPointMake(CGRectGetMidX(self.frame),
                                                 CGRectGetMidY(self.frame));
    self.logo.name = @"logo";
    
    [self addChild:self.logo];
}

- (void)addExitLabel {
    self.exitLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.exitLabel.text = @"X";
    self.exitLabel.fontColor = [SKColor blackColor];
    self.exitLabel.fontSize = 36.0;
    self.exitLabel.position = CGPointMake(self.frame.size.width - 20,
                                          self.frame.size.height - 60);
    self.exitLabel.name = @"exitLabel";
    
    [self addChild:self.exitLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    // Clicking the exitLabel
    if ([node.name isEqualToString:@"exitLabel"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.3];
        STSWelcomeScene *newWelcomeScene = [[STSWelcomeScene alloc] initWithSize:self.frame.size];
        [self.view presentScene:newWelcomeScene transition:reveal];
    }
}

@end
