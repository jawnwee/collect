//
//  STSGameOverScene.m
//  CircleSecondIteration
//
//  Created by Matthew Chiang on 5/28/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSGameOverScene.h"
#import "STSEndlessGameScene.h"
#import "STSWelcomeScene.h"
#import "ObjectAL.h"
#import "ALInterstitialAd.h"
#import "ALAdview.h"
#import "Social/Social.h"
#import "GAIDictionaryBuilder.h"

#define BACKGROUND_MUSIC_FILE @"background.mp3"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface STSGameOverScene () <ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *highScoreLabel;
@property (nonatomic) NSString *scoreString;
@property (nonatomic) NSString *highScoreString;

@property (nonatomic) SKSpriteNode *deadOzone;

@end


@implementation STSGameOverScene


#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"GameOverScene"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];

        self.backgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                               green:241.0 / 255.0
                                                blue:238.0 / 255.0
                                               alpha:1.0];
        // [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self createSceneContents];
        [ALInterstitialAd shared].adLoadDelegate = self;
        [ALInterstitialAd shared].adDisplayDelegate = self;
    }
    return self;
}

- (void)createSceneContents {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"GameOverSymbols"];
    SKTexture *deadOzoneTexture = [atlas textureNamed:@"Dead_Ozone.png"];
    self.deadOzone = [SKSpriteNode spriteNodeWithTexture:deadOzoneTexture];
    self.deadOzone.position = CGPointMake(self.scene.size.width / 2.0, -1000.0);

    SKAction *bounceUp, *adjustBounce;
    if (IS_WIDESCREEN) {
        bounceUp = [SKAction moveByX:0.0 y:1000.0 duration:0.8];
        adjustBounce = [SKAction moveByX:0.0 y:-40.0 duration:0.5];
    } else {
        bounceUp = [SKAction moveByX:0.0 y:950.0 duration:0.8];
        adjustBounce = [SKAction moveByX:0.0 y:-40.0 duration:0.5];
    }
    [self addChild:self.deadOzone];
    SKAction *sequence = [SKAction sequence:@[bounceUp, adjustBounce]];
    [self.deadOzone runAction: sequence completion:^(void){[self addShareButtons];}];
    [self addDividers];
    [self addGameOverNode];
    [self addRetrySymbol];
    [self addMenuSymbol];
}

- (void)didMoveToView:(SKView *)view {
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    self.highScoreString = [NSString stringWithFormat:@"%ld", (long)highScore];
    self.scoreString = [self.userData valueForKey:@"scoreString"];

    [self addScoreLabel];
    [self addHighScoreLabel];
}

# pragma mark - Add nodes

- (void)addGameOverNode {
    SKSpriteNode *gameOverTitle = [SKSpriteNode spriteNodeWithImageNamed:@"GameOverTitle.png"];
    if (IS_WIDESCREEN) {
        gameOverTitle.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame) + 230.0);
    } else {
        gameOverTitle.position = CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame) + 190.0);
    }
    [self addChild:gameOverTitle];
}

- (void)addScoreLabel {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"GameOverSymbols"];
    SKTexture *scoreTexture = [atlas textureNamed:@"Last_Score.png"];
    SKSpriteNode *lastButton = [SKSpriteNode spriteNodeWithTexture:scoreTexture];

    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.scoreLabel.text = self.scoreString;
    self.scoreLabel.fontSize = 66.0;
    self.scoreLabel.fontColor = [SKColor colorWithRed:98.0 / 255.0 
                                                green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];

    if (IS_WIDESCREEN) {
        lastButton.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                          CGRectGetMidY(self.frame) + 180.0);
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                               CGRectGetMidY(self.frame) + 100.0);
    } else {
        lastButton.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                          CGRectGetMidY(self.frame) + 140.0);
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                               CGRectGetMidY(self.frame) + 70.0);
    }

    [self addChild:lastButton];
    [self addChild:self.scoreLabel];
}

