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
#import "ObjectAL.h"

#define BACKGROUND_MUSIC_FILE @"background.mp3"
#define HERO_BEEP @"dying_sound.mp3"
#define MESSAGE_FONT_COLOR [SKColor colorWithRed:211.0 / 255.0 green:92.0 / 255.0 blue:41.0 / 255.0 alpha:1.0];
#define MESSAGE_FONT_SIZE 22.0

@interface STSHeroRotationScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) STSHero *hero;
@property BOOL firstPulseRevealed;

//properites below are used for typing effect
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSMutableString *messageSoFar;
@property NSUInteger characterIndex;

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
        self.firstPulseRevealed = NO;
        [self addIntroText];
        [self addHero];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundToggle"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"musicToggle"];
    [[OALSimpleAudio sharedInstance] preloadBg:BACKGROUND_MUSIC_FILE];
    [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_FILE loop:YES];

    return self;
}

#pragma mark - Creating Sprites
static float PROJECTILE_VELOCITY = 200/1;

- (void)addHero {
    // initialize hero
    CGPoint position = CGPointMake(self.size.width / 2, self.size.height / 2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:position];
    self.hero = newHero;
    newHero.name = @"hero";
    SKSpriteNode *shadow = [newHero createShadow];
    shadow.name = @"HeroShadow";
    shadow.position = CGPointMake(CGRectGetMidX(self.frame) - 0.8, CGRectGetMidY(self.frame) + 1.0);
    [self addChild:shadow];
    [self addDeadHero];
    [self addChild:self.hero];
}
- (void)addDeadHero{
    // initialize deadHero
    SKSpriteNode *deadHero = [self.hero createDeadHero];
    deadHero.name = @"deadHero";
    deadHero.position = self.hero.position;
    deadHero.alpha = 0.5;
    [self addChild:deadHero];
}

- (void)addFirstPulse {
    // initialize first pulse
    self.firstPulseRevealed = YES;
    CGPoint position1 = CGPointMake(self.size.width / 2 + 75, 75);
    SKSpriteNode *pulse = [SKSpriteNode spriteNodeWithImageNamed:@"pulse.png"];
    pulse.name = @"firstPulse";
    pulse.position = position1;
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],
                                         [SKAction runBlock:^{[self addChild:pulse];}]]]];
    [pulse runAction:[self createPulsingAction]];
}

- (void)addSecondPulse {
    // initialize second pulse
    CGPoint position2 = CGPointMake(self.size.width / 2 - 75, 75);
    SKSpriteNode *pulse = [SKSpriteNode spriteNodeWithImageNamed:@"pulse.png"];
    pulse.name = @"secondPulse";
    pulse.position = position2;
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],
                                         [SKAction runBlock:^{[self addChild:pulse];}]]]];
    [pulse runAction:[self createPulsingAction]];
}

- (void)addVillain{
    // initialize villain
    CGPoint position = CGPointMake(self.size.width / 2, self.size.height + 20);
    STSVillain *newVillain = [[STSVillain alloc] initAtPosition:position];
    newVillain.name = @"Villain";
    [self addChild:newVillain];
    
    // create notificaiton for villain
    SKSpriteNode *newNotification =
            [newVillain createNotificationOnCircleWithCenter:self.hero.position positionNumber:90];
    [self addChild:newNotification];
    [self addExplainNotification];
}

#pragma mark - Creating text
- (void)addIntroText {
    SKLabelNode *heroIntroduction = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    heroIntroduction.fontColor = MESSAGE_FONT_COLOR;
    heroIntroduction.fontSize = MESSAGE_FONT_SIZE;
    heroIntroduction.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 100);
    heroIntroduction.name = @"heroIntroduction";
    [self addChild:heroIntroduction];
    [self typingEffectWithString:@"This is our friend, Ozone."
                        forLabel:heroIntroduction
                      completion:^{[self addTapRight];}];
}

- (void)addTapRight {
    SKLabelNode *tapRightMessage = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    tapRightMessage.fontColor = MESSAGE_FONT_COLOR
    tapRightMessage.fontSize = MESSAGE_FONT_SIZE;
    tapRightMessage.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 100);
    tapRightMessage.name = @"tapRightMessage";
    [self addChild:tapRightMessage];
    [self typingEffectWithString:@"Try Tapping the right side."
                        forLabel:tapRightMessage
                      completion:^{[self addFirstPulse];}];
}

- (void)addObserveMessage {
    SKLabelNode *observeMessage = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    observeMessage.fontColor = MESSAGE_FONT_COLOR;
    observeMessage.fontSize = MESSAGE_FONT_SIZE;
    observeMessage.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 100);
    observeMessage.name = @"observeMessage";
    [self addChild:observeMessage];
    [self typingEffectWithString:@"See how Ozone rotates?"
                        forLabel:observeMessage
                      completion:^{[self addTapLeft];}];
}

