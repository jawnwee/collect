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

@interface STSShield ()

@property (strong, nonatomic) SKTexture *savedTexture;
@property BOOL shieldUp;
@property BOOL hasCollided;

@end

@implementation STSShield


#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Shield_Default"];
    self.savedTexture = [atlas textureNamed:@"Shield.png"];
    self.shieldUp = YES;
    self.hasCollided = NO;

    return [super initWithTexture:self.savedTexture atPosition:position];
}

#pragma mark - Overriden Methods

static inline CGFloat marginError(CGFloat radius) {
    return radius + radius;
}
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    NSLog(@"shield physics got called");
    CGFloat normalizedRadius = marginError(self.size.width / 2.0);

    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:normalizedRadius];
    self.physicsBody.dynamic = YES;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = STSColliderTypeShield;
    self.physicsBody.collisionBitMask = STSColliderTypeVillain | STSColliderTypeShield;
    self.physicsBody.contactTestBitMask = STSColliderTypeVillain | STSColliderTypeShield;
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {

    if ([other.node isKindOfClass:[STSVillain class]]) {
        self.texture = nil;
        self.shieldUp = NO;
        [other.node removeFromParent];

    } else if ([other.node isKindOfClass:[STSShield class]]) {
        STSShield *node = (STSShield *)other.node;
        if (!self.shieldUp) {
            self.shieldUp = YES;
            [node removeFromParent];
            self.texture = self.savedTexture;
        } else if (self.shieldUp && !node.hasCollided) {
            node.hasCollided = YES;
            [node.physicsBody applyForce:CGVectorMake(10.0, 0.0)];
            [node removeFromParent];
        }
    }
}

@end
