//
//  VAAudioPlayerController.m
//  VK-GO
//
//  Created by Vladislav Andreev on 21.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudioPlayerController.h"
#import "FrameAccessor.h"
#import "VAAudioManager.h"


@interface VAAudioPlayerController () <UIScrollViewDelegate>

@property (nonatomic) UIImageView *albumCover;
@property (nonatomic) UITextView *lyricsView;
@property (nonatomic) NSString *lyrics;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) BOOL isRewinding;
@property (nonatomic) CGFloat range;
@property (nonatomic) CGFloat currentPositionInSeconds;
@property (nonatomic) NSInteger timeElapsed;

@end

@implementation VAAudioPlayerController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //MPVolumeView;
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    CGFloat width = self.view.width;
    
    //cover of album
    
    CGRect albumCoverRect = CGRectMake(0, 0, width, width);
    
    self.albumCover = [[UIImageView alloc] initWithFrame:albumCoverRect];
    
    self.albumCover.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.contentScrollView addSubview:self.albumCover];
    
    //lyrics
    
    CGRect lyricsViewRect = CGRectMake(width, 0, width, width - self.pageControl.height);
    
    self.lyricsView = [[UITextView alloc] initWithFrame:lyricsViewRect];
    
    self.lyricsView.editable = NO;
    
    self.lyricsView.textAlignment = NSTextAlignmentNatural;
    
    [self.contentScrollView addSubview:self.lyricsView];
    
    self.lyricsView.backgroundColor = [UIColor clearColor];
    
    self.lyricsView.textColor = [UIColor whiteColor];
    
    [self.lyricsView setFont:[UIFont systemFontOfSize:15]];
    
    self.contentScrollView.contentSize = CGSizeMake(width * 2, width);
    
    // content
    
    [self updateContent];
    
    self.range = self.view.width / [queue.getCurrentItem.duration floatValue];
    

    
    [queue listenFeedbackUpdatesWithBlock:^(VAAudio *item) {
        
        if (!self.isRewinding) {
            
            self.timeElapsedLabel.text = [self timeFormatted: item.timePlayed];
            
            NSInteger timeRemaining = [item.duration integerValue] - item.timePlayed;
            self.timeRemainingLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormatted: timeRemaining]];
            
            self.currentPositionInSeconds = self.range * item.timePlayed;
            
            NSLog(@"%f", self.currentPositionInSeconds);
            
            [UIView animateWithDuration:0.f animations:^{
                
                //self.moovingView.x = self.currentPositionInSeconds - startPoint;
                
                self.timeElapsedView.width = self.currentPositionInSeconds;
                self.moovingView.center = CGPointMake(self.timeElapsedView.width, self.moovingView.height/2);
            }];
            
        }
        
    } andFinishedBlock:^(VAAudio *nextItem) {
        [self.playButton setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
    }];
    
    //Gestures
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    
    [self.moovingView addGestureRecognizer:panGesture];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateContent) name:@"VAAudioChange" object:nil];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//InterfaceOrientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
}

- (void)updateContent {
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    VAAudio *audio = [queue getCurrentItem];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [audio fetchMetadata];
        [self loadLyrics];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lyricsView.text = self.lyrics;
            
            if (!queue.getCurrentItem.artwork) {
                self.albumCover.image = [UIImage imageNamed:@"defautAlbumCover"];
            } else {
                self.albumCover.image = queue.getCurrentItem.artwork;
            }
            
            UIImageView *bcLyrics = [[UIImageView alloc] initWithImage:self.albumCover.image];
            
            bcLyrics.frame = CGRectMake(self.lyricsView.x, self.lyricsView.y, self.view.width, self.view.height);
            
            UIVisualEffect *blurEffect;
            blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
            
            UIVisualEffectView *visualEffectView;
            visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            
            visualEffectView.frame = bcLyrics.bounds;
            [bcLyrics addSubview:visualEffectView];
            [self.contentScrollView insertSubview:bcLyrics belowSubview:self.lyricsView];
            
            self.audioTitleLable.text = audio.title;
            self.artistLabele.text = audio.artist;
            
            [self.playButton setImage: [UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
            
        });
    });

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//player actions

- (IBAction)peviousAudio:(UIButton *)sender {
    
    [[VAAudioQueue sharedQueueManager] playPreviousItem];
    
}

- (IBAction)playAudio:(UIButton *)sender {
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    if ([queue isPlaying]) {
        
        [queue pause];
        [sender setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        
        
    } else {
    
        [queue playCurrentItem];
        [sender setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        
    }
}

- (IBAction)nextAudio:(UIButton *)sender {
    
    [[VAAudioQueue sharedQueueManager] playNextItem];
    
}

//network

- (void)loadLyrics {
    __block NSString *lyr;
    VAAudio *audio = [[VAAudioQueue sharedQueueManager] getCurrentItem];
    
    if (audio.lyrics_id) {
    
    VKRequest *request = [VKApi requestWithMethod:@"audio.getLyrics" andParameters:@{@"lyrics_id" : audio.lyrics_id}];
    request.waitUntilDone = YES;
    
    [request executeWithResultBlock:^(VKResponse *response) {

        lyr = [response.json objectForKey:@"text"];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    } else {
        
        lyr = @"Слова к данной аудиозаписи отсутствуют";
    }
    self.lyrics = lyr;
    
}

//Gestures

- (void)handlePan: (UIPanGestureRecognizer *) panGesture {
    
    CGPoint touchLocation = [panGesture locationInView: self.view];
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:
            
            break;
            
        case UIGestureRecognizerStateBegan:
            
            self.isRewinding = YES;
            
            break;
            
        case UIGestureRecognizerStateChanged:

            self.moovingView.center = CGPointMake(touchLocation.x, self.moovingView.height/2);
            
            self.timeElapsed = self.range * self.moovingView.x;
            
            self.timeElapsedLabel.text = [NSString stringWithFormat:@"%@", [self timeFormatted: self.timeElapsed ]];
            
            NSInteger timeRemaining = [queue.getCurrentItem.duration integerValue] - self.timeElapsed ;
            self.timeRemainingLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormatted: timeRemaining]];
            
            break;
            
        case UIGestureRecognizerStateEnded:
            
            //[queue playAtSecond: (self.view.width / (self.moovingView.x + self.moovingView.width/2 + self.currentTimeView.width/2)) * self.range];
            [queue playAtSecond:self.timeElapsed ];
            
            NSLog(@"%ld", (long)self.timeElapsed);
            
            self.isRewinding = NO;
            
        case UIGestureRecognizerStateFailed:
            
            self.isRewinding = NO;
            
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            self.isRewinding = NO;
            
            break;
    }
    
}

//helpers


- (NSString *)timeFormatted: (NSInteger) totalSeconds
{

    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    if (hours < 1) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}


@end
