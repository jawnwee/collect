//
//  STSCharacter.h
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

/* Collision bitmask for physics bodies */
typedef enum :uint8_t {
    STSColliderTypeHero  = 0x1 << 0,
    STSColliderTypeVillain = 0x1 << 1
} STSColliderType;

#import <SpriteKit/SpriteKit.h>

@interface STSCharacter : SKSpriteNode

/* Initialize a standard SpriteNode */
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

/* Overridden Methods */
- (void)configurePhysicsBody;
- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact;

@end
