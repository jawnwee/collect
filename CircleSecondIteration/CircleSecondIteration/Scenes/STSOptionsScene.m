//
//  STSOptionsScene.m
//  CircleSecondIteration
//
//  Created by Matthew Chiang on 5/30/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSOptionsScene.h"
#import "STSWelcomeScene.h"
#import "STSPauseScene.h"

@interface STSOptionsScene () <UITextFieldDelegate>
@property (nonatomic) SKLabelNode *nicknameLabel;
@property (nonatomic) UITextField *nicknameTextField;
@property (nonatomic) NSString *currentNickname;
@property (nonatomic) SKLabelNode *changeNicknameLabel;
@property (nonatomic) SKLabelNode *musicToggleLabel;
@property (nonatomic) SKLabelNode *soundToggleLabel;
@property (nonatomic) SKSpriteNode *saveButton;

@end

@implementation STSOptionsScene

@synthesize previousScene;

# pragma mark - Initialize scene contents

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.backgroundColor = [SKColor colorWithRed:240.0 / 255.0
                                               green:241.0 / 255.0
                                                blue:238.0 / 255.0
                                               alpha:1.0];
        self.scaleMode = SKSceneScaleModeAspectFill;
        [self createSceneContents];
    }
    return self;
}

- (void)createSceneContents {
    CGFloat middle = CGRectGetMidX(self.frame);
    CGFloat height = self.frame.size.height;

    self.currentNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    [self addTitle];
    [self addDivider:CGPointMake(middle, height - 75.0)];
    [self addNicknameTitle];
    [self addDivider:CGPointMake(middle, height - 200.0)];
    [self addMusicTitle];
    [self addMusicToggle];
    [self addSoundToggle];
    [self addDivider:CGPointMake(middle, height - 335.0)];
    [self addSaveButton];
    // [self addDivider:CGPointMake(middle, height - 410.0)];
    [self addCredits];
}

- (void)didMoveToView:(SKView *)view {
    self.nicknameTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.size.width / 3,
                                                                           115, 200, 55)];
    self.nicknameTextField.borderStyle = UITextBorderStyleNone;
    self.nicknameTextField.textColor = [UIColor colorWithRed:245.0 / 255.0
                                                       green:144.0 / 255.0
                                                        blue:68.0 / 255.0
                                                       alpha:1.0];
    self.nicknameTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:48.0];
    self.nicknameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nicknameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nicknameTextField.delegate = self;
    self.nicknameTextField.highlighted = NO;

    NSString *currentName = self.currentNickname;
    if (!currentName) {
        self.nicknameTextField.text = @"Player";
    } else {
        self.nicknameTextField.text = currentName;
    }

    [self.view addSubview:self.nicknameTextField];
}


#pragma mark - Scene Elements
- (void)addDivider:(CGPoint)position {
    SKSpriteNode *divider = [SKSpriteNode spriteNodeWithImageNamed:@"Divider.png"];
    divider.position = position;
    [self addChild:divider];
}

- (void)addTitle {
    SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"Settings_Title.png"];
    title.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 50.0);
    [self addChild:title];
}

- (void)addNicknameTitle {

    SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"Nickname.png"];
    title.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 85.0);
    [self addChild:title];
}

- (void)addMusicTitle {
    SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"Music.png"];
    title.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 215.0);
    [self addChild:title];
}

- (void)addMusicToggle {

    self.musicToggleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
        self.musicToggleLabel.text = @"On";
        self.musicToggleLabel.fontColor = [SKColor colorWithRed:168.0 / 255.0 green:219.0 / 255.0 
                                                           blue:96.0 / 255.0 alpha:1.0];
    } else {
        self.musicToggleLabel.text = @"Off";
        self.musicToggleLabel.fontColor = [SKColor colorWithRed:227.0 / 255.0 green:57.0 / 255.0 
                                                           blue:57.0 / 255.0 alpha:1.0];
    }
    self.musicToggleLabel.fontSize = 48.0;
    self.musicToggleLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80,
                                                 self.frame.size.height - 289.0);
    self.musicToggleLabel.name = @"musicToggleLabel";

    [self addChild:self.musicToggleLabel];
}

