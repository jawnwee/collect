//
//  STSObtainShieldScene.m
//  Ozone!
//
//  Created by Yujun Cho on 6/2/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSObtainShieldScene.h"
#import "STSHero.h"
#import "STSShield.h"
#import "STSTransitionToEndlessGameScene.h"

@interface STSObtainShieldScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) STSHero *hero;
@property int positionCount;
@property BOOL partialShieldObtained;
@property BOOL didCompleteShield;
@property BOOL pulsesAdded;
@property BOOL messageAdded;

//properites below are used for typing effect
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSMutableString *messageSoFar;
@property NSUInteger characterIndex;

@end

#define MESSAGE_FONT_COLOR [SKColor colorWithRed:211.0 / 255.0 green:92.0 / 255.0 blue:41.0 / 255.0 alpha:1.0];
#define MESSAGE_FONT_SIZE 22.0

@implementation STSObtainShieldScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.backgroundColor = [SKColor colorWithRed:245.0 / 255.0
                                               green:144.0 / 255.0
                                                blue:68.0 / 255.0
                                               alpha:1.0];
        self.physicsWorld.contactDelegate = self;
        self.positionCount = 0;
        self.partialShieldObtained = NO;
        self.didCompleteShield = NO;
        self.pulsesAdded = NO;
        self.messageAdded = NO;
        
        //create hero with empty shields
        [self addHero];
        [self createNInitialShield:20];
        
        //throws 16 shields at the hero
        SKAction *makeShieldsInOrder = [SKAction sequence:@[
                                            [SKAction performSelector:@selector(addShieldInOrder)
                                                             onTarget:self],
                                            [SKAction waitForDuration:0.3]]];
        
        [self runAction:[SKAction repeatAction:makeShieldsInOrder count:16]];
    }
    
    return self;
}

#pragma mark - Creating Sprites
static float PROJECTILE_VELOCITY = 200/1;

- (void)addHero{
    //initialize and add the hero with shadow
    CGPoint position = CGPointMake(self.size.width / 2, self.size.height / 2);
    STSHero *newHero = [[STSHero alloc] initAtPosition:position];
    newHero.name = @"hero";
    SKSpriteNode *shadow = [newHero createShadow];
    shadow.name = @"HeroShadow";
    shadow.position = CGPointMake(CGRectGetMidX(self.frame) - 0.8, CGRectGetMidY(self.frame) + 1.0);
    self.hero = newHero;
    [self addChild:shadow];
    [self addChild:newHero];
    
    self.hero.alpha = 0.0;
    shadow.alpha = 0.0;
    SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];
    
    [self.hero runAction:fadeIn];
    [shadow runAction:fadeIn];
}

- (void)addRandomShield {
    //only create random shields from the top half of the screen so
    //it's easier to complete the shield
    int randomPositionNumber = arc4random_uniform(90)+45;
    CGPoint position = [self createPositionOutsideFrameArrayAtPositionNumber:randomPositionNumber];
    STSShield *newShield = [[STSShield alloc] initAtPosition:position];
    newShield.name = @"Shield";
    [self addChild:newShield];
    
    float realMoveDuration = distanceFormula(self.hero.position,
                                             newShield.position) / PROJECTILE_VELOCITY;
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:realMoveDuration];
    [newShield runAction:moveToHero];
}

- (void)addShieldInOrder {
    float incrementor = 360 / 20;
    CGPoint position = [self createPositionOutsideFrameArrayAtPositionNumber:incrementor*self.positionCount];
    
    //skip every other shield for cool effect and player has to
    //fill every other gap rather than one huge gap
    if (self.positionCount > 10) {
        self.positionCount += 2;
    } else {
        self.positionCount++;
    }
    
    //initialize and add new shield
    STSShield *newShield = [[STSShield alloc] initAtPosition:position];
    newShield.name = @"Shield";
    [self addChild:newShield];
    
    //create and run movement for the new shield
    float realMoveDuration = distanceFormula(self.hero.position,
                                             newShield.position) / PROJECTILE_VELOCITY;
    SKAction *moveToHero = [SKAction moveTo:self.hero.position duration:realMoveDuration];
    [newShield runAction:moveToHero];
}

