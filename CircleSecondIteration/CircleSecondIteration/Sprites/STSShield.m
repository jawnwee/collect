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
@property BOOL shieldIsUp;

@end

@implementation STSShield

@synthesize hasBeenCollided;

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Shield_Default"];
    self.savedTexture = [atlas textureNamed:@"Shield.png"];
    self.shieldIsUp = YES;

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
    self.physicsBody.collisionBitMask = STSColliderTypeVillain | 
                                        STSColliderTypeHero | 
                                        STSColliderTypeShield;
    self.physicsBody.contactTestBitMask = STSColliderTypeVillain |
                                          STSColliderTypeHero |
                                          STSColliderTypeShield;
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {

    if ([other.node isKindOfClass:[STSHero class]]) {
        [self removeFromParent];

    } else if ([other.node isKindOfClass:[STSVillain class]]) {
        self.texture = nil;
        [other.node removeFromParent];

    } else if ([other.node isKindOfClass:[STSShield class]]) {
        if (!self.shieldIsUp) {
            [other.node removeFromParent];
            self.texture = self.savedTexture;
            self.shieldIsUp = YES;
        } else {
            self.shieldIsUp = NO;
            [other.node removeFromParent];
        }
    }
}

@end
