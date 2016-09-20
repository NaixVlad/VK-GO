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

@property (nonatomic) NSTimer *feedbackTimer;

@end

@implementation VAAudioPlayback

NSString * const VAAudioPlaybackStatus = @"status";
NSString * const VAAudioStatusDuration = @"duration";
NSString * const VAAudioStatusTimeElapsed = @"timeElapsed";
NSString * const VAAudioPlaybackFinishedNotification = @"kVASoundPlaybackFinishedNotification";


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = VAAudioStatusNotStarted;

        [self addObserver:self
               forKeyPath:@"currentItem"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:NULL];
    }

    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentItem" context:NULL];
}

- (void)setUpItem:(VAAudio *)item {
    
    NSURL *url = [NSURL URLWithString: item.url];
    self.player = [[AVPlayer alloc] initWithURL:url];
    [self.player play];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    self.status = VAAudioStatusPlaying;
    
    self.currentItem = item;

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(finishedBlock)finishedBlock {
    
    CGFloat updateRate = 1;
    
    if (self.player.rate > 0) {
        
        updateRate = 1 / self.player.rate;
    }
    
    self.feedbackTimer = [NSTimer scheduledTimerWithTimeInterval:updateRate block:^{
        
        self.currentItem.timePlayed = (int)CMTimeGetSeconds(self.player.currentTime);
        
        if (block) {
            
            block(self.currentItem);
        }
        
        if (self.statusDictionary[VAAudioStatusDuration] == self.statusDictionary[VAAudioStatusTimeElapsed]) {
            
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"VAAudioChange" object:change];

}

@end
