//
//  STSCharacter.m
//  CircleFirstIteration
//
//  Created by John Lee on 5/26/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSCharacter.h"

@implementation STSCharacter

#pragma mark - Initialization
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position {

    self = [super initWithTexture:texture];
    self.position = position;

    return self;
}


@end