- (void)addSoundToggle {
    self.soundToggleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundToggle"]) {
        self.soundToggleLabel.text = @"On";
        self.soundToggleLabel.fontColor = [SKColor colorWithRed:168.0 / 255.0 green:219.0 / 255.0
                                                           blue:96.0 / 255.0 alpha:1.0];
    } else {
        self.soundToggleLabel.text = @"Off";
        self.soundToggleLabel.fontColor = [SKColor colorWithRed:227.0 / 255.0 green:57.0 / 255.0
                                                           blue:57.0 / 255.0 alpha:1.0];
    }
    self.soundToggleLabel.fontSize = 48.0;
    self.soundToggleLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 80,
                                                 self.frame.size.height - 289.0);
    self.soundToggleLabel.name = @"soundToggleLabel";
    
    [self addChild:self.soundToggleLabel];
}

- (void)addSaveButton {
    self.saveButton = [SKSpriteNode spriteNodeWithImageNamed:@"Save_Button.png"];
    self.saveButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                           self.frame.size.height - 375.0);
    self.saveButton.name = @"SaveButton";

    [self addChild:self.saveButton];
}

- (void)addCredits {
    SKSpriteNode *credits = [SKSpriteNode spriteNodeWithImageNamed:@"Credits.png"];
    credits.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 480.0);
    [self addChild:credits];
}

# pragma mark - Handle nickname changes

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    self.currentNickname = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:self.currentNickname forKey:@"nickname"];

    return YES;
}

# pragma mark - Handle touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    // Clicking the sound label toggles sound on/off
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundToggle"] &&
        [node.name isEqualToString:@"soundToggleLabel"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundToggle"];
        self.soundToggleLabel.text = @"Off";
        self.soundToggleLabel.fontColor = [SKColor colorWithRed:227.0 / 255.0 green:57.0 / 255.0
                                                           blue:57.0 / 255.0 alpha:1.0];
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"soundToggle"] &&
             [node.name isEqualToString:@"soundToggleLabel"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundToggle"];
        self.soundToggleLabel.text = @"On";
        self.soundToggleLabel.fontColor = [SKColor colorWithRed:168.0 / 255.0 green:219.0 / 255.0
                                                           blue:96.0 / 255.0 alpha:1.0];
    }

    // Clicking the music label toggles music on/off
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"] &&
        [node.name isEqualToString:@"musicToggleLabel"]) {

        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"musicToggle"];
        self.musicToggleLabel.text = @"Off";
        self.musicToggleLabel.fontColor = [SKColor colorWithRed:227.0 / 255.0 green:57.0 / 255.0
                                                           blue:57.0 / 255.0 alpha:1.0];
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"] &&
        [node.name isEqualToString:@"musicToggleLabel"]) {

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"musicToggle"];
        self.musicToggleLabel.text = @"On";
        self.musicToggleLabel.fontColor = [SKColor colorWithRed:168.0 / 255.0 green:219.0 / 255.0
                                                           blue:96.0 / 255.0 alpha:1.0];
    }

    // Clicking the exitLabel
    if ([node.name isEqualToString:@"SaveButton"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight
                                                      duration:0.3];
        [self.nicknameTextField removeFromSuperview];
        [self.view presentScene:self.previousScene transition:reveal];
        self.previousScene = nil;
    }

    // Clicking anywhere but the keyboard dismisses it when changing nicknames
    if ([self.nicknameTextField isFirstResponder] && [touch view] != self.nicknameTextField) {
        [self.nicknameTextField resignFirstResponder];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Instantly toggle music when touched
    if ([self.previousScene isMemberOfClass:[STSWelcomeScene class]]) {
        STSWelcomeScene *previousWelcomeScene = (STSWelcomeScene *)self.previousScene;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [previousWelcomeScene.welcomeBackgroundMusicPlayer play];
        } else {
            [previousWelcomeScene.welcomeBackgroundMusicPlayer stop];
        }
        previousWelcomeScene = nil;
    }
    // Previous scene is the pause scene
    else {
        STSPauseScene *previousPauseScene = (STSPauseScene *)self.previousScene;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
            [previousPauseScene.previousScene.previousScene.welcomeBackgroundMusicPlayer play];
        } else {
            [previousPauseScene.previousScene.previousScene.welcomeBackgroundMusicPlayer stop];
        }
        previousPauseScene = nil;
    }
}

@end
