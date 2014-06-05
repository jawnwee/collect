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
#import "ObjectAL.h"

#define BACKGROUND_MUSIC_FILE @"background.mp3"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface STSGameOverScene ()

@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *highScoreLabel;
@property (nonatomic) NSString *scoreString;
@property (nonatomic) NSString *highScoreString;

@property (nonatomic) SKSpriteNode *deadOzone;

@end


@implementation STSGameOverScene

#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        self.backgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                               green:241.0 / 255.0
                                                blue:238.0 / 255.0
                                               alpha:1.0];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self createSceneContents];

        [[OALSimpleAudio sharedInstance] preloadBg:BACKGROUND_MUSIC_FILE];
        [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_FILE loop:YES];
        [OALSimpleAudio sharedInstance].paused = YES;
    }
    return self;
}

- (void)createSceneContents {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"GameOverSymbols"];
    SKTexture *deadOzoneTexture = [atlas textureNamed:@"Dead_Ozone.png"];
    self.deadOzone = [SKSpriteNode spriteNodeWithTexture:deadOzoneTexture];
    self.deadOzone.position = CGPointMake(self.scene.size.width / 2.0, -1000.0);

    SKAction *bounceUp, *adjustBounce;
    if (IS_WIDESCREEN) {
        bounceUp = [SKAction moveByX:0.0 y:1000.0 duration:0.8];
        adjustBounce = [SKAction moveByX:0.0 y:-40.0 duration:0.5];
    } else {
        bounceUp = [SKAction moveByX:0.0 y:950.0 duration:0.8];
        adjustBounce = [SKAction moveByX:0.0 y:-40.0 duration:0.5];
    }
    [self addChild:self.deadOzone];
    SKAction *sequence = [SKAction sequence:@[bounceUp, adjustBounce]];
    [self.deadOzone runAction: sequence];
    [self addDividers];
    [self addGameOverNode];
    [self addRetrySymbol];
    [self addMenuSymbol];
}

- (void)didMoveToView:(SKView *)view {
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    self.highScoreString = [NSString stringWithFormat:@"%ld", (long)highScore];
    self.scoreString = [self.userData valueForKey:@"scoreString"];

    [self addScoreLabel];
    [self addHighScoreLabel];
}

# pragma mark - Add nodes

- (void)addGameOverNode {
    SKSpriteNode *gameOverTitle = [SKSpriteNode spriteNodeWithImageNamed:@"GameOverTitle.png"];
    if (IS_WIDESCREEN) {
        gameOverTitle.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame) + 230.0);
    } else {
        gameOverTitle.position = CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame) + 190.0);
    }
    [self addChild:gameOverTitle];
}

- (void)addScoreLabel {
    SKSpriteNode *lastButton = [SKSpriteNode spriteNodeWithImageNamed:@"Last_Score.png"];

    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.scoreLabel.text = self.scoreString;
    self.scoreLabel.fontSize = 66.0;
    self.scoreLabel.fontColor = [SKColor colorWithRed:98.0 / 255.0 
                                                green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];

    if (IS_WIDESCREEN) {
        lastButton.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                          CGRectGetMidY(self.frame) + 180.0);
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                               CGRectGetMidY(self.frame) + 180.0);
    } else {
        lastButton.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                          CGRectGetMidY(self.frame) + 140.0);
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                               CGRectGetMidY(self.frame) + 70.0);
    }

    [self addChild:lastButton];
    [self addChild:self.scoreLabel];
}

- (void)addHighScoreLabel {
    SKSpriteNode *bestButton = [SKSpriteNode spriteNodeWithImageNamed:@"Best_Score.png"];

    self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.highScoreLabel.text = self.highScoreString;
    self.highScoreLabel.fontSize = 66.0;
    self.highScoreLabel.fontColor = [SKColor colorWithRed:98.0 / 255.0 
                                                    green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];

    if (IS_WIDESCREEN) {
        bestButton.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) + 180.0);
        self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                               CGRectGetMidY(self.frame) + 180.0);
    } else {
        bestButton.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) + 140.0);
        self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                               CGRectGetMidY(self.frame) + 70.0);
    }

    [self addChild:bestButton];
    [self addChild:self.highScoreLabel];
}