- (void)createNInitialShield:(uint)nShields {
    //variables used to find the correct coordinates for each shield
    float incrementor = 360 / nShields;
    float nthPointInCircle = 0;
    for (uint i = 0; i < nShields; i++) {
        
        //find the correct coordinate for initial position and then
        //initialize the new shield
        CGPoint coordinates = findCoordinatesAlongACircle(self.hero.position,
                                                          self.hero.physicsBodyRadius + 32.0,
                                                          nthPointInCircle);
        STSShield *newShield = [[STSShield alloc] initAtPosition:coordinates];
        newShield.name = @"HeroShield";
        newShield.isPartOfBarrier = YES;
        
        //these names are used in completedShields
        if ((i == 12) || (i == 14) || (i == 16) || (i == 18)) {
            newShield.name = [NSString stringWithFormat:@"shield%d", i];
        }
        
        //set upt this way so the initial shield appears empty
        newShield.texture = nil;
        newShield.shieldUp = NO;
        [self addChild:newShield];
        
        //add a joint so the shields rotate with the hero
        SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:newShield.physicsBody
                                                                   bodyB:self.hero.physicsBody
                                                                  anchor:coordinates];
        [self.physicsWorld addJoint:joint];
        nthPointInCircle += incrementor;
    }
}

- (void)addPulses {
    self.pulsesAdded = YES;
    // initialize first pulse
    CGPoint position1 = CGPointMake(self.size.width / 2 + 75, 75);
    SKSpriteNode *pulse = [SKSpriteNode spriteNodeWithImageNamed:@"pulse.png"];
    pulse.name = @"firstPulse";
    pulse.position = position1;
    [pulse runAction:[self createPulsingAction]];
    [self addChild:pulse];
    
    // initialize second pulse
    CGPoint position2 = CGPointMake(self.size.width / 2 - 75, 75);
    SKSpriteNode *pulse2 = [SKSpriteNode spriteNodeWithImageNamed:@"pulse.png"];
    pulse2.name = @"secondPulse";
    pulse2.position = position2;
    [pulse2 runAction:[self createPulsingAction]];
    [self runAction:[SKAction waitForDuration:0.5] completion:^{[self addChild:pulse2];}];
}

#pragma mark - Helper Functions for creating Sprites
static inline float distanceFormula(CGPoint a, CGPoint b) {
    return sqrtf(powf(a.x-b.x, 2)+powf(a.y-b.y, 2));
}

static inline CGPoint findCoordinatesAlongACircle(CGPoint center, uint radius, uint n) {
    return CGPointMake(center.x + (radius * cosf(n * (M_PI / 180))),
                       center.y + (radius * sinf(n * (M_PI / 180))));
}

- (CGPoint)createPositionOutsideFrameArrayAtPositionNumber:(int) n {
    CGPoint frameCenter = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return findCoordinatesAlongACircle(frameCenter, 400, n);
}

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

/* This is to determine when to add the pulses */
- (BOOL)partialShieldCompleted{
    int count = 0;
    for (STSShield* node in self.children){
        if ([node.name isEqualToString:@"HeroShield"] && node.shieldUp) {
            count++;
        }
    }
    if (count == 16) {
        self.partialShieldObtained = YES;
        return TRUE;
    } else {
        return FALSE;
    }
}

#pragma mark - touch logic
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //logic to start rotating hero only once the pulses are added
    if (self.pulsesAdded && !self.didCompleteShield) {
        [self.hero rotate:location];
    }
}

#pragma mark - contact logic
- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKNode *first, *second;
    first = contact.bodyA.node;
    second = contact.bodyB.node;
    
    //this should be the only kind of contact that occurs
    if ([first isKindOfClass:[STSShield class]] &&
        [second isKindOfClass:[STSShield class]]) {
        [(STSCharacter *)first collideWith:contact.bodyB contactAt:contact];
    }
}


