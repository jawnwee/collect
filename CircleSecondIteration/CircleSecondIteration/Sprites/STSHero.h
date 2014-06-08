//
//  STSHero.h
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSCharacter.h"

@interface STSHero : STSCharacter

@property float physicsBodyRadius;

- (id)initAtPosition:(CGPoint)position;

- (SKSpriteNode *)createShadow;

- (SKSpriteNode *)createDeadHero;

- (void)rotate:(CGPoint)location;

- (void)rotateTimeGameMode:(CGPoint)location;

@end
