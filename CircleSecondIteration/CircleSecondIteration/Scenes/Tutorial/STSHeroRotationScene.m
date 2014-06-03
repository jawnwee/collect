//
//  STSHeroRotationScene.m
//  Ozone!
//
//  Created by Yujun Cho on 6/2/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSHeroRotationScene.h"
#import "STSTransitionToShieldScene.h"
#import "STSShield.h"
#import "STSHero.h"

@implementation STSHeroRotationScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.backgroundColor = [SKColor colorWithRed:245.0 / 255.0
                                               green:144.0 / 255.0
                                                blue:68.0 / 255.0
                                               alpha:1.0];
        [self addPulses];
        [self addHero];
    }

    return self;
}

- (void)addHero {
    CGPoint position = CGPointMake(self.size.width / 2, self.size.height / 2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:position];
    newHero.name = @"hero";
    SKSpriteNode *shadow = [newHero createShadow];
    shadow.position = CGPointMake(newHero.position.x - 0.8, newHero.position.y + 1);
    [self addChild:shadow];
    [self addChild:newHero];
}

- (STSHero *)getHero {
    return (STSHero *)[self childNodeWithName:@"hero"];
}

- (void)addPulses {
    CGPoint position1 = CGPointMake(self.size.width / 2 + 75, self.size.height / 2 - 175);
    STSShield *newShield1 = [[STSShield alloc] initAtPosition:position1];
    newShield1.name = @"leftPulse";
    [self addChild:newShield1];

    CGPoint position2 = CGPointMake(self.size.width / 2 - 75, self.size.height / 2 - 175);
    STSShield *newShield2 = [[STSShield alloc] initAtPosition:position2];
    newShield2.name = @"rightPulse";
    [self addChild:newShield2];

    SKAction *fadeIn = [SKAction fadeInWithDuration:0];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1];
    SKAction *scaleUp = [SKAction scaleBy:4 duration:1];
    SKAction *scaleDown = [SKAction scaleBy:0.25 duration:0];
    SKAction *fadeInScaleDown = [SKAction group:@[fadeIn, scaleDown]];
    SKAction *fadeOutScaleUp = [SKAction group:@[fadeOut, scaleUp]];
    SKAction *pulse = [SKAction sequence:@[fadeOutScaleUp, fadeInScaleDown]];

    SKAction *pulseForever = [SKAction repeatActionForever:pulse];

    [newShield1 runAction:pulseForever];
    [newShield2 runAction:pulseForever];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    SKNode *node = [self nodeAtPoint:location];

    [[self getHero] rotate:location];

    STSTransitionToShieldScene *newTransitionToShieldScene = [[STSTransitionToShieldScene alloc]
                                                              initWithSize:self.size];
    [self.view presentScene:newTransitionToShieldScene];


}

#pragma mark - Pause Logic
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // If the scene is currently paused, change it to unpaused
    if (self.paused) {
        self.paused = !self.paused;
    }
}

@end
