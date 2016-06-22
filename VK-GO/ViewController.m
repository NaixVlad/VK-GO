//
//  ViewController.m
//  VK-GO
//
//  Created by Vladislav Andreev on 18.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "ViewController.h"
#import "VKSdk.h"
#import "VKUser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(UIButton *)sender {
    
    VKUser *user = [[VKUser alloc] init];
    
    if ([[VKSdk accessToken] localUser]) {
        
        user = [[VKSdk accessToken] localUser];
        
        self.userName.text = user.first_name;

    }

}
@end
