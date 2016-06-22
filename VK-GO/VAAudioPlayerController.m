//
//  VAAudioPlayerController.m
//  VK-GO
//
//  Created by Vladislav Andreev on 21.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudioPlayerController.h"
#import "FrameAccessor.h"

@interface VAAudioPlayerController () <UIScrollViewDelegate>

@property (nonatomic) UIImageView *albumCover;
@property (nonatomic) UIView *lyricsView;

@end

@implementation VAAudioPlayerController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    self.contentScrollView.pagingEnabled = YES;
    
    //cover of album
    
    CGRect albumCoverRect = CGRectMake(0, 0, self.view.width, self.contentScrollView.height);
    
    self.albumCover = [[UIImageView alloc] initWithFrame:albumCoverRect];
    
    self.albumCover.backgroundColor = [UIColor blueColor];
    
    [self.contentScrollView addSubview:self.albumCover];
    
    //lyrics
    
    CGRect lyricsViewRect = CGRectMake(self.albumCover.width, 0, self.view.width, self.contentScrollView.height);
    
    self.lyricsView = [[UIImageView alloc] initWithFrame:lyricsViewRect];
    
    self.lyricsView.backgroundColor = [UIColor redColor];
    
    [self.contentScrollView addSubview:self.lyricsView];
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.width*2, self.contentScrollView.height);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)peviousAudio:(UIButton *)sender {
}

- (IBAction)playAudio:(UIButton *)sender {
}

- (IBAction)nextAudio:(UIButton *)sender {
}
@end
