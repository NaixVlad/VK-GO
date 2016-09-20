//
//  VAAudioQueue.h
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAAudioPlayback.h"
#import "VAAudio.h"

@interface VAAudioQueue : NSObject

typedef void (^feedbackBlock)(VAAudio *item);
typedef void (^itemFinishedBlock)(VAAudio *nextItem);


+ (VAAudioQueue*) sharedQueueManager;

@property (nonatomic) VAAudioStatus status;

- (NSMutableArray*) getQueueItems;
- (void) setQueueItems:(NSMutableArray *)items;
- (void) addItem:(VAAudio *)item;
- (void) addItem:(VAAudio *)item atIndex:(NSInteger)index;
- (void) removeItem:(VAAudio *)item;
- (void) removeItemAtIndex:(NSInteger)index;
- (void) clearQueue;

- (void) playCurrentItem;
- (void) pause;
- (void) playNextItem;
- (void) playPreviousItem;
- (void) playItem:(VAAudio *)item;
- (void) playItemAtIndex:(NSInteger)index;
- (void) playAtSecond: (NSInteger) second;
- (BOOL) isPlaying;

- (VAAudio *) getCurrentItem;
- (NSInteger) indexOfCurrentItem;

- (void) listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(itemFinishedBlock)finishedBlock;


@end
