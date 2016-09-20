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

@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) UITextView *lyricsView;
@property (strong, nonatomic) NSString *lyrics;
@property (nonatomic) BOOL isRewindingFlag;
@property (nonatomic) CGFloat rangeOfOneMove;
@property (nonatomic) NSInteger timeElapsed;

@end

@implementation VAAudioPlayerController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"playlist"];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
    
    self.navigationController.toolbarHidden = YES;
    

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    [self configurateContent];
    
    __weak VAAudioPlayerController* weakSelf = self;
    [queue listenFeedbackUpdatesWithBlock:^(VAAudio *item) {

        if (!self.isRewindingFlag) {

        self.moovingView.centerX = (self.rangeOfOneMove * item.timePlayed + self.currentTimeView.width / 2);
            
        self.timeElapsedView.width = self.moovingView.centerX;
        self.timeElapsedLabel.text = [weakSelf timeFormatted:item.timePlayed];
        
        NSInteger timeRemaining = [item.duration integerValue] - item.timePlayed;
        self.timeRemainingLabel.text = [NSString stringWithFormat:@"-%@", [weakSelf timeFormatted:timeRemaining]];
            
        }
    } andFinishedBlock:^(VAAudio *nextItem) {
        
    }];

    
    [self updateContent];
    
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

#pragma mark - UI

- (void) configurateContent{
    
    CGFloat width = self.view.width;
    
    CGRect lyricsViewRect = CGRectMake(width, 0, width, width - self.pageControl.height);
    CGRect albumCoverRect = CGRectMake(0, 0, width, width);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.audioTitleLabel.adjustsFontSizeToFitWidth = YES;
        self.audioTitleLabel.minimumScaleFactor = 0.5;
        self.artistLabel.adjustsFontSizeToFitWidth = YES;
        self.artistLabel.minimumScaleFactor = 0.5;
        
        self.volumeSlider.tintColor = [UIColor redColor];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        self.contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
        //cover of album
        
        self.albumCover = [[UIImageView alloc] initWithFrame:albumCoverRect];
        
        self.albumCover.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentScrollView addSubview:self.albumCover];
        
        //lyrics
        
        self.lyricsView = [[UITextView alloc] initWithFrame:lyricsViewRect];
        
        self.lyricsView.editable = NO;
        
        self.lyricsView.textAlignment = NSTextAlignmentNatural;
        
        [self.contentScrollView addSubview:self.lyricsView];
        
        self.lyricsView.backgroundColor = [UIColor clearColor];
        
        self.lyricsView.textColor = [UIColor whiteColor];
        
        [self.lyricsView setFont:[UIFont systemFontOfSize:15]];
        
        self.contentScrollView.contentSize = CGSizeMake(width * 2, width);
    });
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)updateContent {
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    VAAudio *audio = [queue getCurrentItem];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [audio fetchMetadata];
        [self loadLyrics];
     
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat widthOfAvailableMovement = self.view.width - self.currentTimeView.width;
            CGFloat durationOfCurrentItem = [[[queue getCurrentItem]duration] floatValue];
            self.rangeOfOneMove = widthOfAvailableMovement / durationOfCurrentItem;
            
            self.moovingView.centerX = 0.f + self.currentTimeView.width / 2;
            self.timeElapsedView.width = self.moovingView.centerX;
            
            
            
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
            
            self.audioTitleLabel.text = audio.title;
            self.artistLabel.text = audio.artist;
            
            [self.playButton setImage: [UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
            
            NSInteger indexOfCurrentItem = [queue indexOfCurrentItem] + 1;
            NSUInteger coutOfAudiosInQueue = [[queue getQueueItems] count];
            
            self.navigationItem.title = [NSString stringWithFormat:@"%ld из %lu",
                                         (long)indexOfCurrentItem, coutOfAudiosInQueue];
        
        });
    });
    
}






#pragma mark - Player Actions

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

#pragma mark - Networking

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

#pragma mark - Gestures

- (void)handlePan: (UIPanGestureRecognizer *) panGesture {
    
    CGPoint touchLocation = [panGesture locationInView: self.view];
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    static VAAudio *audio = nil;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:
            
            break;
            
        case UIGestureRecognizerStateBegan:
            
            self.isRewindingFlag = YES;
            audio = [queue getCurrentItem];
            
            break;
            
        case UIGestureRecognizerStateChanged:

            self.moovingView.centerX = touchLocation.x;
            self.timeElapsedView.width = self.moovingView.centerX;
            
            self.timeElapsed = (self.moovingView.centerX - self.currentTimeView.width / 2) / self.rangeOfOneMove;
            
            self.timeElapsedLabel.text = [NSString stringWithFormat:@"%@", [self timeFormatted: self.timeElapsed]];
            
            NSInteger timeRemaining = [audio.duration integerValue] - self.timeElapsed;

            self.timeRemainingLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormatted: timeRemaining]];
            
            break;
            
        case UIGestureRecognizerStateEnded:

            [queue playAtSecond:self.timeElapsed ];
            
            self.isRewindingFlag = NO;
            
        case UIGestureRecognizerStateFailed:
            
            self.isRewindingFlag = NO;
            
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            self.isRewindingFlag = NO;
            
            break;
    }
    
}

#pragma mark - Helpers


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


#pragma mark - Navigation

- (void)goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
