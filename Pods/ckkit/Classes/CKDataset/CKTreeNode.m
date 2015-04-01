//
//  CKTreeNode.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-5.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKTreeNode.h"

@implementation CKTreeNode
@synthesize parentNode = _parentNode;

- (id)initWithKey:(NSString *)key
{
    self = [self init];
    _key = key ? key : [NSString stringWithFormat:@"%p", (__bridge void *)self];
    return self;
}

+ (CKTreeNode *)nodeWithKey:(NSString *)key
{
    CKTreeNode *node = [[CKTreeNode alloc] initWithKey:key];
    return node;
}

#pragma mark - Add node
- (void)addChildNode:(CKTreeNode *)node
{
    if (!_childNodeDict)
    {
        _childNodeDict = [[NSMutableDictionary alloc] init];
    }
    [_childNodeDict setObject:node forKey:node.key];
    node->_parentNode = self;
}

#pragma mark - Get node
- (NSArray *)allChildNodes
{
    return _childNodeDict.allValues;
}

- (CKTreeNode *)childNodeForKey:(NSString *)key
{
    return [_childNodeDict objectForKey:key];
}

#pragma mark - Remove node
- (void)removeChildNodeForKey:(NSString *)key
{
    [_childNodeDict removeObjectForKey:key];
}

- (void)removeAllChildNodes
{
    [_childNodeDict removeAllObjects];
}

- (void)removeFromParentNode
{
    [self.parentNode removeChildNodeForKey:self.key];
}

@end
