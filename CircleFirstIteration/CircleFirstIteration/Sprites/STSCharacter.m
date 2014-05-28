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
    [self configurePhysicsBody];
    return self;
}

#pragma mark - Overridden Methods

- (void)configurePhysicsBody {
   // Configure the physics body property and set bitmask properties; override
   NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void)collideWith:(SKPhysicsBody *)other contactAt:(SKPhysicsContact *)contact {
    // Handle a collision with another character; override this
    NSAssert(NO, @"This is an abstract method and should be overridden");

}


@end
