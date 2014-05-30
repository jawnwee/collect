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

@synthesize isPartOfBarrier;

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Shield_Default"];
    self.savedTexture = [atlas textureNamed:@"Shield.png"];
    self.shieldUp = YES;
    self.hasCollided = NO;
    self.isPartOfBarrier = NO;

    return [super initWithTexture:self.savedTexture atPosition:position];
}

#pragma mark - Overriden Methods

static inline CGFloat marginError(CGFloat radius) {
    return radius + 0.0 * radius;
}
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    CGFloat normalizedRadius = marginError(self.size.width / 2.0);
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:normalizedRadius];
    self.physicsBody.dynamic = YES;
    self.physicsBody.usesPreciseCollisionDetection = NO;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = STSColliderTypeShield;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = STSColliderTypeVillain | STSColliderTypeShield;
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {

    if ([other.node isKindOfClass:[STSVillain class]]) {
        STSVillain *node = (STSVillain *)other.node;
        if (!node.hasBeenCollided && self.isPartOfBarrier){
            node.hasBeenCollided = YES;
            self.texture = nil;
            self.shieldUp = NO;
            self.physicsBody.contactTestBitMask = STSColliderTypeShield;
            [other.node removeFromParent];
        }
    } else if ([other.node isKindOfClass:[STSShield class]]) {
        STSShield *node = (STSShield *)other.node;
        if (!self.shieldUp && !node.isPartOfBarrier && !node.hasCollided) {
            self.shieldUp = YES;
            [node removeFromParent];
            self.texture = self.savedTexture;
            self.physicsBody.contactTestBitMask = STSColliderTypeVillain | STSColliderTypeShield;
        } else if (self.shieldUp && !node.hasCollided && !node.isPartOfBarrier) {
            node.hasCollided = YES;
            [node removeFromParent];
        }
    }
}

@end
