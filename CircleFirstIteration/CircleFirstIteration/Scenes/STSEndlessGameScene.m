//
//  STSMyScene.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSEndlessGameScene.h"
#import "STSHero.h"
#import "STSVillain.h"

@interface STSEndlessGameScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) STSHero *hero;

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
- (STSHero *)addHero {

    STSHero *hero = [[STSHero alloc] initAtPosition:CGPointMake(CGRectGetMidX(self.frame), 
                                                                CGRectGetMidY(self.frame) - 150.0)];
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

    STSVillain *villain = [[STSVillain alloc] initAtPosition:CGPointMake(skRand(0, self.size.width),
                                                                        self.size.height - 50.0)];

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

    SKNode *node = contact.bodyA.node;
    if ([node isKindOfClass:[STSHero class]]) {
        [(STSHero *)node collideWith:contact.bodyB contactAt:contact];
    } else if ([node isKindOfClass:[STSVillain class]]) {
        [(STSVillain *)node collideWith:contact.bodyB contactAt:contact];
    }

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

    if (self.hero.children.count == 10) {
        for (SKSpriteNode *child in self.hero.children) {
            SKAction *removeVillainsAction = [self removeVillainsFromHero];
            child.physicsBody.dynamic = NO;
            [child runAction:removeVillainsAction withKey:@"remove"];
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
}

@end
