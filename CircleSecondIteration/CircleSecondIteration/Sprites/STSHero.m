//
//  STSHero.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSHero.h"

@implementation STSHero

@synthesize physicsBodyRadius;

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Hero_Default"];
    SKTexture *texture = [atlas textureNamed:@"Hero.png"];
    
    return [super initWithTexture:texture atPosition:position];
}

#pragma mark - Overriden Methods
/* If ever in contact with shield or enemy; either add shield or lose game */
- (void)configurePhysicsBody {
    NSLog(@"this got called");
    self.physicsBodyRadius = self.size.width / 2.0 + 20.0;
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


@end
