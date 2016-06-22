//
//  NSTimer+VAAudioManager.h
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (VAAudioManager)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

-(void)pauseTimer;
-(void)resumeTimer;

@end
