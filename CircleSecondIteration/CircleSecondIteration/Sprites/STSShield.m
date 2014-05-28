//
//  STSShield.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSShield.h"
#import "STSHero.h"
#import "STSVillain.h"

@implementation STSShield

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Shield_Default"];
    SKTexture *texture = [atlas textureNamed:@"Shield.png"];

    return [super initWithTexture:texture atPosition:position];
}

#pragma mark - Overriden Methods
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    NSLog(@"shield physics got called");
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
    self.physicsBody.dynamic = YES;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = STSColliderTypeShield;
    self.physicsBody.collisionBitMask = STSColliderTypeHero | STSColliderTypeVillain;
    self.physicsBody.contactTestBitMask = STSColliderTypeHero | STSColliderTypeVillain;
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {

    if ([other.node isKindOfClass:[STSHero class]]) {
        SKSpriteNode *hero = (SKSpriteNode *)other.node;
        CGPoint anchorPoint = contact.contactPoint;
        CGFloat contact_x = anchorPoint.x;
        CGFloat contact_y = anchorPoint.y;

        CGFloat hero_x = hero.position.x + 20.0;
        CGFloat hero_y = hero.position.y + 20.0;

        CGPoint normalized = CGPointMake(contact_x - hero_x, contact_y - hero_y);

        [self removeAllActions];
        [self removeFromParent];

        self.position = normalized;
        self.physicsBody.dynamic = NO;
        self.physicsBody.collisionBitMask = STSColliderTypeVillain;
        self.physicsBody.contactTestBitMask = STSColliderTypeVillain;
        [hero addChild:self];
    } else if ([other.node isKindOfClass:[STSVillain class]]) {
        [self removeFromParent];
        [other.node removeFromParent];
    }
}

@end
