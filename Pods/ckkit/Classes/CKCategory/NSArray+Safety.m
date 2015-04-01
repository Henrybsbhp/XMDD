//
//  NSArray+ObjectAtIndex.m
//  JTReader
//
//  Created by jiangjunchen on 13-10-21.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

@implementation NSArray (Safety)

- (id)safetyObjectAtIndex:(NSUInteger)index
{
    if (self.count <= index)
    {
        return nil;
    }
    return [self objectAtIndex:index];
}

- (NSArray *)safetyArrayByAddingObjectsFromArray:(NSArray *)otherArray
{
    NSArray *newArray;
    if (!otherArray)
    {
        newArray = [self arrayByAddingObjectsFromArray:otherArray];
    }
    return newArray;
}

#pragma mark - create
+ (instancetype)safetyArrayWithObject:(id)anObject
{
    if (anObject)
    {
        return [self arrayWithObject:anObject];
    }
    return [self array];
}
@end

@implementation NSMutableArray (Safety)

- (BOOL)safetyAddObject:(id)object
{
    if (object)
    {
        [self addObject:object];
        return YES;
    }
    return NO;
}

- (BOOL)safetyExchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    if (self.count <= idx1 || self.count <= idx2)
    {
        return NO;
    }
    [self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    return YES;
}

- (BOOL)safetyRemoveObjectAtIndex:(NSUInteger)index
{
    if (self.count <= index)
    {
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
}

- (NSArray *)safetyRemoveObjectsFromIndex:(NSUInteger)index
{
    return [self safetyRemoveObjectsInRange:NSMakeRange(index, self.count-index)];
}

- (NSArray *)safetyRemoveObjectsBeforeIndex:(NSUInteger)index
{
    return [self safetyRemoveObjectsInRange:NSMakeRange(0, index+1)];
}

- (NSArray *)safetyRemoveObjectsInRange:(NSRange)range
{
    if (self.count < range.length)
    {
        return nil;
    }
    NSArray *removed = [self subarrayWithRange:range];
    [self removeObjectsInRange:range];
    return removed;
}

- (BOOL)safetyRemoveObject:(id)object
{
    if (object && [self containsObject:object])
    {
        [self removeObject:object];
        return YES;
    }
    return NO;
}

- (BOOL)safetyReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (self.count <= index || !anObject)
    {
        return NO;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
    return YES;
}

- (BOOL)safetyInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (!anObject)
    {
        return NO;
    }
    
    if (self.count <= index)
    {
        [self addObject:anObject];
    }
    else
    {
        [self insertObject:anObject atIndex:index];
    }
    return YES;
}

- (BOOL)safetyAddObjectsFromArray:(NSArray *)otherArray
{
    if (!otherArray)
    {
        return NO;
    }
    [self addObjectsFromArray:otherArray];
    return YES;
}

@end
