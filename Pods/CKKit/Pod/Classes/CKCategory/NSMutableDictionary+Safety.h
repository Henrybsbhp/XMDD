//
//  NSMutableDictionary+Safety.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-26.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safety)

- (void)safetySetObject:(id)anObject forKey:(id)aKey;
- (void)safetyRemoveObjectForKey:(id)key;

@end
