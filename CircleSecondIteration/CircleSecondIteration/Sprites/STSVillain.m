//
//  STSVillain.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSVillain.h"
#import "STSShield.h"
#import "STSHero.h"

@implementation STSVillain

@synthesize hasBeenCollided;

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Villain_Default"];
    SKTexture *texture = [atlas textureNamed:@"Villain.png"];
    self.hasBeenCollided = NO;

    return [super initWithTexture:texture atPosition:position];
}

#pragma mark - Overriden Methods
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
    self.physicsBody.dynamic = YES;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.usesPreciseCollisionDetection = NO;
    self.physicsBody.categoryBitMask = STSColliderTypeVillain;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
}

- (SKSpriteNode *)createNotificationOnCircleWithCenter:(CGPoint)center positionNumber:(float)n{
    //create notification node and configure its physics body
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Villain_Default"];
    SKTexture *villainNotificationTexture = [atlas textureNamed:@"Villain_Warning.png"];
    SKSpriteNode *warning = [SKSpriteNode spriteNodeWithTexture:villainNotificationTexture];
    warning.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:warning.size.width / 2.0];
    warning.physicsBody.dynamic = NO;
    warning.physicsBody.categoryBitMask = STSColliderTypeNotification;
    warning.physicsBody.collisionBitMask = 0;
    warning.physicsBody.contactTestBitMask = STSColliderTypeVillain;
    
    //find position of notification
    warning.position = findCoordinatesAlongACircle(center,
                                                  self.parent.frame.size.width / 2 - warning.size.width,
                                                  n);
    
    return warning;
}

static inline CGPoint findCoordinatesAlongACircle(CGPoint center, uint radius, uint n) {
    return CGPointMake(center.x + (radius * cosf(n * (M_PI / 180))),
                       center.y + (radius * sinf(n * (M_PI / 180))));
}

@end
