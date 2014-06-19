//
//  STSGameScene.h
//  Ozone!
//
//  Created by John Lee on 6/19/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface STSGameScene : SKScene

- (void)addPauseButton;
- (void)addRestartButton;
- (void)addHero;
- (void)addVillain;
- (void)addShield;
- (void)createNInitialShield:(uint)nShields;
- (void)didMoveToView:(SKView *)view;
- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)handleLongPress:(UIGestureRecognizer *)recognizer;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)gameOver;
- (void)update:(CFTimeInterval)currentTime;

@end
