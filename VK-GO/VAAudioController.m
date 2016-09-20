//
//  VAAudioController.m
//  VK-GO
//
//  Created by Vladislav Andreev on 20.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudioController.h"
#import "VAAudioPlayerController.h"
#import "VAAudioManager.h"

static NSString *const RecomendationsRequest = @"audio.getRecommendations";
static NSString *const SearchRequest = @"audio.search";

@interface VAAudioController () <UISearchBarDelegate>

@property(strong, nonatomic) VKAudios *audios;

@end



@implementation VAAudioController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadAudios];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(changePlayIcon:) name:@"VAAudioChange" object:nil];
    
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

- (void) changePlayIcon: (NSNotification *) notification {
    
    for (int i = 0; i < [self.audios count]; i++) {

        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:i inSection: 0];
        
        [self.tableView deselectRowAtIndexPath:oldIndexPath animated:YES];
        
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
        oldCell.imageView.image = [UIImage imageNamed:@"playButton"];
    }
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    VAAudio *currentItemInQueue = [queue getCurrentItem];
    VAAudio *currentItemInTableView = [self.audios.items objectAtIndex:[queue indexOfCurrentItem]];
    
    if ([currentItemInQueue isEqual:currentItemInTableView]){
    
        NSInteger row = [queue indexOfCurrentItem];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection: 0];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
        newCell.imageView.image = [UIImage imageNamed:@"pauseButton"];
        
    }

}

#pragma mark - Networking

- (void)loadAudios {
    
    __block NSMutableArray *audiosArray;
    
    VKUser *localUser = [[VKSdk accessToken] localUser];
    if ([self.navigationController.restorationIdentifier isEqual: @"recomendations"]) {
        self.audiosRequest = [VKApi requestWithMethod:RecomendationsRequest andParameters:@{@"user_id" : localUser.id}];
        self.navigationItem.title = @"Рекомендации";
    } else if ([self.navigationController.restorationIdentifier isEqual: @"myMusic"]) {
        self.audiosRequest = [VKApi requestWithMethod:@"audio.get" andParameters:@{@"owner_id" : localUser.id}];
        self.navigationItem.title = @"Мои аудиозаписи";
    }
    
    self.audiosRequest.waitUntilDone = YES;
    
    [self.audiosRequest executeWithResultBlock:^(VKResponse *response) {
        
        audiosArray = [response.json objectForKey:@"items"];

    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
    self.audios = [[VKAudios alloc] initWithArray:audiosArray objectClass:[VAAudio class]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });


}

- (void)searchAudiosForString: (NSString *) searchString {
    
    __block NSMutableArray *audiosArray;

    VKRequest *searchRequest = [VKApi requestWithMethod:SearchRequest andParameters:@{@"q" : searchString}];
    searchRequest.waitUntilDone = YES;

    [searchRequest executeWithResultBlock:^(VKResponse *response) {
        
        audiosArray = [response.json objectForKey:@"items"];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
    self.audios = [[VKAudios alloc] initWithArray:audiosArray objectClass:[VAAudio class]];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.audios count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    
    VKAudio *audio = [[VKAudio alloc] init];
    
    audio = [self.audios objectAtIndex:indexPath.row];
    
    cell.textLabel.text = audio.title;
    
    cell.detailTextLabel.text = audio.artist;
    
    VAAudio *currentItemInQueue = [[VAAudioQueue sharedQueueManager] getCurrentItem];
    VAAudio *currentItemInTableView = [self.audios.items objectAtIndex:indexPath.row];
    
    if (!([currentItemInQueue isEqual:currentItemInTableView])){
        
        cell.imageView.image = [UIImage imageNamed:@"playButton"];
        
    } else {
        
        cell.imageView.image = [UIImage imageNamed:@"pauseButton"];
        
    }
    
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    NSInteger indexOfCurrentItem = [queue indexOfCurrentItem];
    NSMutableArray *playerQueue = [queue getQueueItems];
    
    BOOL isArraysDifferent = ![self.audios.items isEqual: playerQueue];
    
    if (isArraysDifferent) {
        
        [queue setQueueItems: self.audios.items];

    }
    
    if ((!(indexOfCurrentItem == indexPath.row)) || isArraysDifferent ) { 
        
        [queue playItemAtIndex:indexPath.row];
        
    }
    

    [self performSegueWithIdentifier:@"OpenPlayer" sender:nil];


}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self loadAudios];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (!([searchText length] == 0)) {
        [self searchAudiosForString:searchText];
    } else {
        [self loadAudios];
    }
    
}



@end
