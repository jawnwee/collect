//
//  STSEndlessGameScene.h
//  CircleSecondIteration
//
//  Created by John Lee on 5/27/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "STSWelcomeScene.h"

@interface STSEndlessGameScene : SKScene

@property (strong, nonatomic) STSWelcomeScene *previousScene;
@property (nonatomic, readwrite) int score;


@end
