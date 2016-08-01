//
//  CKMap.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-8.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKMap : NSObject
- (void)addObjects:(NSArray *)objs forKey:(NSString *)key;
- (void)addObject:(id)obj forKey:(NSString *)key;
- (NSArray *)objectsForKey:(NSString *)key;
- (NSArray *)allKeys;
- (NSArray *)allObjects;
- (void)removeAllObjects;
@end
