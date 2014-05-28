//
//  STSEndlessGameScene.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSEndlessGameScene.h"
#import "STSHero.h"
#import "STSVillain.h"
#import "STSShield.h"

@interface STSEndlessGameScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) STSHero *hero;
@property CGSize sizeOfVillainAndShield;

@property (nonatomic) UILongPressGestureRecognizer *longPress;

@end

static inline CGPoint findCoordinatesAlongACircle(CGPoint center, uint radius, uint n){
    return CGPointMake(center.x+(radius*cosf(n*(M_PI/180))),
                       center.y+(radius*sinf(n*(M_PI/180))));
}

@implementation STSEndlessGameScene

#pragma mark - Initialization
-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [self createEndlessGameSceneContents];
    }
    return self;
}

#pragma mark - Scene Contents
-(void)createEndlessGameSceneContents {
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsWorld.contactDelegate = self;
    
    self.hero = [self addHero];
    [self addChild:self.hero];
    [self createNInitialShield:12];
    
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
-(STSHero *)addHero{
    CGPoint sceneCenter = CGPointMake(self.frame.size.width/2,
                                       self.frame.size.height/2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:sceneCenter];
    
    return newHero;
}

-(void)addVillain{
    CGPoint randomPositionOutsideFrame = [self createRandomPositionOutsideFrame];
    STSVillain *newVillain = [[STSVillain alloc] initAtPosition:randomPositionOutsideFrame];
    self.sizeOfVillainAndShield = newVillain.size;
    [self addChild:newVillain];
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:1.0];
    [newVillain runAction:moveToHero];
}

-(void)addShield{
    CGPoint randomPositionOutsideFrame = [self createRandomPositionOutsideFrame];
    STSShield *newShield = [[STSShield alloc] initAtPosition:randomPositionOutsideFrame];
    [self addChild:newShield];
    NSLog(@"%f, %f", self.hero.position.x,self.hero.position.y);
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:1.0];
    [newShield runAction:moveToHero];
}

-(void)createNInitialShield:(uint)nShields{
    float incrementor = 360/nShields;
    float nthPointInCirlce = 0;
    for (uint i = 0; i<nShields; i++) {
        CGPoint coordinates = findCoordinatesAlongACircle(CGPointMake(0, 0),
                                                          self.hero.physicsBodyRadius,
                                                          nthPointInCirlce);
        SKSpriteNode *newShield = [[STSShield alloc] initAtPosition:coordinates];
        [self.hero addChild:newShield];
        nthPointInCirlce += incrementor;
    }
}

#pragma mark - Helper Functions for creating Sprites
-(CGPoint) createRandomPositionOutsideFrame{
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
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [view addGestureRecognizer:self.longPress];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    // Create the rotation action
    SKAction *rotateRight = [SKAction rotateByAngle:-M_PI / 4 duration:0.5];
    SKAction *rotateLeft = [SKAction rotateByAngle:M_PI / 4 duration:0.5];

    if (location.x > self.view.frame.size.width / 2) {
        //        NSLog(@"Touch more than halfway");
        [self.hero runAction:rotateRight];
    }
    else {
        //        NSLog(@"Touch less than halfway");
        [self.hero runAction:rotateLeft];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    // Recognize gesture has ended
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.hero removeAllActions];
        // NSLog(@"Long press ended");

        CGPoint location = [self.longPress locationInView:self.view];
        SKAction *rotateRight = [SKAction rotateByAngle:-2*M_PI duration:5];
        SKAction *rotateLeft = [SKAction rotateByAngle:2*M_PI duration:5];

        if (location.x > self.view.frame.size.width / 2) {
            // NSLog(@"Pressing on right half");
            [self.hero runAction:rotateRight];
        }
        else {
            // NSLog(@"Pressing on left half");
            [self.hero runAction:rotateLeft];
        }
        
    }
}


#pragma mark - Collision Logic

/* Contact logic will be cleaned up accordingly, way too many else ifs */
-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKNode *first, *second;
    first = contact.bodyA.node;
    second = contact.bodyB.node;

    if ([first isKindOfClass:[STSHero class]] && [second isKindOfClass:[STSVillain class]]) {
        NSLog(@"first: hero, second: villain");
        [(STSCharacter *)first collideWith:contact.bodyB];

    } else if ([first isKindOfClass:[STSVillain class]] && [second isKindOfClass:[STSHero class]]) {
        NSLog(@"first: villain, second: hero");
        [(STSCharacter *)second collideWith:contact.bodyA];
    } else if ([first isKindOfClass:[STSShield class]] && [second isKindOfClass:[STSHero class]]) {
        NSLog(@"first: shield, second: hero");
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

    } else if ([first isKindOfClass:[STSHero class]] && [second isKindOfClass:[STSShield class]]){
        NSLog(@"first: hero, second: shield");
        [(STSCharacter *)second collideWith:contact.bodyA contactAt:contact];
    } else if ([first isKindOfClass:[STSShield class]] && [second isKindOfClass:[STSVillain class]]) {
        NSLog(@"first: shield, second: villain");
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];

    } else {
        NSLog(@"first: villain, second: hero");
        [(STSCharacter *)second collideWith:contact.bodyA contactAt:contact];
    }
}

#pragma mark - Frame Updates
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.longPress.state == UIGestureRecognizerStateBegan) {
        // Get long press location
        CGPoint location = [self.longPress locationInView:self.view];

        // Rotate actions
        SKAction *rotateRight = [SKAction rotateByAngle:-M_PI duration:60];
        SKAction *rotateRightForever = [SKAction repeatActionForever:rotateRight];
        SKAction *rotateLeft = [SKAction rotateByAngle:M_PI duration:60];
        SKAction *rotateLeftForever = [SKAction repeatActionForever:rotateLeft];
        // NSLog(@"You pressed at - x: %f y: %f", location.x, location.y);
        if (location.x > self.view.frame.size.width / 2) {
            // NSLog(@"Pressing on right half");
            [self.hero runAction:rotateRightForever];
        }
        else {
            // NSLog(@"Pressing on left half");
            [self.hero runAction:rotateLeftForever];
        }
    }
}

@end
