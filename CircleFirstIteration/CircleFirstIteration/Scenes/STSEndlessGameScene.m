//
//  STSMyScene.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSEndlessGameScene.h"

@interface STSEndlessGameScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKSpriteNode *hero;

@end

@implementation STSEndlessGameScene



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

    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.physicsWorld.contactDelegate = self;

    self.hero = [self addHero];
    self.hero.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 150.0);
    [self addChild:self.hero];

    SKAction *makeVillains = [SKAction sequence:@[
                                    [SKAction performSelector:@selector(addVillain) onTarget:self],
                                    [SKAction waitForDuration:1.0 withRange:0.5]]];
    [self runAction:[SKAction repeatActionForever:makeVillains]];


}

#pragma mark - Touch Handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    SKAction *move = [SKAction moveTo:location duration:0.5];
    [self.hero runAction:move];

}


#pragma mark - Adding Nodes
- (SKSpriteNode *)addHero {

    SKTexture *heroTexture = [SKTexture textureWithImageNamed:@"hero.png"];
    SKSpriteNode *hero = [[SKSpriteNode alloc] initWithTexture:heroTexture];

    hero.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:hero.size.width / 2.0];
    hero.physicsBody.dynamic = NO;
    hero.physicsBody.usesPreciseCollisionDetection = YES;
    hero.physicsBody.categoryBitMask = STSColliderTypeHero;
    hero.physicsBody.collisionBitMask = STSColliderTypeVillain;
    hero.physicsBody.contactTestBitMask = STSColliderTypeVillain;
    SKAction *rotation = [SKAction rotateByAngle:M_PI_4 duration:0.5];
    [hero runAction:[SKAction repeatActionForever:rotation]];


    return hero;
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat)RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

- (void)addVillain {

    SKTexture *villainTexture = [SKTexture textureWithImageNamed:@"villain.png"];
    SKSpriteNode *villain = [[SKSpriteNode alloc] initWithTexture:villainTexture];

    villain.position = CGPointMake(skRand(0, self.size.width), self.size.height - 50.0);
    villain.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:villain.size.width / 2.0];
    villain.physicsBody.affectedByGravity = NO;
    villain.physicsBody.categoryBitMask = STSColliderTypeVillain;
    villain.physicsBody.collisionBitMask = STSColliderTypeVillain | STSColliderTypeHero;
    villain.physicsBody.contactTestBitMask = STSColliderTypeVillain | STSColliderTypeHero;

    [self addChild:villain];

    SKAction *moveVillain = [SKAction moveBy:CGVectorMake(0, -self.size.height + 100) duration:2.0];
    SKAction *removeVillainFromScene = [SKAction removeFromParent];

    [villain runAction:[SKAction sequence:@[moveVillain, removeVillainFromScene]]];
}

#pragma mark - Collision Logic

- (void)didBeginContact:(SKPhysicsContact *)contact {
    CGPoint anchorPoint = contact.contactPoint;
    CGFloat contact_x = anchorPoint.x;
    CGFloat contact_y = anchorPoint.y;

    CGFloat hero_x = self.hero.position.x;
    CGFloat hero_y = self.hero.position.y;

    CGPoint normalized = CGPointMake(contact_x - hero_x, contact_y - hero_y);
    //SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:contact.bodyA
                                                               //bodyB:contact.bodyB
                                                              //anchor:anchorPoint];

    if (contact.bodyA.categoryBitMask == STSColliderTypeVillain) {
        SKSpriteNode *villain = (SKSpriteNode *)contact.bodyA.node;
        [villain removeAllActions];
        [villain removeFromParent];
        villain.position = normalized;
        [self.hero addChild:villain];
    }
    if (contact.bodyB.categoryBitMask == STSColliderTypeVillain) {
        SKSpriteNode *villain = (SKSpriteNode *)contact.bodyB.node;
        [villain removeAllActions];
        [villain removeFromParent];
        villain.position = normalized;
        [self.hero addChild:villain];
    }

    if (self.hero.children.count >= 2) {
        for (SKSpriteNode *child in self.hero.children) {
            SKAction *removeNode = [self removeVillainsFromHero];
            child.physicsBody.dynamic = NO;
            [child runAction:removeNode];
        }
    }
}

#pragma mark - Removing Nodes
- (SKAction *)removeVillainsFromHero {
    SKAction *moveToHeroCenter = [SKAction moveTo:self.hero.anchorPoint duration:0.5];
    SKAction *shrink = [SKAction scaleTo:0.1 duration:0.7];
    SKAction *fadeAway = [SKAction fadeOutWithDuration:0.7];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *absorbAction = [SKAction group:@[moveToHeroCenter, shrink, fadeAway]];
    SKAction *sequence = [SKAction sequence:@[absorbAction, remove]];

    return sequence;
}

#pragma mark - Frame Updates
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CGPoint heroPosition = self.hero.position;
    if (self.hero.children.count == 100) {
        for (SKSpriteNode *child in self.hero.children) {
            [child removeFromParent];
            child.position = heroPosition;
            [self.scene addChild:child];
            SKAction *removeNode = [self removeVillainsFromHero];
            child.physicsBody.dynamic = NO;
            [child runAction:removeNode withKey:@"remove"];
        }
    }

}

@end
