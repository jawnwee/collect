//
//  STSOptionsScene.m
//  CircleSecondIteration
//
//  Created by Matthew Chiang on 5/30/14.
//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import "STSOptionsScene.h"

@interface STSOptionsScene () <UITextFieldDelegate>
@property (nonatomic) SKLabelNode *nicknameLabel;
@property (nonatomic) UITextField *nicknameTextField;
@property (nonatomic) NSString *currentNickname;
@property (nonatomic) SKLabelNode *musicToggleLabel;
@property (nonatomic) SKLabelNode *exitLabel;

@end

@implementation STSOptionsScene

@synthesize prevScene;

# pragma mark - Initialize scene contents

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        self.currentNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
        [self addNicknameLabel];
        [self addMusicToggleLabel];
        [self addExitLabel];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    self.nicknameTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.size.width / 5,
                                                                           100,
                                                                           200, 30)];
    self.nicknameTextField.borderStyle = UITextBorderStyleNone;
    self.nicknameTextField.textColor = [UIColor blackColor];
    self.nicknameTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
    self.nicknameTextField.placeholder = @"Change nickname";
    self.nicknameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nicknameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nicknameTextField.delegate = self;

    [self.view addSubview:self.nicknameTextField];
}

- (void)addNicknameLabel {

    self.nicknameLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    if (self.currentNickname == nil) {
        self.nicknameLabel.text = @"Nickname";
    } else {
        self.nicknameLabel.text = self.currentNickname;
    }
    self.nicknameLabel.fontColor = [SKColor blackColor];
    self.nicknameLabel.fontSize = 36.0;
    self.nicknameLabel.position = CGPointMake(CGRectGetMidX(self.frame), 
                                              CGRectGetMaxY(self.frame) - 100);

    [self addChild:self.nicknameLabel];
    
}

- (void)addMusicToggleLabel {

    self.musicToggleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"]) {
        self.musicToggleLabel.text = @"Music is On";
    } else {
        self.musicToggleLabel.text = @"Music is Off";
    }
    self.musicToggleLabel.fontColor = [SKColor blackColor];
    self.musicToggleLabel.fontSize = 36.0;
    self.musicToggleLabel.position = CGPointMake(CGRectGetMidX(self.frame), 
                                                 CGRectGetMidY(self.frame));
    self.musicToggleLabel.name = @"musicToggleLabel";

    [self addChild:self.musicToggleLabel];
}

- (void)addExitLabel {
    self.exitLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    self.exitLabel.text = @"Go Back";
    self.exitLabel.fontColor = [SKColor blackColor];
    self.exitLabel.fontSize = 36.0;
    self.exitLabel.position = CGPointMake(CGRectGetMidX(self.frame), 
                                          CGRectGetMidY(self.frame) - 150);
    self.exitLabel.name = @"exitLabel";

    [self addChild:self.exitLabel];
}

# pragma mark - Handle nickname changes

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    self.nicknameLabel.text = textField.text;
    self.currentNickname = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:self.currentNickname forKey:@"nickname"];
    textField.text = nil;
    textField.placeholder = @"Change nickname";

    return YES;
}

# pragma mark - Handle touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    // Clicking the music label toggles sound on/off
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"] &&
        [node.name isEqualToString:@"musicToggleLabel"]) {

        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"musicToggle"];
        self.musicToggleLabel.text = @"Music is Off";
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"musicToggle"] &&
        [node.name isEqualToString:@"musicToggleLabel"]) {

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"musicToggle"];
        self.musicToggleLabel.text = @"Music is On";
    }

    // Clicking the exit label
    if ([node.name isEqualToString:@"exitLabel"]) {
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft
                                                      duration:0.5];
        self.nicknameTextField.hidden = YES;
        [self.view presentScene:self.prevScene transition:reveal];
    }

    // Clicking anywhere but the keyboard dismisses it when changing nicknames
    if ([self.nicknameTextField isFirstResponder] && [touch view] != self.nicknameTextField) {
        [self.nicknameTextField resignFirstResponder];
    }
}

@end
