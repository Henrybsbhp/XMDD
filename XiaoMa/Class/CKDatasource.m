//
//  CKDatasource.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKDatasource.h"

@implementation CKItem

#pragma mark - 数据元素
+ (instancetype)itemWithInfo:(NSDictionary *)info
{
    CKItem *item = [[self alloc] init];
    if (info) {
        item->_info = [NSMutableDictionary dictionaryWithDictionary:info];
    }
    else {
        item->_info = [NSMutableDictionary dictionary];
    }
    return item;
}

- (void)setItemKey:(id<NSCopying>)key
{
    self.info[kCKItemKey] = key;
}

- (id)itemKey
{
    return self.info[kCKItemKey];
}

@end


#pragma mark - CKQueue扩展
@implementation CKQueue (Datasource)
static char s_itemKey;

- (void)setItemKey:(id<NSCopying>)key
{
    objc_setAssociatedObject(self, &s_itemKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)itemKey
{
    return objc_getAssociatedObject(self, &s_itemKey);
}

- (void)addSubQueue:(CKQueue *)subq
{
    [self addObject:subq forKey:subq.itemKey];
    [self setDictionary:subq.dictionary];
}

- (void)addSubQueueList:(NSArray *)subqs
{
    for (CKQueue *subq in subqs) {
        [self addSubQueue:subq];
    }
}


#pragma mark - C语言扩展
CKCellSelectedBlock CKCellSelected(CKCellSelectedBlock block)
{
    return [block copy];
}

CKCellGetHeightBlock CKCellGetHeight(CKCellGetHeightBlock block)
{
    return [block copy];
}

CKCellPrepareBlock CKCellPrepare(CKCellPrepareBlock block)
{
    return [block copy];
}

CKItem *CKGenItem(NSDictionary *info)
{
    return [CKItem itemWithInfo:info];
}

CKQueue *CKGenQueue(id<CKQueueItemDelegate> firstObject, ...)
{
    CKQueue *queue = [CKQueue queue];
    va_list ap;
    va_start(ap, firstObject);
    id<CKQueueItemDelegate> obj = firstObject;
    while (obj) {
        [queue addObject:obj forKey:[obj itemKey]];
        obj = va_arg(ap, id);
    }
    va_end(ap);
    return queue;
}

CKQueue *CKPackQueue(CKQueue *firstQueue, ...)
{
    CKQueue *queue = [CKQueue queue];
    va_list ap;
    va_start(ap, firstQueue);
    CKQueue *subq = firstQueue;
    while (subq) {
        [queue addObject:subq forKey:nil];
        [queue setDictionary:subq.dictionary];
        subq = va_arg(ap, CKQueue *);
    }
    va_end(ap);
    return queue;
}

@end
