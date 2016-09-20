//
//  VAFriendsConroller.m
//  VK-GO
//
//  Created by Vladislav Andreev on 20.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAFriendsController.h"
#import "VKUser.h"
//#import "VKApi.h"
#import "VKRequest.h"
#import "VKUtil.h"
#import "UIImageView+AFNetworking.h"
#import "VAAudioController.h"
#import "VASection.h"
#import "VKBatchRequest.h"
#import "NSMutableArray+VASorting.h"
#import "NSArray+VAFilter.h"

static NSString *const Friends_Fields = @"first_name,last_name, photo_50, counters";

@interface VAFriendsController () <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *friends;

@property (strong, nonatomic) VKUser *selectedFriend;

@property (strong, nonatomic) NSArray *sectionsArray;

@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation VAFriendsController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self loadFriends];
        [self generateSectionsInBackgroundFromArray:self.friends];

    });
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionsArray count];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    VASection* sec = [self.sectionsArray objectAtIndex:section];
    
    return [sec.itemsArray count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.sectionsArray objectAtIndex:section] sectionName];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    VASection* section = [self.sectionsArray objectAtIndex:indexPath.section];
    
    VKUser *friend = [section.itemsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.first_name, friend.last_name];
 
    NSURL *url = [NSURL URLWithString:friend.photo_50];
    
    __weak UITableViewCell *weakCell = cell;
    
    cell.imageView.image = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage: [UIImage imageNamed:@"defaultFriend"]
                                   success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
                                       weakCell.imageView.image = image;
                                       weakCell.imageView.image = [image vks_roundCornersImage:25.f
                                                                                    resultSize:CGSizeMake(50, 50)];
                                       [weakCell layoutSubviews];
                                   } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                                       NSLog(@"%@", error.localizedDescription);
                                   }];

    return cell;

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray* array = [NSMutableArray array];
    
    for (VASection* section in self.sectionsArray) {
        if (section.sectionName.length <= 1) {
            [array addObject:section.sectionName];
        } else {
            [array addObject:@"🔍"];
        }
    }
    
    return array;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VASection* section = [self.sectionsArray objectAtIndex:indexPath.section];
    self.selectedFriend = [section.itemsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"friendMusic" sender:nil];
    
}


#pragma mark - Networking

- (void)loadFriends {

    VKRequest *importantFriendsRequest = [[VKApi friends] get:@{VK_API_FIELDS : Friends_Fields, @"order" : @"hints" , @"count" : @(5)}];
    VKRequest *friendsRequest = [[VKApi friends] get:@{VK_API_FIELDS : Friends_Fields}];
    
    __block VKUsersArray *importantUsers;
    __block VKUsersArray *users;
    __block NSArray *sortedArray;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    VKBatchRequest *batch = [[VKBatchRequest alloc] initWithRequests:importantFriendsRequest, friendsRequest, nil];
    
    [batch executeWithResultBlock:^(NSArray *responses) {
        
        importantUsers = [(VKResponse*)[responses objectAtIndex:0] parsedModel];
        users = [(VKResponse*)[responses objectAtIndex:1] parsedModel];
        sortedArray = [users.items sortedArrayInAlphabeticalOrderForKey:@"last_name"];

        dispatch_semaphore_signal(sem);
    } errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    [importantUsers.items addObjectsFromArray:sortedArray];

    self.friends = importantUsers.items;
    
    
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {

    [searchBar setShowsCancelButton:NO animated:YES];
    self.sectionsArray = [self generateSectionsFromArray:self.friends];
    [self.tableView reloadData];

    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (!([searchText length] == 0)) {
        [self filterArray:self.friends withString:searchText];
    } else {
        [self generateSectionsInBackgroundFromArray:self.friends];
    }

    
}

#pragma mark - Sections generation

- (void) generateSectionsInBackgroundFromArray:(NSMutableArray*) array {
    
    [self.currentOperation cancel];
    
    __weak VAFriendsController* weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSArray* sectionsArray = [weakSelf generateSectionsFromArray:array];
        weakSelf.sectionsArray = sectionsArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView reloadData];
            
            self.currentOperation = nil;
        });
    }];
    
    [self.currentOperation start];
}

#pragma mark - Helpers

- (NSArray*) generateSectionsFromArray:(NSMutableArray*) array {
    
    NSMutableArray* sectionsArray = [NSMutableArray array];
    
    NSString *currentLetter = nil;
    
    VASection *firstSection = [self arrangeFirstSectionFromArray: array];
    [sectionsArray addObject:firstSection];
    
    NSRange rangeOfFriends = NSMakeRange(5, ([array count] - 5));
    NSArray *friends = [array subarrayWithRange:rangeOfFriends];
    
    for (VKUser* friend in friends) {
        
        NSString *lastName = friend.last_name;
        
        NSString* firstLetter = [lastName substringToIndex:1];
        
        VASection* section = nil;
        
        if (![currentLetter isEqualToString:firstLetter]) {
            section = [[VASection alloc] init];
            section.sectionName = firstLetter;
            section.itemsArray = [NSMutableArray array];
            currentLetter = firstLetter;
            [sectionsArray addObject:section];
        } else {
            section = [sectionsArray lastObject];
        }
        
        [section.itemsArray addObject:friend];
        
    }
    
    return sectionsArray;
}


- (VASection*) arrangeFirstSectionFromArray: (NSMutableArray*) array {
    
    VASection *section = [[VASection alloc] init];
    
    NSRange rangeOfImportantFriends = NSMakeRange(0, 5);
    
    NSArray* importantFriends = [array subarrayWithRange:rangeOfImportantFriends];
    
    section.itemsArray = [[NSMutableArray alloc] initWithArray:importantFriends];
    
    section.sectionName = @"Важные";
    
    return section;
}

- (void) filterArray: (NSMutableArray*) array withString: (NSString*) string {
    
    NSRange rangeOfFriends = NSMakeRange(5, ([array count] -5));
    NSArray *friends = [array subarrayWithRange:rangeOfFriends];
    VASection* section = [[VASection alloc] init];
    section.sectionName = @"Поиск";
    section.itemsArray = [[NSMutableArray alloc] init];
    
    section.itemsArray = [[friends filterArrayWithFilter:string] mutableCopy];
    self.sectionsArray = @[section];

    __weak VAFriendsController* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    VAAudioController *vc = [segue destinationViewController];
    vc.audiosRequest = [VKApi requestWithMethod:@"audio.get" andParameters:@{@"owner_id" : self.selectedFriend.id}];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", self.selectedFriend.first_name, self.selectedFriend.last_name];
    
    vc.navigationItem.title = title;
    
}


@end
