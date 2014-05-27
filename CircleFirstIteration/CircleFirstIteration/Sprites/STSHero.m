//
//  STSHero.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSHero.h"

@implementation STSHero

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Hero"];
    SKTexture *texture = [atlas textureNamed:@"hero.png"];
    return  [super initWithTexture:texture atPosition:position];
}

@end