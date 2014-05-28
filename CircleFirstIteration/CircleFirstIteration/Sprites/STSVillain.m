//
//  STSVillain.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSVillain.h"

@implementation STSVillain

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Villain"];
    SKTexture *texture = [atlas textureNamed:@"villain.png"];
    return  [super initWithTexture:texture atPosition:position];
}

- (void)configurePhysicsBody {
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = STSColliderTypeVillain;
    self.physicsBody.collisionBitMask = STSColliderTypeVillain | STSColliderTypeHero;
    self.physicsBody.contactTestBitMask = STSColliderTypeVillain | STSColliderTypeHero;
}

@end
