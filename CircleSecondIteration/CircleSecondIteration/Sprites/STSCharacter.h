//
//  STSCharacter.h
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

/* Collision bitmask for physics bodies */
typedef enum:uint8_t {
    STSColliderTypeHero = 0x1 << 0,
    STSColliderTypeShield = 0x1 << 1,
    STSColliderTypeVillain = 0x1 << 2
} STSColliderType;

@interface STSCharacter : SKSpriteNode

/* Initialize a SpriteNode */
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

/* Overridden Methods */
- (void)configurePhysicsBody;
- (void)collideWith:(SKPhysicsBody *)other;
- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact;


@end
