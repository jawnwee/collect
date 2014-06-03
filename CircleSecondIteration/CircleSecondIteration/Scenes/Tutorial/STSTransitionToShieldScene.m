//
//  STSTransitionToShieldScene.m
//  Ozone!
//
//  Created by Yujun Cho on 6/2/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSTransitionToShieldScene.h"

@implementation STSTransitionToShieldScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.backgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                               green:241.0 / 255.0
                                                blue:238.0 / 255.0
                                               alpha:1.0];
        [self addText];
    }

    return self;
}

- (void)addText {

    // Use a for loop loooool
    SKNode *text = [SKNode node];

    SKLabelNode *ohNo = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    ohNo.alpha = 0;
    ohNo.fontColor = [SKColor blackColor];
    ohNo.text = @"Oh no!";
    ohNo.fontSize = 32.0;
    ohNo.name = @"textNode";
    ohNo.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 100);
    [self addChild:ohNo];

    SKLabelNode *thatLooked = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    thatLooked.alpha = 0;
    thatLooked.fontColor = [SKColor blackColor];
    thatLooked.text = @"That looked";
    thatLooked.fontSize = 32.0;
    thatLooked.name = @"textNode";
//    thatLooked.position = CGPointMake(ohNo.position.x, ohNo.position.y - 50);
    thatLooked.position = ohNo.position;
    [self addChild:thatLooked];

    SKLabelNode *painful = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    painful.alpha = 0;
    painful.fontColor = [SKColor blackColor];
    painful.text = @"painful :(!";
    painful.fontSize = 32.0;
    painful.name = @"textNode";
//    painful.position = CGPointMake(thatLooked.position.x, thatLooked.position.y - 50);
    painful.position = ohNo.position;
    [self addChild:painful];

    SKLabelNode *letsGet = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    letsGet.alpha = 0;
    letsGet.fontColor = [SKColor blackColor];
    letsGet.text = @"Let's get";
    letsGet.fontSize = 32.0;
    letsGet.name = @"textNode";
//    letsGet.position = CGPointMake(painful.position.x, painful.position.y - 50);
    letsGet.position = ohNo.position;
    [self addChild:letsGet];

    SKLabelNode *someShields = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    someShields.alpha = 0;
    someShields.fontColor = [SKColor blackColor];
    someShields.text = @"some shields!";
    someShields.fontSize = 32.0;
    someShields.name = @"textNode";
//    someShields.position = CGPointMake(letsGet.position.x, letsGet.position.y - 50);
    someShields.position = ohNo.position;
    [self addChild:someShields];


    // Insert one more completion at the end to present the next scene.
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.75];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.75];
    SKAction *fadeInFadeOut = [SKAction sequence:@[fadeIn, fadeOut]];
    [ohNo runAction:fadeInFadeOut completion:^{
        [thatLooked runAction:fadeInFadeOut completion:^{
            [painful runAction:fadeInFadeOut completion:^{
                [letsGet runAction:fadeInFadeOut completion:^{
                    [someShields runAction:fadeInFadeOut];
                }];
            }];
        }];
    }];

//    [self enumerateChildNodesWithName:@"textNode" usingBlock:^(SKNode *node, BOOL *stop) {
//        SKAction *fadeIn = [SKAction fadeInWithDuration:1];
//        [node runAction:fadeIn];
//    }];


}

@end
