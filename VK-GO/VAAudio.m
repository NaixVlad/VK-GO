//
//  VAAudio.m
//  VK-GO
//
//  Created by Vladislav Andreev on 22.06.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "VAAudio.h"
#import "VAAudioManager.h"

@implementation VAAudio

-(void)fetchMetadata {
    
    NSURL *url = [NSURL URLWithString:self.url];
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    NSArray *metadata = [playerItem.asset commonMetadata];
    
    for (AVMetadataItem *metadataItem in metadata) {
        
        [metadataItem loadValuesAsynchronouslyForKeys:@[AVMetadataKeySpaceCommon] completionHandler:^{
            
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
                    self.artwork = [UIImage imageWithData:metadataItem.dataValue];
                } else {
                    NSDictionary *dict;
                    [metadataItem.value copyWithZone:nil];
                    self.artwork = [UIImage imageWithData:[dict objectForKey:@"data"]];
                }
            }
        }];
    }
}


@end
