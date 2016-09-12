//
//  VAAudioController.h
//  VK-GO
//
//  Created by Vladislav Andreev on 20.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKAudio.h"
#import "VKApi.h"
@import AVFoundation;

@interface VAAudioController : UITableViewController

@property(strong, nonatomic) VKRequest *audiosRequest;

@end
