//
//  CKMethods.h
//  JTReader
//
//  Created by jiangjunchen on 13-10-18.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C"
{
#endif
    ///四舍五入
    int CKRoundto(float f);
    ///GCD主队列
    void CKAsyncMainQueue(dispatch_block_t block);
    ///GCD高优先级的默认全局队列
    void CKAsyncHighQueue(dispatch_block_t block);
    ///GCD默认优先级的默认全局队列
    void CKAsyncDefaultQueue(dispatch_block_t block);
    ///dispath_after
    void CKAfter(float delay, dispatch_block_t block);
    ///根据限定size，等比缩小原size到最合适的大小
    CGSize CKNarrowSize(CGSize oldSize, CGSize maxSize);
#if defined __cplusplus
};
#endif

@interface CKMethods : NSObject

///随机函数：从minNumber到maxNumber范围内生成一个随机数
+ (NSUInteger)randomIntBetweenNumber:(NSUInteger)minNumber andNumber:(NSUInteger)maxNumber;

@end
