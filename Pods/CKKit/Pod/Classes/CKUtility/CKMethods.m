//
//  CKMethods.m
//  JTReader
//
//  Created by jiangjunchen on 13-10-18.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKMethods.h"

int CKRoundto(float f)
{
    int i = floor(f);
    return i + (f - i < 0.5 ? 0 : 1);
}

//GCD主队列
void CKAsyncMainQueue(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

//GCD高优先级的默认全局队列
void CKAsyncHighQueue(dispatch_block_t block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

//GCG默认优先级的默认全局队列
void CKAsyncDefaultQueue(dispatch_block_t block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

//dispath_after
void CKAfter(float delay, dispatch_block_t block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

CGSize CKNarrowSize(CGSize oldSize, CGSize maxSize)
{
    //长和宽都小于压缩大小，不压缩
    if (oldSize.height < maxSize.height && oldSize.width < maxSize.width)
    {
        return oldSize;
    }
    if (maxSize.height == 0)
    {
        oldSize.height = 0;
        oldSize.width = MIN(maxSize.width, oldSize.width);
    }

    CGFloat thumbnailScale = maxSize.width/maxSize.height;
    CGFloat scale = oldSize.width/oldSize.height;
    CGSize newSize = maxSize;
    if (scale > thumbnailScale)
    {
        newSize.width = maxSize.width;
        newSize.height = newSize.width/scale;
    }
    else
    {
        newSize.height = maxSize.height;
        newSize.width = newSize.height*scale;
    }
    return newSize;
}

@implementation CKMethods


+ (NSUInteger)randomIntBetweenNumber:(NSUInteger)minNumber andNumber:(NSUInteger)maxNumber
{
    if (minNumber > maxNumber)
    {
        return [self randomIntBetweenNumber:maxNumber andNumber:minNumber];
    }

    NSUInteger i = (arc4random() % (maxNumber - minNumber + 1)) + minNumber;

    return i;
}


@end
