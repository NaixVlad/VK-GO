//
//  VAStartScreen.m
//  VK
//
//  Created by Vladislav Andreev on 03.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAStartScreen.h"


static NSString *const TokenKey = @"my_application_access_token";
static NSString *const NextControllerSegueId = @"startWork";
static NSString *const AppId = @"5334722";

@interface VAStartScreen () <UIAlertViewDelegate, VKSdkDelegate, VKSdkUIDelegate>

@property (strong, nonatomic) NSArray *scope;;

@end

@implementation VAStartScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scope = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
    [[VKSdk initializeWithAppId:AppId] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
    
    [VKSdk wakeUpSession: self.scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        switch (state) {
            case VKAuthorizationAuthorized:
                NSLog (@"User already autorized, and session is correct");
                [self startWorking];
                break;
                
            case VKAuthorizationInitialized:
                [VKSdk authorize: self.scope];
                break;
                
            default:
                NSLog (@"Probably, network error occured");
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Error"
                                             message:[error description]
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [VKSdk authorize: self.scope];
                                            }];
                
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                break;
        }
    }];

}

- (void)startWorking {
    [self performSegueWithIdentifier:NextControllerSegueId sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    NSLog(@"TokenHasExpired");
    [VKSdk authorize: self.scope];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        
        [self startWorking];
        
    } else if (result.error) {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error"
                                     message:[NSString stringWithFormat:@"Access denied\n%@", result.error]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 //
                             }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)vkSdkUserAuthorizationFailed {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Authorization Failed "
                                 message:@"Access denied"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             //
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

@end

