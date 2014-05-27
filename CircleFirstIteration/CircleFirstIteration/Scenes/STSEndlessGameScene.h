//
//  STSMyScene.h
//  CircleFirstIteration
//

//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// Collision Bit masks
typedef enum :uint8_t {
    STSColliderTypeHero  = 0x1 << 0,
    STSColliderTypeVillain = 0x1 << 1
} STSColliderType;

@interface STSEndlessGameScene : SKScene

@end