- (void)addTapLeft {
    SKLabelNode *tapLeftMessage = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    tapLeftMessage.fontColor = MESSAGE_FONT_COLOR;
    tapLeftMessage.fontSize = MESSAGE_FONT_SIZE;
    tapLeftMessage.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 100);
    tapLeftMessage.name = @"tapLeftMessage";
    [self addChild:tapLeftMessage];
    [self typingEffectWithString:@"Now try the left side."
                        forLabel:tapLeftMessage
                      completion:^{[self addSecondPulse];}];
}

- (void)addExplainNotification {
    SKLabelNode *explainNotification = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    explainNotification.fontColor = MESSAGE_FONT_COLOR;
    explainNotification.fontSize = MESSAGE_FONT_SIZE;
    explainNotification.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 100);
    explainNotification.name = @"explainNotification";
    [self addChild:explainNotification];
    [self typingEffectWithString:@"What's that notification?"
                        forLabel:explainNotification
                      completion:^{[self moveVillainIntoScreen];}];
}

- (void)addScreamRedDot {
    SKLabelNode *screamRedDot = [SKLabelNode labelNodeWithFontNamed:@"HelveticeNeue-Light"];
    screamRedDot.fontColor = MESSAGE_FONT_COLOR;
    screamRedDot.fontSize = MESSAGE_FONT_SIZE;
    screamRedDot.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 100);
    screamRedDot.name = @"screamRedDot";
    [self addChild:screamRedDot];
    [self typingEffectWithString:@"AAH! A RED DOT!"
                        forLabel:screamRedDot
                      completion:^{[self finishMovingVillain];}];
}

#pragma mark - Helper methods for creating sprites and text
- (SKAction *)createPulsingAction {
    // create sequence of actions used for pulsing effect
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

- (void)moveVillainIntoScreen {
    SKNode *villain = [self childNodeWithName:@"Villain"];
    float realMoveDuration = distanceFormula(self.hero.position,
                                             villain.position) / PROJECTILE_VELOCITY;
    // move villain to the center
    [villain runAction:[SKAction moveTo:CGPointMake(self.frame.size.width / 2, self.frame.size.height-100)
                                duration:realMoveDuration]
            completion:^{
                SKNode *explainNotification = [self childNodeWithName:@"explainNotification"];
                [explainNotification removeFromParent];
                [self addScreamRedDot];
            }];
}

- (void)finishMovingVillain {
    SKNode *villain = [self childNodeWithName:@"Villain"];
    float realMoveDuration = distanceFormula(self.hero.position,
                                             villain.position) / PROJECTILE_VELOCITY;
    // move villain to the center
    [villain runAction:[SKAction moveTo:self.hero.position duration:realMoveDuration]];
}

- (void)typingEffectWithString:(NSString *)message
                      forLabel:(SKLabelNode *)labelNode
                    completion:(dispatch_block_t)block
{
    // create actions to update label node with the message character by character
    self.message = message;
    self.messageSoFar = [[NSMutableString alloc] initWithCapacity:message.length];
    self.characterIndex = 0;
    SKAction *waitToType = [SKAction waitForDuration:1.0];
    SKAction *addChar = [SKAction runBlock:^(void){
        [self.messageSoFar appendFormat:@"%c", [self.message characterAtIndex:self.characterIndex]];
        self.characterIndex+=1;
    }];
    SKAction *waitToAddNextCharacter = [SKAction waitForDuration:0.08];
    SKAction *updateHeroInroductionText = [SKAction runBlock:^(void){
        NSString *temporaryString = [[NSString alloc] initWithString:self.messageSoFar];
        labelNode.text = temporaryString;}];
    SKAction *sequenceOfAddingCharacters = [SKAction sequence:@[addChar,
                                                                waitToAddNextCharacter,
                                                                updateHeroInroductionText]];
    SKAction *repeatMessageLength = [SKAction repeatAction:sequenceOfAddingCharacters
                                                     count:message.length];
    
    // run the sequence of actions and then run the completion block
    [self runAction:[SKAction sequence:@[waitToType, repeatMessageLength]] completion:block];
}

- (void)typingEffectWithString:(NSString *)message
                      forLabel:(SKLabelNode *)labelNode
{
    // create actions to update label node with the message character by character
    self.message = message;
    self.messageSoFar = [[NSMutableString alloc] initWithCapacity:message.length];
    self.characterIndex = 0;
    SKAction *waitToType = [SKAction waitForDuration:1.0];
    SKAction *addChar = [SKAction runBlock:^(void){
        [self.messageSoFar appendFormat:@"%c", [self.message characterAtIndex:self.characterIndex]];
        self.characterIndex+=1;
    }];
    SKAction *waitToAddNextCharacter = [SKAction waitForDuration:0.08];
    SKAction *updateHeroInroductionText = [SKAction runBlock:^(void){
        NSString *temporaryString = [[NSString alloc] initWithString:self.messageSoFar];
        labelNode.text = temporaryString;}];
    SKAction *sequenceOfAddingCharacters = [SKAction sequence:@[addChar,
                                                                waitToAddNextCharacter,
                                                                updateHeroInroductionText]];
    SKAction *repeatMessageLength = [SKAction repeatAction:sequenceOfAddingCharacters
                                                     count:message.length];
    
    // run the sequence of actions
    [self runAction:[SKAction sequence:@[waitToType, repeatMessageLength]]];
}

static inline float distanceFormula(CGPoint a, CGPoint b) {
    return sqrtf(powf(a.x-b.x, 2)+powf(a.y-b.y, 2));
}

#pragma mark - contact logic
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    // logic for adding one pulse at a time
    if ([node.name isEqualToString:@"firstPulse"] || [node.name isEqualToString:@"secondPulse"]) {
        STSShield *pulseNode = (STSShield *)node;
        if ([node.name isEqualToString:@"firstPulse"]){
            SKNode *heroIntroduction = [self childNodeWithName:@"heroIntroduction"];
            SKNode *tapRightMessage = [self childNodeWithName:@"tapRightMessage"];
            [heroIntroduction removeFromParent];
            [tapRightMessage removeFromParent];
            [pulseNode runAction:[SKAction removeFromParent]];
            [self addObserveMessage];
        }
        if ([node.name isEqualToString:@"secondPulse"]){
            SKNode *observeMessage = [self childNodeWithName:@"observeMessage"];
            SKNode *tapLeftMessage = [self childNodeWithName:@"tapLeftMessage"];
            [observeMessage removeFromParent];
            [tapLeftMessage removeFromParent];
            [pulseNode runAction:[SKAction removeFromParent]];
            [self addVillain];
        }
    }
    
    if (self.firstPulseRevealed){
        [self.hero rotate:location];
    }
}

