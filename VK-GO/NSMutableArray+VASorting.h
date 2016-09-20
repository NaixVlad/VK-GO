//
//  NSMutableArray+VASorting.h
//  VK-GO
//
//  Created by Vladislav Andreev on 14.09.16.
//  Copyright © 2016 Vladislav Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (VASorting)

- (NSMutableArray*) sortedArrayInAlphabeticalOrderForKey: (NSString*) key;

@end
