//
//  STSEndlessGameScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSEndlessGameScene.h"
#import "STSPauseScene.h"
#import "STSGameOverScene.h"
#import "STSOptionsScene.h"
#import "STSHero.h"
#import "STSVillain.h"
#import "STSShield.h"
#import "ObjectAL.h"
#import "ALAdView.h"
#import "GAIDictionaryBuilder.h"

#define HERO_BEEP @"dying_sound.mp3"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface STSEndlessGameScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) STSHero *hero;

@property CGSize sizeOfVillainAndShield;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastIncreaseToScoreTimeInterval;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) NSTimer *longGestureTimer;

@property (nonatomic) UILongPressGestureRecognizer *longPress;
@end

@implementation STSEndlessGameScene

@synthesize level;

#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.backgroundColor = [SKColor colorWithRed:245.0 / 255.0
                                               green:144.0 / 255.0
                                                blue:68.0 / 255.0
                                               alpha:1.0];

        [self addScore];
        [super addPauseButton];
        [super addRestartButton];
        [[OALSimpleAudio sharedInstance] preloadEffect:HERO_BEEP];

        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"EndlessGame"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];

        // Duration to start song
        SKAction *waitBeforeGameBegins = [SKAction waitForDuration:0.3];
        [self runAction:waitBeforeGameBegins completion:^{
            [self createEndlessGameSceneContents];
        }];
    }
    return self;
}



#pragma mark - Scene Contents
- (void)createEndlessGameSceneContents {
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:[self frame]];
    self.physicsWorld.contactDelegate = self;

    self.level = 1;

    [self addHero];
    [self createNInitialShield:20];

    // Adjust this value to lengthen wait for hero to come in
    SKAction *waitForFadeToFinish = [SKAction waitForDuration:0.2];
    [self runAction:waitForFadeToFinish completion:^{
        SKAction *makeVillain = [SKAction sequence:@[
                                                     [SKAction performSelector:@selector(addVillain)
                                                                      onTarget:self],
                                                     [SKAction waitForDuration:2.0 withRange:0.5]]];

        SKAction *makeExtraShields = [SKAction sequence:@[
                               [SKAction performSelector:@selector(addShield) onTarget:self],
                               [SKAction waitForDuration:1.0 withRange:0.5]]];
        
        [self runAction:[SKAction repeatActionForever:makeVillain] withKey:@"makeVillains"];
        [self runAction:[SKAction repeatActionForever:makeExtraShields] withKey:@"makeShields"];
    }];
}


// The logic behind here is to add a dead hero image on top of the hero with 0.0 alpha
// This means that when the game is over, the positioning of the white dot on the dead/normal
// hero is the same and will show a simultaneous fade in/out animation
- (void)addHero{
    [super addHero];
    [self createHeroLevelsColors];
}

// Change this as more hero level colors get added
- (void)createHeroLevelsColors {
    for (int i = 2; i <= 8; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Hero_%d.png", i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        SKSpriteNode *nextLevelHero = [SKSpriteNode spriteNodeWithTexture:texture];
        nextLevelHero.position = CGPointMake(0.0, 0.0);
        nextLevelHero.alpha = 0.0;
        nextLevelHero.name = [NSString stringWithFormat:@"%d", i];
        [self.hero addChild:nextLevelHero];
    }
}


- (void)addVillain {
    [super addVillain];
}

- (void)addShield {
    [super addShield];
}

- (void)createNInitialShield:(uint)nShields {
    [super createNInitialShield:nShields];
}

- (void)addScore {
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
    self.scoreLabel.name = @"score";
    self.scoreLabel.fontSize = 60.0;
    self.scoreLabel.fontColor = [SKColor colorWithRed:211.0 / 255.0 
                                                green:92.0 / 255.0 
                                                 blue:41.0 / 255.0 
                                                alpha:1.0];
    if (IS_WIDESCREEN) {
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMidY(self.frame) + 200.0);
    } else {
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), 
                                               CGRectGetMidY(self.frame) + 160.0);
    }

    [self addChild:self.scoreLabel];
}

#pragma mark - Rotation Handler
- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    [super handleLongPress:recognizer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    if (!self.paused){
        if ([node.name isEqualToString:@"pause"]) {
            self.paused = YES;
            STSPauseScene *pauseScene = [[STSPauseScene alloc] initWithSize:self.size];
            SKTransition *swipeLeft = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                              duration:0.3];
            pauseScene.previousScene = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
            [self.view presentScene:pauseScene transition:swipeLeft];
        }
        else if ([node.name isEqualToString:@"restart"]) {
            STSEndlessGameScene *newEndlessGameScene = [[STSEndlessGameScene alloc] 
                                                        initWithSize:self.frame.size];
            [self.view presentScene:newEndlessGameScene];
        }
        else {
            [self.hero rotate:location];
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
        self.paused = NO;
    }
}


#pragma mark - Contact Logic

