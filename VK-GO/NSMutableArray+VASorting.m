//
//  NSMutableArray+VASorting.m
//  VK-GO
//
//  Created by Vladislav Andreev on 14.09.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "NSMutableArray+VASorting.h"
#import "VKUser.h"

@implementation NSMutableArray (VASorting)

- (NSMutableArray*) sortedArrayInAlphabeticalOrderForKey: (NSString*) key{

    NSSortDescriptor *languageDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *alphabetDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    
    return (NSMutableArray*)[self sortedArrayUsingDescriptors:@[languageDescriptor,alphabetDescriptor]];

}

@end
