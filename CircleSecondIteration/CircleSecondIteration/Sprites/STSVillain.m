//
//  STSVillain.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSVillain.h"
#import "STSShield.h"

@implementation STSVillain

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Villain_Default"];
    SKTexture *texture = [atlas textureNamed:@"Villain.png"];

    return [super initWithTexture:texture atPosition:position];
}

#pragma mark - Overriden Methods
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
    self.physicsBody.dynamic = YES;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask = STSColliderTypeVillain;
    self.physicsBody.collisionBitMask = STSColliderTypeShield;
    self.physicsBody.contactTestBitMask = STSColliderTypeShield;
}

- (void)collideWith:(SKPhysicsBody *)other {
    if ([other.node isKindOfClass:[STSShield class]]) {
        [self removeFromParent];
        [other.node removeFromParent];
    } else {
        [self removeFromParent];
    }
}

@end