- (void)addRetrySymbol {
    SKTexture *retryTexture = [SKTexture textureWithImageNamed:@"RetrySymbol.png"];
    SKSpriteNode *retrySymbol = [[SKSpriteNode alloc] initWithTexture:retryTexture];
    retrySymbol.name = @"retrySymbol";
    if (IS_WIDESCREEN) {
        retrySymbol.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                           CGRectGetMidY(self.frame) - 10.0);
    } else {
        retrySymbol.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                           CGRectGetMidY(self.frame) - 30.0);
    }
    [self addChild:retrySymbol];
}

- (void)addMenuSymbol {
    SKTexture *menuTexture = [SKTexture textureWithImageNamed:@"MenuSymbol@2x.png"];
    SKSpriteNode *menuSymbol = [[SKSpriteNode alloc] initWithTexture:menuTexture];
    menuSymbol.name = @"menuSymbol";
    if (IS_WIDESCREEN) {
        menuSymbol.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) - 10.0);
    } else {
        menuSymbol.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) - 30.0);
    }

    [self addChild:menuSymbol];
}

- (void)addDividers {
    CGFloat screenMiddleX = CGRectGetMidX(self.frame);
    CGFloat screenMiddleY = CGRectGetMidY(self.frame);


    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"GameOverSymbols"];
    SKTexture *longDividerTexture = [atlas textureNamed:@"Long_Bar.png"];
    SKTexture *middleLongerDivider = [atlas textureNamed:@"Middle_Longer_Bar.png"];
    SKTexture *middleShorterDivider = [atlas textureNamed:@"Middle_Shorter_bar.png"];

    SKSpriteNode *top = [SKSpriteNode spriteNodeWithTexture:longDividerTexture];
    SKSpriteNode *firstMiddle = [SKSpriteNode spriteNodeWithTexture:middleLongerDivider];
    SKSpriteNode *secondMiddle = [SKSpriteNode spriteNodeWithTexture:middleShorterDivider];
    SKSpriteNode *bottom = [SKSpriteNode spriteNodeWithTexture:longDividerTexture];
    if (IS_WIDESCREEN) {
        top.position = CGPointMake(screenMiddleX, screenMiddleY + 195.0);
        firstMiddle.position = CGPointMake(screenMiddleX, screenMiddleY + 125.0);
        bottom.position = CGPointMake(screenMiddleX, screenMiddleY + 53.0);
        secondMiddle.position =  CGPointMake(screenMiddleX, screenMiddleY - 5.0);
    } else {
        top.position = CGPointMake(screenMiddleX, screenMiddleY + 155.0);
        firstMiddle.position = CGPointMake(screenMiddleX, screenMiddleY + 85.0);
        bottom.position = CGPointMake(screenMiddleX, screenMiddleY + 23.0);
        secondMiddle.position =  CGPointMake(screenMiddleX, screenMiddleY - 40.0);
    }
    [self addChild:top];
    [self addChild:firstMiddle];
    [self addChild:bottom];
    [self addChild:secondMiddle];

}

# pragma mark - Handle touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Initialize touch and location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    SKColor *orangeBackground = [SKColor colorWithRed:245.0 / 255.0 green:144.0 / 255.0
                                                 blue:68.0 / 255.0 alpha:1.0];

    // Scene transitions
    SKTransition *reveal = [SKTransition fadeWithColor:orangeBackground duration:0.5];

    // Touching the retry node presents game scene last played
    if ([node.name isEqualToString:@"retryLabel"] || [node.name isEqualToString:@"retrySymbol"]) {
        STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
        [OALSimpleAudio sharedInstance].paused = NO;
        [self.view presentScene:gameScene transition:reveal];
    } else if ([node.name isEqualToString:@"menuLabel"] || [node.name isEqualToString:@"menuSymbol"]) {
        STSWelcomeScene *welcomeScene = [[STSWelcomeScene alloc] initWithSize:self.size];
        [OALSimpleAudio sharedInstance].paused = NO;
        [self.view presentScene:welcomeScene transition:reveal];
    }

}

@end
