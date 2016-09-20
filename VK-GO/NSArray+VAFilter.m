//
//  NSArray+VAFilter.m
//  VK-GO
//
//  Created by Vladislav Andreev on 18.09.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import "NSArray+VAFilter.h"

@implementation NSArray (VAFilter)


- (NSArray*) filterArrayWithFilter:(NSString*) filterString{
    
    NSString *filter=[NSString stringWithFormat:@"last_name contains[c] '%@' OR first_name contains[c] '%@'", filterString, filterString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filter];
    NSArray *filteredArray = [self filteredArrayUsingPredicate:predicate];
    
    return filteredArray;
    
}
@end
