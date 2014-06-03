//
//  STSPauseScene.h
//  CircleSecondIteration
//
//  Created by John Lee on 6/2/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSCharacter.h"
#import "STSEndlessGameScene.h"

@interface STSPauseScene : SKScene

@property (strong, nonatomic) STSEndlessGameScene *previousScene;

- (id)initWithSize:(CGSize)size;

@end
