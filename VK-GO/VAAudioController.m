//
//  VAAudioController.m
//  VK-GO
//
//  Created by Vladislav Andreev on 20.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudioController.h"

#import "VAAudioManager.h"


@interface VAAudioController ()

@property(strong, nonatomic) VKAudios *audios;

@end



@implementation VAAudioController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadAudios];
    });
    
    
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
    
    static NSInteger row;
    
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:row inSection: 0];
    
    [self.tableView deselectRowAtIndexPath:oldIndexPath animated:YES];
    
    UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
    oldCell.imageView.image = [UIImage imageNamed:@"playButton"];
    
    VAAudioQueue *queue = [VAAudioQueue sharedQueueManager];
    
    row = [queue indexOfCurrentItem];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection: 0];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
    newCell.imageView.image = [UIImage imageNamed:@"pauseButton"];
    

}

#pragma mark - Networking

- (void)loadAudios {
    
    __block NSMutableArray *audiosArray;
    
    if (!self.audiosRequest) {
        
        VKUser *localUser = [[VKSdk accessToken] localUser];
        self.audiosRequest = [VKApi requestWithMethod:@"audio.get" andParameters:@{@"owner_id" : localUser.id}];
        
    }
    
    self.audiosRequest.waitUntilDone = YES;
    
    [self.audiosRequest executeWithResultBlock:^(VKResponse *response) {
        
        audiosArray = [[NSMutableArray alloc] initWithArray:[response.json objectForKey:@"items"]];

    } errorBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
    self.audios = [[VKAudios alloc] initWithArray:audiosArray objectClass:[VAAudio class]];
    
    [[VAAudioQueue sharedQueueManager] setQueueItems: self.audios.items];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.audios count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"songIdentidier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    VKAudio *audio = [[VKAudio alloc] init];
    
    audio = [self.audios objectAtIndex:indexPath.row];
    
    cell.textLabel.text = audio.title;
    
    cell.detailTextLabel.text = audio.artist;
    
    cell.imageView.image = [UIImage imageNamed:@"playButton"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];

    [[VAAudioQueue sharedQueueManager] playItemAtIndex:indexPath.row];
    
    /*
    VKAudio *selectedAudio = [[VKAudio alloc] init];
    
    selectedAudio = [self.audios objectAtIndex:indexPath.row];
    
    NSString *stringURL = selectedAudio.url;
    
    NSURL *url = [NSURL URLWithString: stringURL];
    
    [self playselectedsong:url];*/

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //VAAudioPlayerController *vc = [segue destinationViewController];
    
    //vc.queue = [[VAAudioQueue alloc]initWithItems:self.audios.items];
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
