//
//  VAAudioQueue.h
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAAudioPlayback.h"
#import "VKAudio.h"

@interface VAAudioQueue : NSObject

typedef void (^feedbackBlock)(VKAudio *item);
typedef void (^itemFinishedBlock)(VKAudio *nextItem);

-(id)initWithItems:(NSArray *)items;

@property (nonatomic) VAAudioStatus status;

-(void)addItem:(VKAudio *)item;
-(void)addItem:(VKAudio *)item atIndex:(NSInteger)index;
-(void)removeItem:(VKAudio *)item;
-(void)removeItemAtIndex:(NSInteger)index;
-(void)clearQueue;

-(void)playCurrentItem;
-(void)pause;
-(void)playNextItem;
-(void)playPreviousItem;
-(void)playItem:(VKAudio *)item;
-(void)playItemAtIndex:(NSInteger)index;

-(VKAudio *)getCurrentItem;
-(NSInteger)indexOfCurrentItem;

-(void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(itemFinishedBlock)finishedBlock;


@end
