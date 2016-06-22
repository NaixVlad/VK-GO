//
//  VAAudioPlayback.m
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudioPlayback.h"
#import "VAAudioManager.h"
#import "NSTimer+VAAudioManager.h"

@interface VAAudioPlayback ()

-(void)setUpItem:(VKAudio *)item;

@property (nonatomic, strong) NSTimer *feedbackTimer;

@end

@implementation VAAudioPlayback

NSString * const AFSoundPlaybackStatus = @"status";
NSString * const AFSoundStatusDuration = @"duration";
NSString * const AFSoundStatusTimeElapsed = @"timeElapsed";

NSString * const AFSoundPlaybackFinishedNotification = @"kAFSoundPlaybackFinishedNotification";

-(id)initWithItem:(VKAudio *)item {
    
    if (self == [super init]) {
        
        self.currentItem = item;
        [self setUpItem:item];
        
        self.status = VAAudioStatusNotStarted;
    }
    
    return self;
}

-(void)setUpItem:(VKAudio *)item {
    
    self.player = [[AVPlayer alloc] initWithURL:item.url];
    [self.player play];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    self.status = VAAudioStatusPlaying;
    
    self.currentItem = item;
    self.currentItem.duration = (int)CMTimeGetSeconds(self.player.currentItem.asset.duration);
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

-(void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(finishedBlock)finishedBlock {
    
    CGFloat updateRate = 1;
    
    if (self.player.rate > 0) {
        
        updateRate = 1 / self.player.rate;
    }
    
    self.feedbackTimer = [NSTimer scheduledTimerWithTimeInterval:updateRate block:^{
        
        self.currentItem.timePlayed = (int)CMTimeGetSeconds(self.player.currentTime);
        
        if (block) {
            
            block(self.currentItem);
        }
        
        if (self.statusDictionary[AFSoundStatusDuration] == self.statusDictionary[AFSoundStatusTimeElapsed]) {
            
            [self.feedbackTimer pauseTimer];
            
            self.status = VAAudioStatusFinished;
            
            if (finishedBlock) {
                
                finishedBlock();
            }
        }
    } repeats:YES];
}

-(NSDictionary *)playingInfo {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:[NSNumber numberWithDouble:CMTimeGetSeconds(self.player.currentItem.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [dict setValue:@(self.player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    return dict;
}

-(void)play {
    
    [self.player play];
    [self.feedbackTimer resumeTimer];
    [[MPRemoteCommandCenter sharedCommandCenter] playCommand];
    
    self.status = VAAudioStatusPlaying;
}

-(void)pause {
    
    [self.player pause];
    [self.feedbackTimer pauseTimer];
    [[MPRemoteCommandCenter sharedCommandCenter] pauseCommand];
    
    self.status = VAAudioStatusPaused;
}

-(void)restart {
    
    [self.player seekToTime:CMTimeMake(0, 1)];
}

-(void)playAtSecond:(NSInteger)second {
    
    [self.player seekToTime:CMTimeMake(second, 1)];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self play];
                break;
                
            default:
                break;
        }
    }
}

-(NSDictionary *)statusDictionary {
    
    return @{VAAudioStatusDuration: @((int)CMTimeGetSeconds(self.player.currentItem.asset.duration)),
             VAAudioStatusTimeElapsed: @((int)CMTimeGetSeconds(self.player.currentItem.currentTime)),
             VAAudioPlaybackStatus: @(self.status)};
}

@end
