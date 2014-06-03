//
//  STSHero.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSHero.h"
#import "STSVillain.h"

@interface STSHero ()

@property (strong, nonatomic) SKSpriteNode *shadow;
@property (strong, nonatomic) SKSpriteNode *deadHero;

@end

static float MAX_TORQUE = 2.5;
static float MIN_TORQUE = -2.5;

@implementation STSHero

@synthesize physicsBodyRadius;

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Hero_Default"];
    SKTexture *texture = [atlas textureNamed:@"Hero.png"];
    SKTexture *shadowTexture = [atlas textureNamed:@"Hero_Shadow.png"];
    SKTexture *deadHeroTexture = [atlas textureNamed:@"Hero_Dead.png"];
    self.deadHero = [SKSpriteNode spriteNodeWithTexture:deadHeroTexture];
    self.shadow = [SKSpriteNode spriteNodeWithTexture:shadowTexture];
    return [super initWithTexture:texture atPosition:position];
}

#pragma mark - Overriden Methods
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    self.physicsBodyRadius = self.size.width / 2.0 + 5.0;
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.physicsBodyRadius];
    self.physicsBody.angularDamping = 0.2;
    
    self.physicsBody.dynamic = YES;
    self.physicsBody.allowsRotation = YES;
    
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.usesPreciseCollisionDetection = NO;
    self.physicsBody.categoryBitMask = STSColliderTypeHero;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = STSColliderTypeVillain;
}

#pragma mark - Hero Details
- (SKSpriteNode *)createDeadHero {
    return self.deadHero;
}

- (SKSpriteNode *)createShadow {
    return self.shadow;
}

- (void)rotate:(CGPoint)location{
    SKScene *parentView = (SKScene *)self.parent;
    if (location.x > parentView.frame.size.width / 2.0) {
        if (self.physicsBody.angularVelocity >= 0.5) {
            [self.physicsBody applyTorque:-4.0];
        } else if (self.physicsBody.angularVelocity >= MIN_TORQUE) {
            [self.physicsBody applyTorque:-0.7];
        }
    }
    else {
        if (self.physicsBody.angularVelocity <= -0.5) {
            [self.physicsBody applyTorque:4.0];
        } else if (self.physicsBody.angularVelocity <= MAX_TORQUE) {
            [self.physicsBody applyTorque:0.7];
        }
    }
}


@end