- (void)addHighScoreLabel {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"GameOverSymbols"];
    SKTexture *scoreTexture = [atlas textureNamed:@"Best_Score.png"];
    SKSpriteNode *bestButton = [SKSpriteNode spriteNodeWithTexture:scoreTexture];

    self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.highScoreLabel.text = self.highScoreString;
    self.highScoreLabel.fontSize = 66.0;
    self.highScoreLabel.fontColor = [SKColor colorWithRed:98.0 / 255.0 
                                                    green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];

    if (IS_WIDESCREEN) {
        bestButton.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) + 180.0);
        self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                               CGRectGetMidY(self.frame) + 100.0);
    } else {
        bestButton.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) + 140.0);
        self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                               CGRectGetMidY(self.frame) + 70.0);
    }

    [self addChild:bestButton];
    [self addChild:self.highScoreLabel];
}

- (void)addRetrySymbol {
    SKTexture *retryTexture = [SKTexture textureWithImageNamed:@"RetrySymbol.png"];
    SKSpriteNode *retrySymbol = [[SKSpriteNode alloc] initWithTexture:retryTexture];
    retrySymbol.name = @"retrySymbol";
    if (IS_WIDESCREEN) {
        retrySymbol.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                           CGRectGetMidY(self.frame) - 10.0);
    } else {
        retrySymbol.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0,
                                           CGRectGetMidY(self.frame) - 30.0);
    }
    [self addChild:retrySymbol];
}

- (void)addMenuSymbol {
    SKTexture *menuTexture = [SKTexture textureWithImageNamed:@"MenuSymbol.png"];
    SKSpriteNode *menuSymbol = [[SKSpriteNode alloc] initWithTexture:menuTexture];
    menuSymbol.name = @"menuSymbol";
    if (IS_WIDESCREEN) {
        menuSymbol.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) - 10.0);
    } else {
        menuSymbol.position = CGPointMake(CGRectGetMidX(self.frame) + 80.0,
                                          CGRectGetMidY(self.frame) - 30.0);
    }

    [self addChild:menuSymbol];
}

- (void)addDividers {
    CGFloat screenMiddleX = CGRectGetMidX(self.frame);
    CGFloat screenMiddleY = CGRectGetMidY(self.frame);


    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"GameOverSymbols"];
    SKTexture *longDividerTexture = [atlas textureNamed:@"Long_Bar.png"];
    SKTexture *middleLongerDivider = [atlas textureNamed:@"Middle_Longer_Bar.png"];
    SKTexture *middleShorterDivider = [atlas textureNamed:@"Middle_Shorter_bar.png"];

    SKSpriteNode *top = [SKSpriteNode spriteNodeWithTexture:longDividerTexture];
    SKSpriteNode *firstMiddle = [SKSpriteNode spriteNodeWithTexture:middleLongerDivider];
    SKSpriteNode *secondMiddle = [SKSpriteNode spriteNodeWithTexture:middleShorterDivider];
    SKSpriteNode *bottom = [SKSpriteNode spriteNodeWithTexture:longDividerTexture];
    if (IS_WIDESCREEN) {
        top.position = CGPointMake(screenMiddleX, screenMiddleY + 195.0);
        firstMiddle.position = CGPointMake(screenMiddleX, screenMiddleY + 125.0);
        bottom.position = CGPointMake(screenMiddleX, screenMiddleY + 53.0);
        secondMiddle.position =  CGPointMake(screenMiddleX, screenMiddleY - 5.0);
    } else {
        top.position = CGPointMake(screenMiddleX, screenMiddleY + 155.0);
        firstMiddle.position = CGPointMake(screenMiddleX, screenMiddleY + 85.0);
        bottom.position = CGPointMake(screenMiddleX, screenMiddleY + 23.0);
        secondMiddle.position =  CGPointMake(screenMiddleX, screenMiddleY - 40.0);
    }
    [self addChild:top];
    [self addChild:firstMiddle];
    [self addChild:bottom];
    [self addChild:secondMiddle];

}

/*remove banner add on gameOver age*/
- (void)addShareButtons {
    // initialize facebook button
    SKTexture *facebookTexture = [SKTexture textureWithImageNamed:@"facebook_logo.png"];
    SKSpriteNode *facebookNode = [SKSpriteNode spriteNodeWithTexture:facebookTexture];
    facebookNode.name = @"facebook";
    facebookNode.position = CGPointMake(self.frame.size.width - (facebookNode.size.width / 2) - 10,
                                        facebookNode.size.height / 2 + 10);
    facebookNode.alpha = 0.0;
    
    // initialize twitter button
    SKTexture *twitterTexture = [SKTexture textureWithImageNamed:@"twitter_logo.png"];
    SKSpriteNode *twitterNode = [SKSpriteNode spriteNodeWithTexture:twitterTexture];
    twitterNode.name = @"twitter";
    twitterNode.position = CGPointMake(facebookNode.position.x - twitterNode.size.width -
                                                                twitterNode.size.width / 2,
                                       facebookNode.position.y);
    twitterNode.alpha = 0.0;
    
    [self addChild:facebookNode];
    [self addChild:twitterNode];
    
    [facebookNode runAction:[SKAction fadeInWithDuration:0.5]];
    [twitterNode runAction:[SKAction fadeInWithDuration:0.5]];
}

