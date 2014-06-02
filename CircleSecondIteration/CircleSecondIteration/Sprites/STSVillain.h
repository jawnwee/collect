//
//  STSVillain.h
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSCharacter.h"

@interface STSVillain : STSCharacter

@property BOOL hasBeenCollided;

- (id)initAtPosition:(CGPoint)position;

- (SKSpriteNode *)createNotificationOnCircleWithCenter:(CGPoint)center positionNumber:(float)n;

//- (SKSpriteNode *)showWarning:(CGPoint)originalPos padding:(float)padding side:(int)side;

@end
