//
//  STSTimedGameOverScene.m
//  Ozone!
//
//  Created by John Lee on 6/8/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSTimedGameOverScene.h"
#import "STSEndlessGameScene.h"
#import "STSWelcomeScene.h"
#import "STSTimedGameScene.h"
#import "ObjectAL.h"
#import "ALInterstitialAd.h"
#import "ALAdview.h"
#import "Social/Social.h"
#import "GAIDictionaryBuilder.h"

#define BACKGROUND_MUSIC_FILE @"background.mp3"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface STSTimedGameOverScene () <ALAdLoadDelegate, ALAdDisplayDelegate>

@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *highScoreLabel;
@property (nonatomic) NSString *scoreString;
@property (nonatomic) NSString *highScoreString;

@property (nonatomic) SKSpriteNode *deadOzone;

@end

@implementation STSTimedGameOverScene


#pragma mark - Initialization
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"GameOverTimedScene"];
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
    [super createSceneContents];
}

- (void)didMoveToView:(SKView *)view {
    int highScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"timedHighScore"];
    self.highScoreString = [self getTimeStr:highScore];
    self.scoreString = [self.userData valueForKey:@"timedScore"];

    [self addScoreLabel];
    [self addHighScoreLabel];
}

// Helper method to get timed score
- (NSString*)getTimeStr:(int)secondsElapsed {
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
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
    self.scoreLabel.fontSize = 36.0;
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
    self.highScoreLabel.fontSize = 36.0;
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
    SKTexture *menuTexture = [SKTexture textureWithImageNamed:@"MenuSymbol@2x.png"];
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
    [super addDividers];
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
        [tracker set:kGAIScreenName value:@"GameOverTimedScene"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                              action:@"touch"
                                                               label:@"restart_timedgame_over"
                                                               value:nil] build]];
        [tracker set:kGAIScreenName value:nil];

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [[OALSimpleAudio sharedInstance] playBg:BACKGROUND_MUSIC_FILE loop:YES];
        }

        // [[ALInterstitialAd shared] showOver: [UIApplication sharedApplication].keyWindow];
        [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];

        [self removeAllChildren];
        [self removeAllActions];
        [super removeAllActions];
        [super removeAllChildren];

    } else if ([node.name isEqualToString:@"menuLabel"] ||
               [node.name isEqualToString:@"menuSymbol"]) {
        [self removeAllChildren];
        [self removeAllActions];
        [super removeAllActions];
        [super removeAllChildren];
        self.userData = nil;
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
    STSTimedGameScene *gameScene = [[STSTimedGameScene alloc] initWithSize:self.size];
    [self.view presentScene:gameScene transition:reveal];
}

- (void) ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    SKColor *orangeBackground = [SKColor colorWithRed:245.0 / 255.0 green:144.0 / 255.0
                                                 blue:68.0 / 255.0 alpha:1.0];
    SKTransition *reveal = [SKTransition fadeWithColor:orangeBackground duration:0.5];
    STSTimedGameScene *gameScene = [[STSTimedGameScene alloc] initWithSize:self.size];
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
    NSString *message = [NSString stringWithFormat:@"I just blocked red dots for %@ minutes! #Ozone!",
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
    NSString *message = [NSString stringWithFormat:@"I just blocked red dots for %@ minutes! #Ozone!",
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