# pragma mark - Handle touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Initialize touch and location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    SKColor *orangeBackground = [SKColor colorWithRed:245.0 / 255.0 green:144.0 / 255.0
                                                 blue:68.0 / 255.0 alpha:1.0];

    // Scene transitions
    SKTransition *reveal = [SKTransition fadeWithColor:orangeBackground duration:0.5];

    // Touching the retry node presents game scene last played
    if ([node.name isEqualToString:@"retryLabel"] || [node.name isEqualToString:@"retrySymbol"]) {

         id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"GameOverScene"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                              action:@"touch"
                                                               label:@"restart_game_over"
                                                               value:nil] build]];
        [tracker set:kGAIScreenName value:nil];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_FILE loop:YES];
        }
        
        // [[ALInterstitialAd shared] showOver: [UIApplication sharedApplication].keyWindow];
        [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];

    } else if ([node.name isEqualToString:@"menuLabel"] || 
               [node.name isEqualToString:@"menuSymbol"]) {
        [self removeAllActions];
        [self removeAllChildren];
        STSWelcomeScene *welcomeScene = [[STSWelcomeScene alloc] initWithSize:self.size];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_FILE loop:YES];
        }
        [self.view presentScene:welcomeScene transition:reveal];
    } else if ([node.name isEqualToString:@"twitter"]) {
        [self shareTextToTwitter];
    } else if ([node.name isEqualToString:@"facebook"]) {
        [self shareTextToFaceBook];
    }

}

#pragma mark - Handle Ads

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {

    SKColor *orangeBackground = [SKColor colorWithRed:245.0 / 255.0 green:144.0 / 255.0
                                                 blue:68.0 / 255.0 alpha:1.0];
    SKTransition *reveal = [SKTransition fadeWithColor:orangeBackground duration:0.5];
    STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
    [self.view presentScene:gameScene transition:reveal];
}

- (void) ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    SKColor *orangeBackground = [SKColor colorWithRed:245.0 / 255.0 green:144.0 / 255.0
                                                 blue:68.0 / 255.0 alpha:1.0];
    SKTransition *reveal = [SKTransition fadeWithColor:orangeBackground duration:0.5];
    STSEndlessGameScene *gameScene = [[STSEndlessGameScene alloc] initWithSize:self.size];
    [self.view presentScene:gameScene transition:reveal];
}

- (void) ad:(ALAd *)ad wasClickedIn:(UIView *)view {

}

- (void) ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {


}

#pragma mark - Sharing logic
- (void)shareTextToFaceBook{
    //  Create an instance of the Tweet Sheet
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"GameOverTimedScene"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"shareFB"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];

    SLComposeViewController *facebookSheet =
        [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    facebookSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    NSString *message = [NSString stringWithFormat:@"I just blocked %@ dots! #Ozone!",
                                                        self.scoreString];
    [facebookSheet setInitialText:message];
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
//    if (![facebookSheet addURL:[NSURL URLWithString:@"http://facebook.com/"]]){
//        NSLog(@"Unable to add the URL!");
//    }
    
    //  Presents the Tweet Sheet to the user
    [self.view.window.rootViewController presentViewController:facebookSheet 
                                                      animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
    
}

- (void)shareTextToTwitter{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"GameOverTimedScene"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"shareTwitter"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];

    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet =
        [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    NSString *message = [NSString stringWithFormat:@"I just blocked %@ dots! #Ozone!",
                                                        self.scoreString];
    [tweetSheet setInitialText:message];
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"shareImage.png"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
//    if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
//        NSLog(@"Unable to add the URL!");
//    }
    
    //  Presents the Tweet Sheet to the user
    [self.view.window.rootViewController presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}

@end