#pragma mark - transition logic
- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKNode *first, *second;
    first = contact.bodyA.node;
    second = contact.bodyB.node;
    
    // logic to make the notification disappear
    if (first.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [first removeFromParent];
    } else if (second.physicsBody.categoryBitMask == STSColliderTypeNotification) {
        [second removeFromParent];
    } else {
        //logic to kill hero on contact with villain. second should always be the villain
        [second removeFromParent];
        [self removeAllActions];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundToggle"]) {
            [[OALSimpleAudio sharedInstance] playEffect:HERO_BEEP];
            [self gameOver];
        } else {
            [self gameOver];
        }
    }
}

/* Animation to make all villains and shields from appearing and make heroes current shields fly out
 Hero then bounces up, then quickly down in order to transition into GameOverScene */
- (void)gameOver {
    SKNode *screamRedDot = [self childNodeWithName:@"screamRedDot"];
    [screamRedDot removeFromParent];
    CGPoint middle = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    SKAction *waitDuration = [SKAction waitForDuration:0.2];
    SKAction *waitAfter = [SKAction waitForDuration:0.3];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.1];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.1];
    SKAction *bounceUp = [SKAction moveByX:0.0 y:10.0 duration:0.5];
    SKAction *bounceDown = [SKAction moveByX:0.0 y:-500.0 duration:0.2];
    SKAction *bounceSequence =[SKAction sequence:@[waitDuration, bounceUp, bounceDown, waitAfter]];
    
    SKSpriteNode *deadHero = (SKSpriteNode *)[self childNodeWithName:@"deadHero"];
    deadHero.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    SKSpriteNode *shadow = (SKSpriteNode *)[self childNodeWithName:@"HeroShadow"];
    deadHero.zRotation = self.hero.zRotation;
    
    // Create gray background for smoother transition
    SKColor *transitionToShieldSceneBackgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                                                      green:241.0 / 255.0
                                                                       blue:238.0 / 255.0
                                                                      alpha:1.0];
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:transitionToShieldSceneBackgroundColor
                                                              size:self.size];
    background.position = middle;
    background.alpha = 0.0;
    [self addChild:background];
    SKAction *fadeBackgroundIn = [SKAction fadeAlphaTo:1.0 duration:1.0];
    SKAction *backgroundWait = [SKAction waitForDuration:1.4];
    SKAction *backgroundSequence = [SKAction sequence:@[backgroundWait, fadeBackgroundIn]];

    [deadHero runAction:fadeIn];
    [deadHero runAction:bounceSequence];
    [shadow runAction:bounceSequence];
    [shadow runAction:fadeOut];
    [self.hero runAction:fadeOut];
    [self.hero runAction:bounceSequence];
    [background runAction:backgroundSequence completion:^{
        SKTransition *fade = [SKTransition fadeWithColor:transitionToShieldSceneBackgroundColor
                                                duration:0.5];
        STSTransitionToShieldScene *newTransitionToShieldScene = [[STSTransitionToShieldScene alloc]
                                                                        initWithSize:self.size];
        [self.view presentScene:newTransitionToShieldScene transition:fade];
    }];
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
