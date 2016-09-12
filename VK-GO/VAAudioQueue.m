//
//  VAAudioQueue.m
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudioQueue.h"
#import "VAAudioManager.h"
#import "NSTimer+VAAudioManager.h"

#import <objc/runtime.h>

@interface VAAudioQueue ()

@property (nonatomic) VAAudioPlayback *queuePlayer;
@property (nonatomic) NSMutableArray *items;

@property (nonatomic) NSTimer *feedbackTimer;

@end


@implementation VAAudioQueue

+ (VAAudioQueue*) sharedQueueManager {
    
    static VAAudioQueue* manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VAAudioQueue alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.queuePlayer = [[VAAudioPlayback alloc] init];
        
    }
    return self;
}


- (void)setQueueItems:(NSMutableArray *)items {
    
    [self clearQueue];
    self.items = [NSMutableArray arrayWithArray:items];
    
}

-(void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(itemFinishedBlock)finishedBlock {
    
    CGFloat updateRate = 1;
    
    if (self.queuePlayer.player.rate > 0) {
        
        updateRate = 1 / self.queuePlayer.player.rate;
    }
    
    self.feedbackTimer = [NSTimer scheduledTimerWithTimeInterval:updateRate block:^{
        
        if (block) {
            
            self.queuePlayer.currentItem.timePlayed = (int)CMTimeGetSeconds(self.queuePlayer.player.currentTime); 
            
            block(self.queuePlayer.currentItem);
        }
        
        if (self.queuePlayer.currentItem.timePlayed == [self.queuePlayer.currentItem.duration integerValue]) {
            
            if (finishedBlock) {
                
                if ([self indexOfCurrentItem] + 1 < self.items.count) {
                    
                    finishedBlock(self.items[[self indexOfCurrentItem] + 1]);
                } else {
                    
                    finishedBlock(nil);
                }
            }
            
            [self.feedbackTimer pauseTimer];
            
            [self playNextItem];
        }
    } repeats:YES];
}

- (void) addItem:(VAAudio *)item {
    
    [self addItem:item atIndex:self.items.count];
}

- (void) addItem:(VAAudio *)item atIndex:(NSInteger)index {
    
    [self.items insertObject:item atIndex:(self.items.count >= index) ? self.items.count : index];
}

- (void) removeItem:(VAAudio *)item {
    
    if ([self.items containsObject:item]) {
        
        [self removeItemAtIndex:[self.items indexOfObject:item]];
    }
}

- (void) removeItemAtIndex:(NSInteger)index {
    
    if (self.items.count >= index) {
        
        VAAudio *item = self.items[index];
        [self.items removeObject:item];
        
        if (self.queuePlayer.currentItem == item) {
            
            [self playNextItem];
            
            [self.feedbackTimer resumeTimer];
        }
    }
}

- (void) clearQueue {
    
    [self.queuePlayer pause];
    [self.items removeAllObjects];
    [self.feedbackTimer pauseTimer];
}

- (void) playCurrentItem {
    
    [self.queuePlayer play];
    [[MPRemoteCommandCenter sharedCommandCenter] playCommand];
    
    [self.feedbackTimer resumeTimer];
}

- (void) pause {
    
    [self.queuePlayer pause];
    [[MPRemoteCommandCenter sharedCommandCenter] pauseCommand];
    
    [self.feedbackTimer pauseTimer];
}

- (void) playNextItem {
    
    if ([self.items containsObject:self.queuePlayer.currentItem]) {
        
        [self playItemAtIndex:([self.items indexOfObject:self.queuePlayer.currentItem] + 1)];
        [[MPRemoteCommandCenter sharedCommandCenter] nextTrackCommand];
        
        [self.feedbackTimer resumeTimer];
    }
}

- (void) playPreviousItem {
    
    if ([self.items containsObject:self.queuePlayer.currentItem] && [self.items indexOfObject:self.queuePlayer.currentItem] > 0) {
        
        [self playItemAtIndex:([self.items indexOfObject:self.queuePlayer.currentItem] - 1)];
        [[MPRemoteCommandCenter sharedCommandCenter] previousTrackCommand];
    }
}

- (void) playItemAtIndex:(NSInteger)index {
    
    if (self.items.count > index) {
        
        [self playItem:self.items[index]];
    }
}


-(void) playItem:(VAAudio *)item {
    
    if ([self.items containsObject:item]) {
        
        if (self.queuePlayer.status == VAAudioStatusNotStarted || self.queuePlayer.status == VAAudioStatusPaused || self.queuePlayer.status == VAAudioStatusFinished) {
            
            //            [self.feedbackTimer resumeTimer];
        }

        self.queuePlayer = [[VAAudioPlayback alloc] init];
        [self.queuePlayer setUpItem:item];
        [self.queuePlayer play];
        [[MPRemoteCommandCenter sharedCommandCenter] playCommand];
        
    }
}


- (void) playAtSecond: (NSInteger) second {
    
    [self.queuePlayer playAtSecond: second];
    
    NSLog(@"%ld", (long)second);
    
}

- (BOOL) isPlaying {
    
    AVPlayer* pl = self.queuePlayer.player;
    
    if ((pl.rate != 0) && (pl.error == nil)) {
        return YES;
    }
    
    return NO;
}

-(VAAudio *)getCurrentItem {
    
    return self.queuePlayer.currentItem;
}

-(NSInteger)indexOfCurrentItem {
    
    VAAudio *currentItem = [self getCurrentItem];
    
    if ([self.items containsObject:currentItem]) {
        
        return [self.items indexOfObject:currentItem];
    }
    
    return NAN;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPreviousItem];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNextItem];
                break;
                
            default:
                break;
        }
    }
}


@end
