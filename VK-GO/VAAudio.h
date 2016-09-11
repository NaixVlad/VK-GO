//
//  VAAudio.h
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VKSdk.h"

@interface VAAudio : VKAudio

@property (nonatomic) NSInteger timePlayed;
@property (nonatomic) UIImage *artwork;
@property (nonatomic) NSString *lyrics;

-(void)fetchMetadata;

@end
