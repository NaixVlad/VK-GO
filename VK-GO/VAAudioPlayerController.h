//
//  VAAudioPlayerController.h
//  VK-GO
//
//  Created by Vladislav Andreev on 21.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//
#import "VAAudioQueue.h"

#import <UIKit/UIKit.h>

@interface VAAudioPlayerController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (weak, nonatomic) IBOutlet UIView *moovingView;
@property (weak, nonatomic) IBOutlet UIView *currentTimeView;
@property (weak, nonatomic) IBOutlet UIView *allTimeView;
@property (weak, nonatomic) IBOutlet UIView *timeElapsedView;
@property (weak, nonatomic) IBOutlet UILabel *audioTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeSlider;


- (IBAction)peviousAudio:(UIButton *)sender;
- (IBAction)playAudio:(UIButton *)sender;
- (IBAction)nextAudio:(UIButton *)sender;

@end
