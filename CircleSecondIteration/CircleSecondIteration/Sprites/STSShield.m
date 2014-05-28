//
//  STSShield.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSShield.h"
#import "STSHero.h"

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
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
    self.physicsBody.dynamic = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask = STSColliderTypeVillain;
    self.physicsBody.collisionBitMask = STSColliderTypeHero | STSColliderTypeVillain;
    self.physicsBody.contactTestBitMask = STSColliderTypeHero | STSColliderTypeVillain;
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {

    if ([other isKindOfClass:[STSHero class]]) {
        SKSpriteNode *hero = (SKSpriteNode *)other.node;
        CGPoint anchorPoint = contact.contactPoint;
        CGFloat contact_x = anchorPoint.x;
        CGFloat contact_y = anchorPoint.y;

        CGFloat hero_x = hero.position.x + 10.0;
        CGFloat hero_y = hero.position.y + 10.0;

        CGPoint normalized = CGPointMake(contact_x - hero_x, contact_y - hero_y);

        [self removeAllActions];
        [self removeFromParent];

        self.position = normalized;
        self.physicsBody.collisionBitMask = STSColliderTypeVillain;
        self.physicsBody.contactTestBitMask = STSColliderTypeVillain;
        [hero addChild:self];
    }
}

@end