#pragma mark - message logic
- (void)addCompleteShield {
    self.messageAdded = YES;
    SKLabelNode *completeShield = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    completeShield.fontColor = MESSAGE_FONT_COLOR
    completeShield.fontSize = MESSAGE_FONT_SIZE;
    completeShield.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 120);
    completeShield.name = @"completeShield";
    [self addChild:completeShield];
    [self typingEffectWithString:@"Try filling the rest of the shield."
                        forLabel:completeShield
                      completion:^{[self addPulses];}];
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

#pragma mark - transition
//Used to determine if the player completed the shield
- (BOOL)completedShields{
    STSShield *twelve = (STSShield *)[self childNodeWithName:@"shield12"];
    STSShield *fourteen = (STSShield *)[self childNodeWithName:@"shield14"];
    STSShield *sixteen = (STSShield *)[self childNodeWithName:@"shield16"];
    STSShield *eighteen = (STSShield *)[self childNodeWithName:@"shield18"];
    
    if (twelve.shieldUp && fourteen.shieldUp && sixteen.shieldUp && eighteen.shieldUp) {
        self.didCompleteShield = YES;
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)update:(NSTimeInterval)currentTime{
    if ([self partialShieldCompleted] && !self.messageAdded) {
        // start making extra shields for player to fill in the gap
        SKAction *makeRandomShields = [SKAction repeatActionForever:
                                       [SKAction sequence:@[
                                                            [SKAction performSelector:@selector(addRandomShield)
                                                                             onTarget:self],
                                                            [SKAction waitForDuration:1.0 withRange:0.5]]]];
        [self runAction:[SKAction sequence:@[makeRandomShields]]];
        [self addCompleteShield];
    }
    
    //logic to transition scenes if  the shield is completed
    if ([self completedShields]) {
        [self removeAllActions];
        [[self childNodeWithName:@"firstPulse"] removeFromParent];
        [[self childNodeWithName:@"secondPulse"] removeFromParent];
        [[self childNodeWithName:@"completeShield"] removeFromParent];
        
        for (SKSpriteNode *node in self.children) {
            if ([node.name isEqualToString:@"HeroShield"] ||
                [node.name isEqualToString:@"shield12"] || [node.name isEqualToString:@"shield14"] ||
                [node.name isEqualToString:@"shield16"] || [node.name isEqualToString:@"shield18"]) {
                [node runAction:[SKAction fadeOutWithDuration:0.5]];
            } else if ([node.name isEqualToString:@"Shield"]) {
                [node removeFromParent];
            }
        }
        SKSpriteNode *shadow = (SKSpriteNode *)[self childNodeWithName:@"HeroShadow"];

        [shadow runAction:[SKAction fadeOutWithDuration:0.5]];
        [self.hero runAction:[SKAction fadeOutWithDuration:0.5] completion:^(void){
            CGPoint middle = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            SKColor *transitionToGameSceneBackgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                                                            green:241.0 / 255.0
                                                                             blue:238.0 / 255.0
                                                                            alpha:1.0];
            SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:transitionToGameSceneBackgroundColor
                                                                      size:self.size];
            background.position = middle;
            background.alpha = 0.0;
            [self addChild:background];
            SKAction *fadeBackgroundIn = [SKAction fadeAlphaTo:1.0 duration:0.5];
            SKAction *backgroundWait = [SKAction waitForDuration:0.25];
            SKAction *backgroundSequence = [SKAction sequence:@[backgroundWait, fadeBackgroundIn]];
            [background runAction:backgroundSequence completion:^{
                SKTransition *fade = [SKTransition fadeWithColor:transitionToGameSceneBackgroundColor duration:0.3];
                [self removeAllActions];
                [self removeAllChildren];
                self.hero = nil;
                STSTransitionToEndlessGameScene *newTransitionToEndlessGameScene = [[STSTransitionToEndlessGameScene alloc]
                                                                                    initWithSize:self.size];
                [self.view presentScene:newTransitionToEndlessGameScene transition:fade];
            }];
        }];
    }
}

@end
