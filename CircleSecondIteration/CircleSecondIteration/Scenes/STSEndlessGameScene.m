//
//  STSEndlessGameScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSEndlessGameScene.h"
#import "STSGameOverScene.h"
#import "STSHero.h"
#import "STSVillain.h"
#import "STSShield.h"

@interface STSEndlessGameScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) STSHero *hero;
@property CGSize sizeOfVillainAndShield;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastIncreaseToScoreTimeInterval;
@property (nonatomic) SKLabelNode *scoreLabel;

@property (nonatomic) UILongPressGestureRecognizer *longPress;

@end

@implementation STSEndlessGameScene

#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [self createEndlessGameSceneContents];
    }
    return self;
}

#pragma mark - Scene Contents
- (void)createEndlessGameSceneContents {
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.backgroundColor = [SKColor colorWithRed:235.0 / 255.0 
                                           green:113.0 / 255.0 
                                            blue:61.0 / 255.0 
                                           alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:[self frame]];
    self.physicsWorld.contactDelegate = self;

    [self addHero];
    [self createNInitialShield:20];
    [self addScore];

    SKAction *makeVillain = [SKAction sequence:@[
                                    [SKAction performSelector:@selector(addVillain)
                                                     onTarget:self],
                                    [SKAction waitForDuration:1.0
                                                    withRange:0.5]]];
    SKAction *makeExtraShields = [SKAction sequence:@[
                                    [SKAction performSelector:@selector(addShield)
                                                     onTarget:self],
                                    [SKAction waitForDuration:1.0
                                                    withRange:0.5]]];

    [self runAction:[SKAction repeatActionForever:makeVillain]];
    [self runAction:[SKAction repeatActionForever:makeExtraShields]];
}


#pragma mark - Creating Sprites
- (void)addHero{
    CGPoint sceneCenter = CGPointMake(self.frame.size.width/2,
                                       self.frame.size.height/2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:sceneCenter];
    self.hero = newHero;
    [self addChild:self.hero];

    SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:self.hero.physicsBody
                                                           bodyB:self.physicsBody
                                                          anchor:self.hero.position];
    [self.physicsWorld addJoint:joint];
}

- (void)addVillain{
    CGPoint randomPositionOutsideFrame = [self createRandomPositionOutsideFrame];
    STSVillain *newVillain = [[STSVillain alloc] initAtPosition:randomPositionOutsideFrame];
    self.sizeOfVillainAndShield = newVillain.size;
    [self addChild:newVillain];
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:1.0];
    [newVillain runAction:moveToHero];
}

- (void)addShield{
    CGPoint randomPositionOutsideFrame = [self createRandomPositionOutsideFrame];
    STSShield *newShield = [[STSShield alloc] initAtPosition:randomPositionOutsideFrame];
    [self addChild:newShield];

    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:1.0];
    [newShield runAction:moveToHero];
}

static inline CGPoint findCoordinatesAlongACircle(CGPoint center, uint radius, uint n){
    return CGPointMake(center.x + (radius * cosf(n * (M_PI/180))),
                       center.y + (radius * sinf(n * (M_PI/180))));
}

- (void)createNInitialShield:(uint)nShields{
    float incrementor = 360 / nShields;
    float nthPointInCirlce = 0;
    for (uint i = 0; i < nShields; i++) {
        CGPoint coordinates = findCoordinatesAlongACircle(self.hero.position,
                                                          self.hero.physicsBodyRadius + 32.0,
                                                          nthPointInCirlce);
        STSShield *newShield = [[STSShield alloc] initAtPosition:coordinates];
        newShield.isPartOfBarrier = YES;
        
        [self addChild:newShield];
        SKAction *fadeIn = [SKAction fadeInWithDuration:1.5];
        [newShield runAction:fadeIn];
        
        SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:newShield.physicsBody
                                                                   bodyB:self.hero.physicsBody
                                                                  anchor:coordinates];
        [self.physicsWorld addJoint:joint];
        nthPointInCirlce += incrementor;
    }
}

- (void)addScore {
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
    self.scoreLabel.fontSize = 36.0;
    self.scoreLabel.fontColor = [SKColor colorWithRed:211.0 / 255.0 
                                                green:92.0 / 255.0 
                                                 blue:41.0 / 255.0 
                                                alpha:1.0];
    self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), 
                                           CGRectGetMidY(self.frame) + 150);

    [self addChild:self.scoreLabel];
}

#pragma mark - Helper Functions for creating Sprites
- (CGPoint)createRandomPositionOutsideFrame{
    int sideBulletComesFrom = arc4random_uniform(4);
    float xCoordinate, yCoordinate;
    if (sideBulletComesFrom == 0) {
        xCoordinate = -self.sizeOfVillainAndShield.width;
        yCoordinate = arc4random_uniform(self.frame.size.height);
    } else if (sideBulletComesFrom == 1){
        xCoordinate = arc4random_uniform(self.frame.size.width);
        yCoordinate = self.frame.size.height+self.sizeOfVillainAndShield.height;
    } else if (sideBulletComesFrom == 2){
        xCoordinate = self.frame.size.width+self.sizeOfVillainAndShield.width;
        yCoordinate = arc4random_uniform(self.frame.size.height);
    } else {
        xCoordinate = arc4random_uniform(self.frame.size.width);
        yCoordinate = -self.sizeOfVillainAndShield.height;
    }
    return CGPointMake(xCoordinate, yCoordinate	);
}


