//
//  VAAudioPlayback.h
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "VAAudio.h"

typedef void (^feedbackBlock)(VAAudio *item);
typedef void (^finishedBlock)(void);

@interface VAAudioPlayback : NSObject

extern NSString *const VAAudioPlaybackStatus;
extern NSString *const VAAudioStatusDuration;
extern NSString *const VAAudioStatusTimeElapsed;

extern NSString *const VAAudioPlaybackFinishedNotification;

typedef NS_ENUM(NSInteger, VAAudioStatus) {
    
    VAAudioStatusNotStarted = 0,
    VAAudioStatusPlaying,
    VAAudioStatusPaused,
    VAAudioStatusFinished
};

- (instancetype)init;

@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) VAAudioStatus status;

@property (strong, nonatomic) VAAudio *currentItem;

- (void)setUpItem:(VAAudio *)item;
- (void)play;
- (void)pause;
- (void)restart;

- (void)playAtSecond:(NSInteger)second;

- (void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(finishedBlock)finishedBlock;
- (NSDictionary *)statusDictionary;


@end
