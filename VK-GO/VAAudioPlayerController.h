//
//  VAAudioPlayerController.h
//  VK-GO
//
//  Created by Vladislav Andreev on 21.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAAudioPlayerController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)peviousAudio:(UIButton *)sender;
- (IBAction)playAudio:(UIButton *)sender;
- (IBAction)nextAudio:(UIButton *)sender;

@end
