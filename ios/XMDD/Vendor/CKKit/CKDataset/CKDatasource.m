//
//  CKDatasource.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKDatasource.h"
#import <objc/runtime.h>

static char s_shouldBeSplicingKey;

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

CKCellWillDisplayBlock CKCellWillDisplay(CKCellWillDisplayBlock block)
{
    return [block copy];
}

CKList *__CKCreateList(id obj, va_list restobjs)
{
    CKList *list = [CKList queue];
    while (obj) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [[CKDict alloc] initWithDict:obj];
            [list addObject:obj forKey:nil];
        }
        else if ([obj isKindOfClass:[CKList class]] && objc_getAssociatedObject(obj, &s_shouldBeSplicingKey)) {
            [list addObjectsFromQueue:obj];
        }
        //如果为CKNULL直接忽略
        else if (![CKNULL isEqual:obj]) {
            [list addObject:obj forKey:nil];
        }
        obj = va_arg(restobjs, id);
    }
    return list;
}

CKList *CKGenList(id firstObject, ...)
{
    va_list ap;
    va_start(ap, firstObject);
    CKList *list = __CKCreateList(firstObject, ap);
    va_end(ap);
    return list;
}

CKList *CKSplicList(id firstObject, ...)
{
    va_list ap;
    va_start(ap, firstObject);
    CKList *list = __CKCreateList(firstObject, ap);
    objc_setAssociatedObject(list, &s_shouldBeSplicingKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    va_end(ap);
    return list;
}

CKList *CKJoinArray(NSArray *array)
{
    CKList *list = [CKList queue];
    for (id obj in array) {
        [list addObject:obj forKey:nil];
    }
    objc_setAssociatedObject(list, &s_shouldBeSplicingKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return list;
}
