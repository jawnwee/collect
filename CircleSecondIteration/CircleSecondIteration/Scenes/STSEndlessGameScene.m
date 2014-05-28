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

@interface STSEndlessGameScene () <SKPhysicsContactDelegate>
@property (strong, nonatomic) STSHero *hero;
@property CGSize sizeOfVillainAndShield;
@end

@implementation STSEndlessGameScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [self createEndlessGameSceneContents];
    }
    return self;
}

#pragma makr - Scene Contents

-(void)createEndlessGameSceneContents {
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsWorld.contactDelegate = self;
    
    self.hero = [self addHeroWithShields];
    [self addChild:self.hero];
    
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

-(STSHero *)addHeroWithShields{
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
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:1.0];
    [newShield runAction:moveToHero];
}

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

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
}


@end
