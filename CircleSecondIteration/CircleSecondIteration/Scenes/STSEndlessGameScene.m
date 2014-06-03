//
//  STSEndlessGameScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSEndlessGameScene.h"
#import "STSPauseScene.h"
#import "STSAppDelegate.h"
#import "STSGameOverScene.h"
#import "STSOptionsScene.h"
#import "STSHero.h"
#import "STSVillain.h"
#import "STSShield.h"

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
        [self addPauseButton];
        [self addRestartButton];

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

    [self addHero];
    [self createNInitialShield:20];

    // Adjust this value to lengthen wait for hero to come in
    SKAction *waitForFadeToFinish = [SKAction waitForDuration:0.2];
    [self runAction:waitForFadeToFinish completion:^{
        SKAction *makeVillain = [SKAction sequence:@[
                                                     [SKAction performSelector:@selector(addVillain)
                                                                      onTarget:self],
                                                     [SKAction waitForDuration:1.5 withRange:0.5]]];

        SKAction *makeExtraShields = [SKAction sequence:@[
                               [SKAction performSelector:@selector(addShield) onTarget:self],
                               [SKAction waitForDuration:1.0 withRange:0.5]]];
        
        [self runAction:[SKAction repeatActionForever:makeVillain]];
        [self runAction:[SKAction repeatActionForever:makeExtraShields]];
    }];
}


#pragma mark - Creating Sprites
static float PROJECTILE_VELOCITY = 200/1;

- (void)addPauseButton{
    SKTexture *pauseTexture = [SKTexture textureWithImageNamed:@"Pause_Button.png"];
    SKSpriteNode *pauseNode = [SKSpriteNode spriteNodeWithTexture:pauseTexture];
    CGPoint topRightCorner = CGPointMake(self.frame.size.width - pauseNode.size.width - 20.0 ,
                                         self.frame.size.height - pauseNode.size.height - 30.0);
    pauseNode.position = topRightCorner;
    pauseNode.name = @"pause";
    [self addChild:pauseNode];
}

- (void)addRestartButton {
    SKTexture *restartTexture = [SKTexture textureWithImageNamed:@"Retry_Button.png"];
    SKSpriteNode *restartNode = [SKSpriteNode spriteNodeWithTexture:restartTexture];
    CGPoint topLeftCorner = CGPointMake(restartNode.size.width + 10.0,
                                        self.frame.size.height - restartNode.size.height - 26.0);

    restartNode.position = topLeftCorner;
    restartNode.name = @"restart";
    [self addChild:restartNode];
}

- (void)addHero{
    CGPoint sceneCenter = CGPointMake(self.frame.size.width / 2,
                                       self.frame.size.height / 2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:sceneCenter];
    self.hero = newHero;

    SKSpriteNode *shadow = [self.hero createShadow];
    shadow.position = CGPointMake(CGRectGetMidX(self.frame) - 0.8, CGRectGetMidY(self.frame) + 1.0);
    [self addChild:shadow];

    [self addChild:self.hero];

    self.hero.alpha = 0.0;
    shadow.alpha = 0.0;
    SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];

    [self.hero runAction:fadeIn];
    [shadow runAction:fadeIn];

    SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:self.hero.physicsBody
                                                           bodyB:self.physicsBody
                                                          anchor:self.hero.position];
    [self.physicsWorld addJoint:joint];
}


- (void)addVillain{
    //create a random starting point and initialize a villain
    int randomPositionNumber = arc4random_uniform(360);
    CGPoint position = [self createPositionOutsideFrameArrayAtPositionNumber:randomPositionNumber];
    STSVillain *newVillain = [[STSVillain alloc] initAtPosition:position];
    self.sizeOfVillainAndShield = newVillain.size;
    [self addChild:newVillain];
    
    //create the villain's actions
    float realMoveDuration = distanceFormula(self.hero.position, 
                                             newVillain.position) / PROJECTILE_VELOCITY;
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:realMoveDuration];
    
    //create notification for incoming villain
    SKSpriteNode *newNotification =
                        [newVillain createNotificationOnCircleWithCenter:self.hero.position
                                                          positionNumber:randomPositionNumber];
    [self addChild:newNotification];
    
    //run the villain's actions
    [newVillain runAction:moveToHero];
    
}

- (void)addShield {
    int randomPositionNumber = arc4random_uniform(360);
    CGPoint position = [self createPositionOutsideFrameArrayAtPositionNumber:randomPositionNumber];
    STSShield *newShield = [[STSShield alloc] initAtPosition:position];
    [self addChild:newShield];

    float realMoveDuration = distanceFormula(self.hero.position,
                                             newShield.position) / PROJECTILE_VELOCITY;
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:realMoveDuration];
    [newShield runAction:moveToHero];
}

