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

@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *retryLabel;
@property (nonatomic) SKLabelNode *menuLabel;
@property (nonatomic) SKSpriteNode *retrySymbol;
@property (nonatomic) SKSpriteNode *menuSymbol;
@property (nonatomic) NSString *scoreString;

@end


@implementation STSGameOverScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self addChild:[self addGameOverNode]];
        [self addRetryLabel];
        [self addMenuLabel];
        [self addRetrySymbol];
        [self addMenuSymbol];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    self.scoreString = [self.userData valueForKey:@"scoreString"];
    [self addScoreLabel];

}

# pragma mark - Add nodes

- (SKLabelNode *)addGameOverNode {
    SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    gameOver.text = @"Game Over";
    gameOver.fontSize = 36.0;
    gameOver.fontColor = [SKColor blackColor];
    gameOver.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 150);

    return gameOver;
}

- (void)addScoreLabel {
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.scoreLabel.text = self.scoreString;
    self.scoreLabel.fontSize = 72.0;
    self.scoreLabel.fontColor = [SKColor blackColor];
    self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 35);

    [self addChild:self.scoreLabel];
}

- (void)addRetryLabel {
    self.retryLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.retryLabel.text = @"Retry";
    self.retryLabel.name = @"retryLabel";
    self.retryLabel.fontSize = 30.0;
    self.retryLabel.fontColor = [SKColor blackColor];
    self.retryLabel.position = CGPointMake(CGRectGetMidX(self.frame) / 2,
                                      CGRectGetMidY(self.frame) / 1.5);
    [self addChild:self.retryLabel];
}

- (void)addMenuLabel {
    self.menuLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.menuLabel.text = @"Menu";
    self.menuLabel.name = @"menuLabel";
    self.menuLabel.fontSize = 30.0;
    self.menuLabel.fontColor = [SKColor blackColor];
    self.menuLabel.position = CGPointMake(CGRectGetMidX(self.frame) * 1.5,
                                     CGRectGetMidY(self.frame) / 1.5);
    [self addChild:self.menuLabel];
}

- (void)addRetrySymbol {
    SKTexture *retryTexture = [SKTexture textureWithImageNamed:@"RetrySymbol@2x.png"];
    self.retrySymbol = [[SKSpriteNode alloc] initWithTexture:retryTexture];
    self.retrySymbol.name = @"retrySymbol";

    // Add the retry symbol below the retry label
    int y = self.retryLabel.frame.size.height;
    self.retrySymbol.position = CGPointMake(self.retryLabel.position.x, 
                                            self.retryLabel.position.y - 2 * y + 10);
    [self addChild:self.retrySymbol];
}

- (void)addMenuSymbol {
    SKTexture *menuTexture = [SKTexture textureWithImageNamed:@"MenuSymbol@2x.png"];
    self.menuSymbol = [[SKSpriteNode alloc] initWithTexture:menuTexture];
    self.menuSymbol.name = @"menuSymbol";

    // Add the menu symbol below the retry symbol
    int y = self.menuLabel.frame.size.height;
    self.menuSymbol.position = CGPointMake(self.menuLabel.position.x,
                                            self.menuLabel.position.y - 2 * y);
    [self addChild:self.menuSymbol];
}

# pragma mark - Handle touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Initialize touch and location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    // Scene transitions
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                  duration:0.5];


    // Touching the retry node presents game scene last played
    if ([node.name isEqualToString:@"retryLabel"] || [node.name isEqualToString:@"retrySymbol"]) {
        STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
        [self.view presentScene:gameScene transition:reveal];
    }

    // Touching the menu node presents the welcome scene
    if ([node.name isEqualToString:@"menuLabel"] || [node.name isEqualToString:@"menuSymbol"]) {
        STSWelcomeScene *welcomeScene = [[STSWelcomeScene alloc] initWithSize:self.size];
        [self.view presentScene:welcomeScene transition:reveal];
    }
}

@end