#pragma mark - Rotation Handler
- (void)didMoveToView:(SKView *)view {
    // Initiate the long press gesture
    // self.longPress = [[UILongPressGestureRecognizer alloc]
    //                  initWithTarget:self action:@selector(handleLongPress:)];
    // [view addGestureRecognizer:self.longPress];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    if (location.x > self.view.frame.size.width / 2.0) {
        NSLog(@"Touch more than halfway");
        //[self.hero.physicsBody applyForce:CGVectorMake(100.0, 0.0)
                                  //atPoint:CGPointMake(self.hero.position.x, self.hero.position.y + 15)];
        [self.hero.physicsBody applyTorque:-0.5];
    }
    else {
        NSLog(@"Touch less than halfway");
        //[self.hero.physicsBody applyForce:CGVectorMake(-100.0, 0.0)
                                  //atPoint:CGPointMake(self.hero.position.x, self.hero.position.y + 15)];
        [self.hero.physicsBody applyTorque:0.5];

    }
}

// Uncomment to allot longPress
//- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
//    // Recognize gesture has ended
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        [self.hero removeAllActions];
//        // NSLog(@"Long press ended");
//
//        CGPoint location = [self.longPress locationInView:self.view];
//        SKAction *rotateRight = [SKAction rotateByAngle:-2 * M_PI duration:5];
//        SKAction *rotateLeft = [SKAction rotateByAngle:2 * M_PI duration:5];
//
//        if (location.x > self.view.frame.size.width / 2) {
//            // NSLog(@"Pressing on right half");
//            [self.hero runAction:rotateRight];
//        }
//        else {
//            // NSLog(@"Pressing on left half");
//            [self.hero runAction:rotateLeft];
//        }
//        
//    }
//}


#pragma mark - Contact Logic

/* Contact logic will be cleaned up accordingly, way too many else ifs */
-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKNode *first, *second;
    first = contact.bodyA.node;
    second = contact.bodyB.node;

    if ([first isKindOfClass:[STSHero class]] && [second isKindOfClass:[STSVillain class]]) {
        NSLog(@"first: hero, second: villain");
        [(STSCharacter *)first collideWith:contact.bodyB];

        // Game over scene transition when villain hits hero
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.5];
        SKScene *newGameOverScene = [[STSGameOverScene alloc] initWithSize:self.size];
        /* Test for high score */

        NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
        if (highScore == 0 || highScore < self.score) {
            [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:@"highScore"];
        }

        newGameOverScene.userData = [NSMutableDictionary dictionary];
        NSString *scoreString = [NSString stringWithFormat:@"%d", self.score];
        [newGameOverScene.userData setObject:scoreString forKey:@"scoreString"];
        [self.view presentScene:newGameOverScene transition:reveal];

    } else if ([first isKindOfClass:[STSShield class]] && [second isKindOfClass:[STSShield class]]) {
        NSLog(@"first: shield, second: shield");
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

    } else if ([first isKindOfClass:[STSShield class]]
               && [second isKindOfClass:[STSVillain class]]) {
        NSLog(@"first: shield, second: villain");
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];
        
        // Increment score for each villain blocked
        self.score++;

    }
}

#pragma mark - Frame Updates
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

    // Keep score by time
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
    [self updateWithTimeSinceLastUpdate:timeSinceLast];

//    // Uncomment to allot longPress activation
//    if (self.longPress.state == UIGestureRecognizerStateBegan) {
//        // Get long press location
//        CGPoint location = [self.longPress locationInView:self.view];
//
//        // Rotate actions
//        SKAction *rotateRight = [SKAction rotateByAngle:-M_PI duration:60];
//        SKAction *rotateRightForever = [SKAction repeatActionForever:rotateRight];
//        SKAction *rotateLeft = [SKAction rotateByAngle:M_PI duration:60];
//        SKAction *rotateLeftForever = [SKAction repeatActionForever:rotateLeft];
//        // NSLog(@"You pressed at - x: %f y: %f", location.x, location.y);
//        if (location.x > self.view.frame.size.width / 2) {
//            // NSLog(@"Pressing on right half");
//            [self.hero runAction:rotateRightForever];
//        }
//        else {
//            // NSLog(@"Pressing on left half");
//            [self.hero runAction:rotateLeftForever];
//        }
//    }
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {

    self.lastIncreaseToScoreTimeInterval += timeSinceLast;
    if (self.lastIncreaseToScoreTimeInterval > 1) {
        self.lastIncreaseToScoreTimeInterval = 0;
//        self.score++;
    }

}

@end