- (void)createNInitialShield:(uint)nShields {
    float incrementor = 360 / nShields;
    float nthPointInCircle = 0;
    for (uint i = 0; i < nShields; i++) {
        CGPoint coordinates = findCoordinatesAlongACircle(self.hero.position,
                                                          self.hero.physicsBodyRadius + 32.0,
                                                          nthPointInCircle);
        STSShield *newShield = [[STSShield alloc] initAtPosition:coordinates];
        newShield.isPartOfBarrier = YES;
        
        [self addChild:newShield];
        newShield.alpha = 0.0;
        SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];
        [newShield runAction:fadeIn];
        
        SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:newShield.physicsBody
                                                                   bodyB:self.hero.physicsBody
                                                                  anchor:coordinates];
        [self.physicsWorld addJoint:joint];
        nthPointInCircle += incrementor;
    }
}

- (void)addScore {
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
    self.scoreLabel.fontSize = 60.0;
    self.scoreLabel.fontColor = [SKColor colorWithRed:211.0 / 255.0 
                                                green:92.0 / 255.0 
                                                 blue:41.0 / 255.0 
                                                alpha:1.0];
    self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), 
                                           CGRectGetMidY(self.frame) + 200.0);

    [self addChild:self.scoreLabel];
}

#pragma mark - Helper Functions for creating Sprites
static inline float distanceFormula(CGPoint a, CGPoint b) {
    return sqrtf(powf(a.x-b.x, 2)+powf(a.y-b.y, 2));
}

static inline CGPoint findCoordinatesAlongACircle(CGPoint center, uint radius, uint n) {
    return CGPointMake(center.x + (radius * cosf(n * (M_PI / 180))),
                       center.y + (radius * sinf(n * (M_PI / 180))));
}

- (CGPoint)createPositionOutsideFrameArrayAtPositionNumber:(int) n {
    CGPoint frameCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return findCoordinatesAlongACircle(frameCenter, 400, n);
}


#pragma mark - Rotation Handler
- (void)didMoveToView:(SKView *)view {
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(handleLongPress:)];
    self.longPress.minimumPressDuration = 0.3;
    [view addGestureRecognizer:self.longPress];
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint location = [recognizer locationInView:self.view];
        SEL selector = @selector(rotate:);
        NSMethodSignature *signature = [STSHero instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:self.hero];
        [invocation setArgument:&location atIndex:2];
        self.longGestureTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                             invocation:invocation
                                                                repeats:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (self.longGestureTimer != nil) {
            [self.longGestureTimer invalidate];
            self.longGestureTimer = nil;
        }
    }
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
            [self.view presentScene:pauseScene transition:swipeLeft];
        }
        else if ([node.name isEqualToString:@"restart"]) {
            STSEndlessGameScene *newEndlessGameScene = [[STSEndlessGameScene alloc] initWithSize:self.frame.size];
            [self.view presentScene:newEndlessGameScene];
        }
        else {
            [self.hero rotate:location];
        }
    }
    else {
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
    if ([first isKindOfClass:[STSHero class]] && [second isKindOfClass:[STSVillain class]]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [self runAction:[SKAction playSoundFileNamed:@"herobeep.caf" waitForCompletion:NO]
                 completion:^{
                     // Game over scene transition when villain hits hero
                     SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                                   duration:0.5];
                     NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
                     if (highScore == 0 || highScore < self.score) {
                         [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:@"highScore"];
                     }
                     SKScene *newGameOverScene = [[STSGameOverScene alloc] initWithSize:self.size];
                     newGameOverScene.userData = [NSMutableDictionary dictionary];
                     NSString *scoreString = [NSString stringWithFormat:@"%d", self.score];
                     [newGameOverScene.userData setObject:scoreString forKey:@"scoreString"];
                     [self.view presentScene:newGameOverScene transition:reveal];
                 }];
        } else {
            // Game over scene transition when villain hits hero
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                          duration:0.5];
            NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
            if (highScore == 0 || highScore < self.score) {
                [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:@"highScore"];
            }
            SKScene *newGameOverScene = [[STSGameOverScene alloc] initWithSize:self.size];
            newGameOverScene.userData = [NSMutableDictionary dictionary];
            NSString *scoreString = [NSString stringWithFormat:@"%d", self.score];
            [newGameOverScene.userData setObject:scoreString forKey:@"scoreString"];
            [self.view presentScene:newGameOverScene transition:reveal];
        };
    } else if ([first isKindOfClass:[STSShield class]] &&
               [second isKindOfClass:[STSShield class]]) {
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

    } else if ([first isKindOfClass:[STSShield class]]
               && [second isKindOfClass:[STSVillain class]]) {
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

        // Play sound effect
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [self runAction:[SKAction playSoundFileNamed:@"Beep.caf" waitForCompletion:YES]];
        }

        // Increment score for each villain blocked
        self.score++;

    } else if (first.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [first removeFromParent];
    } else if (second.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [second removeFromParent];
    }
}


#pragma mark - Frame Updates
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
}

@end