/* Contact logic will be cleaned up accordingly, way too many else ifs */
-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKNode *first, *second;
    first = contact.bodyA.node;
    second = contact.bodyB.node;

    // The villain sounds should come and should continue to play as villains hit shields
    // If the shield hits another shield, (usually to recover the hero's shield, use the 2nd contact
    // If a villain hits a shield, get rid of that shield (the shield MUST be attached to the hero)
    if ([first isKindOfClass:[STSHero class]] && [second isKindOfClass:[STSVillain class]]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [[OALSimpleAudio sharedInstance] stopBg];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundToggle"]) {
            [[OALSimpleAudio sharedInstance] playEffect:HERO_BEEP];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
            [second removeFromParent];
            [self gameOver];
        } else {
            [second removeFromParent];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
            [self gameOver];
        }
    } else if ([first isKindOfClass:[STSShield class]] &&
               [second isKindOfClass:[STSShield class]]) {
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

    } else if ([first isKindOfClass:[STSShield class]]
               && [second isKindOfClass:[STSVillain class]]) {
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

        // Increment score for each villain blocked
        self.score++;
        if (self.score % 10 == 0) {
            [self increaseSpeed:self.level];
            [self increaseSoundPitch];
        }

    } else if (first.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [first removeFromParent];
    } else if (second.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [second removeFromParent];
    }
}

#pragma mark - Game Difficulty Logic

/* Adjust speed based off levels, increments of 10 */
- (void)increaseSpeed:(NSInteger)withSpeed{
    [self removeActionForKey:@"makeVillains"];
    [self removeActionForKey:@"makeShields"];

    CGFloat newVillainSpeed, newShieldSpeed;
    // Set here for smooth adjustments
    if (withSpeed == 1) {
        newVillainSpeed = 1.8;
        newShieldSpeed = 1.0;
    } else if (withSpeed <= 7){
        newVillainSpeed = 1.8 - withSpeed * 0.2;
        newShieldSpeed = 1.0 - withSpeed * 0.1;
    } else {
        newVillainSpeed = 0.3;
        newVillainSpeed = 0.3;
    }
    if (self.level % 2 == 0) {
        [self bonus];
    }

    // This incremented here because of the image being named as hero_2 instead of hero_1 so we need
    // to know this information beforehand. Level starts at 1.
    self.level++;
    if (self.level <= 8) {
        SKSpriteNode *newHero = (SKSpriteNode *)[self.hero childNodeWithName:
                                             [NSString stringWithFormat:@"%ld", (long)self.level]];
        newHero.zRotation = newHero.zRotation;
        SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.5];
        [newHero runAction:fadeIn];
    }

    //SKSpriteNode

    SKAction *makeVillains = [SKAction sequence:@[
                                                  [SKAction performSelector:@selector(addVillain)
                                                                   onTarget:self],
                                                  [SKAction waitForDuration:newVillainSpeed 
                                                                  withRange:0.2]]];

    SKAction *makeExtraShields = [SKAction sequence:@[
                                                      [SKAction performSelector:@selector(addShield) 
                                                                       onTarget:self],
                                                      [SKAction waitForDuration:newShieldSpeed 
                                                                      withRange:0.2]]];
    [self runAction:[SKAction repeatActionForever:makeVillains] withKey:@"makeVillains"];
    [self runAction:[SKAction repeatActionForever:makeExtraShields] withKey:@"makeShields"];
}

- (void)bonus {
    SKAction *makeExtraShields = [SKAction sequence:@[
                                                     [SKAction performSelector:@selector(addShield) 
                                                                      onTarget:self],
                                                     [SKAction waitForDuration:0.0 withRange:0.0]]];
    [self runAction:[SKAction repeatAction:makeExtraShields count:30]];
}
- (void)increaseSoundPitch {
    for (int i = 2; i <= 5; i++) {
        if (self.level == i) {
            NSString *backgroundMusic = [NSString stringWithFormat:@"background_%d.mp3", i];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
                [[OALSimpleAudio sharedInstance] preloadBg:backgroundMusic];
            } else {
                [[OALSimpleAudio sharedInstance] playBg:backgroundMusic loop:YES];
            }
        }
    }
}

#pragma mark - Game Over Animation

/* Animation to make all villains and shields from appearing and make heroes current shields fly out
   Hero then bounces up, then quickly down in order to transition into GameOverScene */
- (void)gameOver {
    [super gameOver];
    CGPoint middle = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    if (highScore == 0 || highScore < self.score) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:@"highScore"];
    }
    STSGameOverScene *newGameOverScene = [[STSGameOverScene alloc] initWithSize:self.size];

    newGameOverScene.userData = [NSMutableDictionary dictionary];
    NSString *scoreString = [NSString stringWithFormat:@"%d", self.score];
    [newGameOverScene.userData setObject:scoreString forKey:@"scoreString"];

    // Create gray background for smoother transition
    SKColor *endGameSceneBackgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                                           green:241.0 / 255.0
                                                            blue:238.0 / 255.0
                                                           alpha:1.0];
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:endGameSceneBackgroundColor 
                                                              size:self.size];
    background.position = middle;
    background.alpha = 0.0;
    [self addChild:background];
    SKAction *fadeBackgroundIn = [SKAction fadeAlphaTo:1.0 duration:1.0];
    SKAction *backgroundWait = [SKAction waitForDuration:1.4];
    SKAction *backgroundSequence = [SKAction sequence:@[backgroundWait, fadeBackgroundIn]];
    [background runAction:backgroundSequence completion:^{
        [self.view removeGestureRecognizer:self.longPress];
        SKTransition *fade = [SKTransition fadeWithColor:endGameSceneBackgroundColor duration:0.5];
        [self.view presentScene:newGameOverScene transition:fade];
    }];
}

#pragma mark - Frame Updates
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
}

@end
