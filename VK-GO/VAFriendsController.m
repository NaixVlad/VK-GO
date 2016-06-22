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
#import "SWRevealViewController.h"

static NSString *const FRIENDS_FIELDS = @"first_name,last_name, photo_50";

@interface VAFriendsController ()

@end

@implementation VAFriendsController

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.friends = [self loadUsers];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%lu", (unsigned long)self.friends.count);
    
    return self.friends.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"friendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    VKUser *friend = [[VKUser alloc] init];
    
    friend = [self.friends objectAtIndex:indexPath.row];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text = [friend.first_name stringByAppendingFormat: @" %@", friend.last_name];
    
    NSURL *url = [NSURL URLWithString:friend.photo_50];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];

    cell.imageView.image = [img vks_roundCornersImage:15.f resultSize:CGSizeMake(50, 50)];

    return cell;

}


- (VKUsersArray *)loadUsers {
    __block VKUsersArray *users;
    VKRequest *request = [[VKApi friends] get:@{VK_API_FIELDS : FRIENDS_FIELDS}];
    request.waitUntilDone = YES;
    
    [request executeWithResultBlock:^(VKResponse *response) {
        users = response.parsedModel;
    }                    errorBlock:nil];
    

    return users;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
