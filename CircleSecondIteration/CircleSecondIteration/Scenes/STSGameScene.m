//
//  STSGameScene.m
//  Ozone!
//
//  Created by John Lee on 6/19/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSGameScene.h"
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
@interface STSGameScene ()
@property (strong, nonatomic) STSHero *hero;

@property CGSize sizeOfVillainAndShield;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastIncreaseToScoreTimeInterval;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) NSTimer *longGestureTimer;

@property (nonatomic) UILongPressGestureRecognizer *longPress;
@end

@implementation STSGameScene

#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {

    }
    return self;
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

    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:@"EndlessGameScene"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"restart_endless_game"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];

    SKTexture *restartTexture = [SKTexture textureWithImageNamed:@"Retry_Button.png"];
    SKSpriteNode *restartNode = [SKSpriteNode spriteNodeWithTexture:restartTexture];
    CGPoint topLeftCorner = CGPointMake(restartNode.size.width + 10.0,
                                        self.frame.size.height - restartNode.size.height - 26.0);

    restartNode.position = topLeftCorner;
    restartNode.name = @"restart";
    [self addChild:restartNode];
}


// The logic behind here is to add a dead hero image on top of the hero with 0.0 alpha
// This means that when the game is over, the positioning of the white dot on the dead/normal
// hero is the same and will show a simultaneous fade in/out animation
- (void)addHero {
    CGPoint sceneCenter = CGPointMake(self.frame.size.width / 2,
                                      self.frame.size.height / 2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:sceneCenter];
    self.hero = newHero;

    SKSpriteNode *shadow = [self.hero createShadow];
    shadow.position = CGPointMake(CGRectGetMidX(self.frame) - 0.8, CGRectGetMidY(self.frame) + 1.0);
    shadow.name = @"HeroShadow";
    [self addChild:shadow];

    SKSpriteNode *deadHero = [self.hero createDeadHero];
    deadHero.name = @"deadHero";
    deadHero.position = sceneCenter;
    deadHero.alpha = 0.0;
    [self addChild:deadHero];
    [self addChild:self.hero];

    self.hero.alpha = 0.0;
    shadow.alpha = 0.0;
    SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];
    SKAction *fadeInForDeadHero = [SKAction fadeAlphaTo:0.5 duration:1.0];

    [deadHero runAction:fadeInForDeadHero];
    [self.hero runAction:fadeIn];
    [shadow runAction:fadeIn];

    SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:self.hero.physicsBody
                                                           bodyB:self.physicsBody
                                                          anchor:self.hero.position];
    [self.physicsWorld addJoint:joint];
}



- (void)addVillain {
    //create a random starting point and initialize a villain
    int randomPositionNumber = arc4random_uniform(360);
    CGPoint position = [self createPositionOutsideFrameArrayAtPositionNumber:randomPositionNumber];
    STSVillain *newVillain = [[STSVillain alloc] initAtPosition:position];
    newVillain.name = @"Villain";
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
    newNotification.name = @"notification";
    [self addChild:newNotification];

    //run the villain's actions
    [newVillain runAction:moveToHero];

}

- (void)addShield {
    int randomPositionNumber = arc4random_uniform(360);
    CGPoint position = [self createPositionOutsideFrameArrayAtPositionNumber:randomPositionNumber];
    STSShield *newShield = [[STSShield alloc] initAtPosition:position];
    newShield.name = @"Shield";
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
        newShield.name = @"HeroShield";
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
    return findCoordinatesAlongACircle(frameCenter, 450, n);
}


#pragma mark - Rotation Handler
- (void)didMoveToView:(SKView *)view {
    self.longPress = [[UILongPressGestureRecognizer alloc]
                      initWithTarget:self
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
- (void)didBeginContact:(SKPhysicsContact *)contact {
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

    } else if (first.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [first removeFromParent];
    } else if (second.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [second removeFromParent];
    }
}


#pragma mark - Game Over Animation

/* Animation to make all villains and shields from appearing and make heroes current shields fly out
 Hero then bounces up, then quickly down in order to transition into GameOverScene */
- (void)gameOver {
    [self removeAllActions];
    CGPoint middle = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.hero.physicsBody.dynamic = NO;
    SKAction *waitDuration = [SKAction waitForDuration:0.7];
    SKAction *waitAfter = [SKAction waitForDuration:0.3];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.1];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.1];
    SKAction *bounceUp = [SKAction moveByX:0.0 y:10.0 duration:0.5];
    SKAction *bounceDown = [SKAction moveByX:0.0 y:-500.0 duration:0.2];
    SKAction *bounceSequence =[SKAction sequence:@[waitDuration, bounceUp, bounceDown, waitAfter]];
    SKAction *slightWait = [SKAction waitForDuration:0.2];

    SKSpriteNode *deadHero = (SKSpriteNode *)[self childNodeWithName:@"deadHero"];
    deadHero.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    SKSpriteNode *shadow = (SKSpriteNode *)[self childNodeWithName:@"HeroShadow"];
    deadHero.zRotation = self.hero.zRotation;

    // Checking for all villains and shields to throw them out of the scene
    CGFloat sceneMidXCoordinate = middle.x;
    CGFloat sceneMidYCoordinate = middle.y;
    for (SKSpriteNode *node in self.children) {
        if ([node.name isEqualToString:@"HeroShield"]) {
            if (node.position.x >= sceneMidXCoordinate && node.position.y >= sceneMidYCoordinate) {
                SKAction *pushUpAndRight = [SKAction moveByX:500.0 y:500.0 duration:1.0];
                [node runAction:[SKAction sequence:@[slightWait, pushUpAndRight]]];
            } else if (node.position.x >= sceneMidXCoordinate
                       && node.position.y <= sceneMidYCoordinate) {
                SKAction *pushDownAndRight = [SKAction moveByX:500.0 y:-500.0 duration:1.0];
                [node runAction:[SKAction sequence:@[slightWait, pushDownAndRight]]];
            } else if (node.position.x <= sceneMidXCoordinate
                       && node.position.y <= sceneMidYCoordinate) {
                SKAction *pushDownAndLeft = [SKAction moveByX:-500.0 y:-500.0 duration:1.0];
                [node runAction:[SKAction sequence:@[slightWait, pushDownAndLeft]]];
            } else {
                SKAction *pushUpAndLeft = [SKAction moveByX:-500.0 y:500.0 duration:1.0];
                [node runAction:[SKAction sequence:@[slightWait, pushUpAndLeft]]];
            }
        } else if ([node.name isEqualToString:@"Shield"]
                   || [node.name isEqualToString:@"Villain"]
                   || [node.name isEqualToString:@"notification"]) {

            [node removeFromParent];

        } else if ([node.name isEqualToString:@"pause"] || [node.name isEqualToString:@"restart"]
                   || [node.name isEqualToString:@"score"]) {
            [node runAction:fadeOut];
        }
    }

    [deadHero runAction:fadeIn];
    [deadHero runAction:bounceSequence];
    [shadow runAction:bounceSequence];
    [shadow runAction:fadeOut];
    [self.physicsWorld removeAllJoints];
    [self.hero runAction:fadeOut];
    [self.hero runAction:bounceSequence];

}

#pragma mark - Frame Updates
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
