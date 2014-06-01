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

- (SKSpriteNode *)showWarning:(CGPoint)originalPos padding:(float)padding side:(int)side {
    // Set up coordinates
    CGRect temp = CGRectMake(100, 100, 50, 50);
    SKSpriteNode *warning = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:temp.size];
    float selfX = self.position.x;
    float selfY = self.position.y;
    float heroX = self.frame.size.width / 2;
    float heroY = self.frame.size.height / 2;
    float dX = selfX - heroX;
    float dY = selfY - heroY;

    if (side == 0) {
        float paddingX = padding;
        float paddingY = (dY * paddingX) / dX;
        warning.position = CGPointMake(selfX - paddingX + 25, selfY - paddingY);
    } else if (side == 1) {
        float paddingY = padding;
        float paddingX = (dX * paddingY) / dY;
        warning.position = CGPointMake(selfX - paddingX, selfY - paddingY - 25);
    } else if (side == 2) {
        float paddingX = padding;
        float paddingY = (dY * paddingX) / dX;
        warning.position = CGPointMake(selfX - paddingX - 25, selfY - paddingY);
    } else {
        float paddingY = padding;
        float paddingX = (dX * paddingY) / dY;
        warning.position = CGPointMake(selfX - paddingX, selfY - paddingY + 25);
    }

//    // Coming from the top or bottom
//    if (selfX - originalPos.x == 0) {
//        float paddingY = padding;
//        float paddingX = (dX * paddingY) / dY;
//        warning.position = CGPointMake(selfX - paddingX, selfY - paddingY);
//    }
//
//    // Coming from the left or right
//    else {
//        float paddingX = padding;
//        float paddingY = (dY * paddingX) / dX;
//        warning.position = CGPointMake(selfX - paddingX, selfY - paddingY);
//    }

    return warning;
}



@end
