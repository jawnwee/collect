//
//  STSHero.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSHero.h"

@implementation STSHero

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Hero"];
    SKTexture *texture = [atlas textureNamed:@"hero.png"];
    return  [super initWithTexture:texture atPosition:position];
}

- (void)configurePhysicsBody {
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
    self.physicsBody.dynamic = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask = STSColliderTypeHero;
    self.physicsBody.collisionBitMask = STSColliderTypeVillain;
    self.physicsBody.contactTestBitMask = STSColliderTypeVillain;
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact{
    if (other.categoryBitMask & STSColliderTypeVillain) {
        SKSpriteNode *villain = (SKSpriteNode *)other.node;
        [villain removeAllActions];
        [villain removeFromParent];
        //villain.position = normalized;
        [self addChild:villain];
    }
}

@end