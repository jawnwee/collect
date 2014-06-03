//
//  STSMyScene.h
//  CircleSecondIteration
//

//  Copyright (c) 2014 SummaTime Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@import AVFoundation;

@interface STSWelcomeScene : SKScene

@property (nonatomic) BOOL musicStillPlaying;

@property (nonatomic) AVAudioPlayer *welcomeBackgroundMusicPlayer;

- (id)initWithSize:(CGSize)size;

@end
