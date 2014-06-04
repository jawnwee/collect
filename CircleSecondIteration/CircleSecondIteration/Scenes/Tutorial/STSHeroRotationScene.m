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
#import "STSVillain.h"

@interface STSHeroRotationScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) STSHero *hero;

@end

@implementation STSHeroRotationScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.backgroundColor = [SKColor colorWithRed:245.0 / 255.0
                                               green:144.0 / 255.0
                                                blue:68.0 / 255.0
                                               alpha:1.0];
        self.physicsWorld.contactDelegate = self;
        [self addIntroductionText];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tutorialFinished"];
    }

    return self;
}

#pragma mark - Creating Sprites
static float PROJECTILE_VELOCITY = 200/1;

- (void)addHero {
    //initialize hero
    CGPoint position = CGPointMake(self.size.width / 2, self.size.height / 2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:position];
    newHero.name = @"hero";
    SKSpriteNode *shadow = [newHero createShadow];
    shadow.name = @"HeroShadow";
    shadow.position = CGPointMake(newHero.position.x - 0.8, newHero.position.y + 1);
    self.hero = newHero;
    [self addChild:shadow];
    [self addChild:newHero];
    
    //add first pulse after some duration
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *addFirstPulse = [SKAction runBlock:^(void){[self addFirstPulse];}];
    [self.hero runAction:[SKAction sequence:@[wait, addFirstPulse]]];

}

- (void)addFirstPulse {
    //initialize first pulse
    CGPoint position1 = CGPointMake(self.size.width / 2 + 75, 75);
    SKSpriteNode *pulse = [SKSpriteNode spriteNodeWithImageNamed:@"pulse.png"];
    pulse.name = @"firstPulse";
    pulse.position = position1;
    [self addChild:pulse];
    [pulse runAction:[self createPulsingAction]];
}

- (void)addSecondPulse {
    //initialize second pulse
    CGPoint position2 = CGPointMake(self.size.width / 2 - 75, 75);
    SKSpriteNode *pulse = [SKSpriteNode spriteNodeWithImageNamed:@"pulse.png"];
    pulse.name = @"secondPulse";
    pulse.position = position2;
    [self addChild:pulse];
    [pulse runAction:[self createPulsingAction]];
}

- (void)addIntroductionText {
    //initialize introduction text
    SKLabelNode *heroIntroduction = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    heroIntroduction.fontColor = [SKColor blackColor];
    heroIntroduction.fontSize = 36.0;
    heroIntroduction.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 100);
    heroIntroduction.text = @"This is Ozone";
    [self addChild:heroIntroduction];
    
    //remove introduction text and add hero after some duration
    SKAction *wait = [SKAction waitForDuration:1.5];
    SKAction *addHero = [SKAction runBlock:^(void){[self addHero];}];
    SKAction *blockAddHeroAndWait = [SKAction group:@[wait, addHero]];
    SKAction *removeIntroduction = [SKAction removeFromParent];
    [heroIntroduction runAction:[SKAction sequence:@[blockAddHeroAndWait,
                                                     removeIntroduction]]];
}

- (void)addVillain{
    //initialize villain
    CGPoint position = CGPointMake(self.size.width / 2, self.size.height + 20);
    STSVillain *newVillain = [[STSVillain alloc] initAtPosition:position];
    [self addChild:newVillain];
    float realMoveDuration = distanceFormula(self.hero.position,
                                             newVillain.position) / PROJECTILE_VELOCITY;
    
    //create notificaiton for villain
    SKSpriteNode *newNotification =
            [newVillain createNotificationOnCircleWithCenter:self.hero.position positionNumber:90];
    [self addChild:newNotification];
    
    //move villain to the center
    [newVillain runAction:[SKAction sequence:@[[SKAction waitForDuration: 0.75],
                                [SKAction moveTo:self.hero.position duration:realMoveDuration]]]];
}

- (void)addDeadHero{
    //initialize deadHero
    SKSpriteNode *deadHero = [self.hero createDeadHero];
    deadHero.position = self.hero.position;
    deadHero.alpha = 0.0;
    deadHero.zRotation = self.hero.zRotation;
    [self addChild:deadHero];
    
    //Actions used to create the effect of dying hero
    self.hero.physicsBody.dynamic = NO;
    SKAction *waitDuration = [SKAction waitForDuration:0.7];
    SKAction *waitAfter = [SKAction waitForDuration:0.3];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.1];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.1];
    SKAction *bounceUp = [SKAction moveByX:0.0 y:10.0 duration:0.5];
    SKAction *bounceDown = [SKAction moveByX:0.0 y:-500.0 duration:0.2];
    SKAction *bounceSequence =[SKAction sequence:@[waitDuration, bounceUp, bounceDown, waitAfter]];

    //run actions and change scenes
    SKSpriteNode *shadow = (SKSpriteNode *)[self childNodeWithName:@"HeroShadow"];
    [deadHero runAction:fadeIn];
    [deadHero runAction:bounceSequence];
    [shadow runAction:bounceSequence];
    [shadow runAction:fadeOut];
    [self.physicsWorld removeAllJoints];
    [self.hero runAction:fadeOut];
    [self.hero runAction:bounceSequence completion:^{
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.3];
        STSTransitionToShieldScene *newTransitionToShieldScene = [[STSTransitionToShieldScene alloc]
                                                                  initWithSize:self.size];
        [self.view presentScene:newTransitionToShieldScene transition:reveal];
    }];
}

#pragma mark - Helper methods for creating sprites
- (SKAction *)createPulsingAction {
    //create sequence of actions used for pulsing effect
    SKAction *fadeIn = [SKAction fadeInWithDuration:0];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1];
    SKAction *scaleUp = [SKAction scaleBy:4 duration:1];
    SKAction *scaleDown = [SKAction scaleBy:0.25 duration:0];
    SKAction *fadeInScaleDown = [SKAction group:@[fadeIn, scaleDown]];
    SKAction *fadeOutScaleUp = [SKAction group:@[fadeOut, scaleUp]];
    SKAction *pulse = [SKAction sequence:@[fadeOutScaleUp, fadeInScaleDown]];
    SKAction *pulseForever = [SKAction repeatActionForever:pulse];
    
    return pulseForever;
}

static inline float distanceFormula(CGPoint a, CGPoint b) {
    return sqrtf(powf(a.x-b.x, 2)+powf(a.y-b.y, 2));
}

#pragma mark - transitions and contact logic
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    //logic for adding one pulse at a time
    if ([node.name isEqualToString:@"firstPulse"] || [node.name isEqualToString:@"secondPulse"]) {
        STSShield *pulseNode = (STSShield *)node;
        if ([node.name isEqualToString:@"firstPulse"]){
            [pulseNode runAction:[SKAction removeFromParent]];
            [self addSecondPulse];
        }
        if ([node.name isEqualToString:@"secondPulse"]){
            [pulseNode runAction:[SKAction removeFromParent]];
            [self addVillain];
        }
    }
    [self.hero rotate:location];
}

- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKNode *first, *second;
    first = contact.bodyA.node;
    second = contact.bodyB.node;
    
    //logic to make the notification disappear
    if (first.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [first removeFromParent];
    } else if (second.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [second removeFromParent];
    } else {
        //logic to kill hero on contact with villain. second should always be the villain
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundToggle"]) {
            [self runAction:[SKAction playSoundFileNamed:@"herobeep.caf" waitForCompletion:NO]
                 completion:^{
                     [second removeFromParent];
                     [self removeAllActions];
                     [self addDeadHero];
                 }];
        } else {
            [second removeFromParent];
            [self removeAllActions];
            [self addDeadHero];
        }
    }
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
