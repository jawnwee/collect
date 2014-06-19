//
//  STSTimedGameScene.m
//  Ozone!
//
//  Created by John Lee on 6/7/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSTimedGameScene.h"
#import "STSTimedGameOverScene.h"
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

@interface STSTimedGameScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) STSHero *hero;

@property CGSize sizeOfVillainAndShield;
@property (nonatomic) NSTimer *timer;
@property int seconds;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) NSTimer *longGestureTimer;

@property (nonatomic) UILongPressGestureRecognizer *longPress;

@end

@implementation STSTimedGameScene


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
        [tracker set:kGAIScreenName value:@"TimedGame"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];

        // Duration to start song
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self 
                                                    selector:@selector(timerController) 
                                                    userInfo:nil repeats:YES];
        SKAction *waitBeforeGameBegins = [SKAction waitForDuration:0.3];
        [self runAction:waitBeforeGameBegins completion:^{
            [self createTimedGameSceneContents];
        }];
    }
    return self;
}



#pragma mark - Scene Contents
- (void)createTimedGameSceneContents {
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:[self frame]];
    self.physicsWorld.contactDelegate = self;

    [self addHero];
    [self createNInitialShield:20];

    // Adjust this value to lengthen wait for hero to come in
    SKAction *waitForFadeToFinish = [SKAction waitForDuration:0.2];
    [self runAction:waitForFadeToFinish completion:^{
        SKAction *makeVillain = [SKAction sequence:@[
                                                     [SKAction performSelector:@selector(addVillain)
                                                                      onTarget:self],
                                                     [SKAction waitForDuration:0.9 withRange:0.5]]];

        SKAction *makeExtraShields = 
            [SKAction sequence:@[[SKAction performSelector:@selector(addShield) onTarget:self],
                                                [SKAction waitForDuration:0.45 withRange:0.5]]];

        [self runAction:[SKAction repeatActionForever:makeVillain] withKey:@"makeVillains"];
        [self runAction:[SKAction repeatActionForever:makeExtraShields] withKey:@"makeShields"];
    }];
}


// The logic behind here is to add a dead hero image on top of the hero with 0.0 alpha
// This means that when the game is over, the positioning of the white dot on the dead/normal
// hero is the same and will show a simultaneous fade in/out animation
- (void)addHero{
    [super addHero];
}


- (void)addVillain{
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
    int minutes = 0;
    int seconds = 0;
    self.scoreLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    self.scoreLabel.name = @"score";
    self.scoreLabel.fontSize = 50.0;
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
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Contact Logic

/* Contact logic will be cleaned up accordingly, way too many else ifs */
-(void)didBeginContact:(SKPhysicsContact *)contact{
    [super didBeginContact:contact];
}



#pragma mark - Game Over Animation

/* Animation to make all villains and shields from appearing and make heroes current shields fly out
 Hero then bounces up, then quickly down in order to transition into GameOverScene */
- (void)gameOver {
    [super gameOver];
    CGPoint middle = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"timedHighScore"];

    if (highScore == 0 || highScore < self.seconds) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.seconds forKey:@"timedHighScore"];
    }
    STSTimedGameOverScene *newGameOverScene = [[STSTimedGameOverScene alloc] initWithSize:self.size];

    newGameOverScene.userData = [NSMutableDictionary dictionary];
    NSString *scoreString = [self getTimeStr:self.seconds];
    [newGameOverScene.userData setObject:scoreString forKey:@"timedScore"];

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
        [self removeAllActions];
        [self removeAllChildren];
        [self.timer invalidate];
        self.timer = nil;


        SKTransition *fade = [SKTransition fadeWithColor:endGameSceneBackgroundColor duration:0.5];
        [self.view presentScene:newGameOverScene transition:fade];
    }];
}

#pragma mark - Timing for Score

- (void)timerController {
    self.seconds++;
    self.scoreLabel.text = [self getTimeStr:self.seconds];
}

- (NSString*)getTimeStr:(int)secondsElapsed {
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)resumeTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                selector:@selector(timerController)
                                                userInfo:nil repeats:YES];
}

- (void)pauseTimer {
    [self.timer invalidate];
}

#pragma mark - Frame Updates

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}


@end
