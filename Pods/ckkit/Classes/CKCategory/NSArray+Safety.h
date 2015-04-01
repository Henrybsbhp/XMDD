//
//  NSArray+ObjectAtIndex.h
//  JTReader
//
//  Created by jiangjunchen on 13-10-21.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safety)

- (id)safetyObjectAtIndex:(NSUInteger)index;
- (NSArray *)safetyArrayByAddingObjectsFromArray:(NSArray *)otherArray;

#pragma mark - create
+ (instancetype)safetyArrayWithObject:(id)anObject;
@end

@interface NSMutableArray (Safety)

#pragma mark - add
- (BOOL)safetyAddObject:(id)object;
- (BOOL)safetyInsertObject:(id)anObject atIndex:(NSUInteger)index;
- (BOOL)safetyAddObjectsFromArray:(NSArray *)otherArray;

#pragma mark - replace
- (BOOL)safetyExchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (BOOL)safetyReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

#pragma mark - remove
- (BOOL)safetyRemoveObjectAtIndex:(NSUInteger)index;
- (BOOL)safetyRemoveObject:(id)object;
- (NSArray *)safetyRemoveObjectsFromIndex:(NSUInteger)index;
- (NSArray *)safetyRemoveObjectsBeforeIndex:(NSUInteger)index;
- (NSArray *)safetyRemoveObjectsInRange:(NSRange)range;



@end
