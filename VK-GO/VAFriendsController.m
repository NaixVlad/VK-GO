//
//  VAFriendsConroller.m
//  VK-GO
//
//  Created by Vladislav Andreev on 20.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAFriendsController.h"
#import "VKUser.h"
#import "VKApi.h"
#import "VKRequest.h"
#import "VKUtil.h"
#import "UIImageView+AFNetworking.h"
#import "VAAudioController.h"

static NSString *const Friends_Fields = @"first_name,last_name, photo_50";

@interface VAFriendsController ()

@property (strong, nonatomic) VKUsersArray *friends;
@property (strong, nonatomic) VKUser *selectedFriend;

@end

@implementation VAFriendsController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadFriends];
    });

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {

    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"%lu", (unsigned long)self.friends.count);
    
    return self.friends.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"friendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSLog(@"%lu", indexPath.row);
    
    VKUser *friend = [[VKUser alloc] init];
    
    friend = [self.friends objectAtIndex:indexPath.row];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text = [friend.first_name stringByAppendingFormat: @" %@", friend.last_name];
    
    NSLog(@"%@", [friend.first_name stringByAppendingFormat: @" %@", friend.last_name]);
    NSLog(@"%@", cell.textLabel.text);
    
    NSURL *url = [NSURL URLWithString:friend.photo_50];

    __weak UITableViewCell *weakCell = cell;
    
    cell.imageView.image = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage: [UIImage imageNamed:@"defaultFriend"]
                                   success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
                                       weakCell.imageView.image = image;
                                       weakCell.imageView.image = [image vks_roundCornersImage:25.f resultSize:CGSizeMake(50, 50)];
                                       [weakCell layoutSubviews];
                                   } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                                       NSLog(@"%@", error.localizedDescription);
                                   }];

    return cell;

}

#pragma mark - Networking

- (void)loadFriends {
    
    __block VKUsersArray *users;
    VKRequest *request = [[VKApi friends] get:@{VK_API_FIELDS : Friends_Fields}];
    request.waitUntilDone = YES;
    
    [request executeWithResultBlock:^(VKResponse *response) {
        users = response.parsedModel;
    }                    errorBlock:nil];
    
    self.friends = users;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedFriend = [self.friends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"friendMusic" sender:nil];
    
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
    
    VAAudioController *vc = [segue destinationViewController];
    vc.audiosRequest = [VKApi requestWithMethod:@"audio.get" andParameters:@{@"owner_id" : self.selectedFriend.id}];
    
}

@end
