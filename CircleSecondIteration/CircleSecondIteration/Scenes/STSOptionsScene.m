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

@end

@implementation STSOptionsScene

# pragma mark - Initialize scene contents

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        self.currentNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
        NSLog(@"Opening up the scene...nickname at top should be: %@", self.currentNickname);
        [self addNicknameLabel];
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
    self.nicknameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 100);

    [self addChild:self.nicknameLabel];
    
}

# pragma mark - Handle nickname changes

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    self.nicknameLabel.text = textField.text;
    self.currentNickname = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:self.currentNickname forKey:@"nickname"];
    textField.text = nil;
    textField.placeholder = @"Change nickname";
    NSLog(@"The currentNickname is: %@", self.currentNickname);
    NSLog(@"Next time I open, the nickname should be: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"]);
    return YES;
}

# pragma mark - Handle touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    if ([self.nicknameTextField isFirstResponder] && [touch view] != self.nicknameTextField) {
        [self.nicknameTextField resignFirstResponder];
    }
}

@end
