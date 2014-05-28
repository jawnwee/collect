//
//  STSCharacter.m
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSCharacter.h"

@implementation STSCharacter

#pragma mark - Initialization
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position {
    self = [super initWithTexture:texture];
    self.position = position;
    [self configurePhysicsBody];
    return self;
}

#pragma mark - Overridden Methods
- (void)configurePhysicsBody {
    // Configure the physics body property and set bitmasks for contact delegates; must override
    NSAssert(NO, @"Override configurePhysicsBody method");
}
- (void)collideWith:(SKPhysicsBody *)other {
    // Override if character will collide
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {
    // Override this one if the contact object is needed for joint/position attatchments
}


@end
