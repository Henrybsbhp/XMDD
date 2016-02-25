//
//  CKDatasource.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKQueue.h"

///info的默认Key
#define kCKCellID           @"__cellid"
#define kCKCellGetHeight    @"__getcellheight"
#define kCKCellPrepare      @"__preparecell"
#define kCKCellSelected     @"__selectcell"

#define CKNULL     [NSNull null]
#define kCKItemKey      @"__itemkey"

@protocol CKQueueItemDelegate <NSObject>
- (void)setItemKey:(id<NSCopying>)key;
- (id)itemKey;

@end

///数据源元素
@interface CKItem : NSObject<CKQueueItemDelegate>
@property (nonatomic, strong, readonly) NSMutableDictionary *info;
@property (nonatomic, assign) BOOL forceRerend;
+ (instancetype)itemWithInfo:(NSDictionary *)info;

@end

///数据源结构
@interface CKQueue (Datasource)<CKQueueItemDelegate>
- (void)addSubQueue:(CKQueue *)subq;
- (void)addSubQueueList:(NSArray *)subqs;

@end



#pragma mark - C语言扩展(主要为了自动补全block以及简化方法调用)
#if defined __cplusplus
extern "C"
{
#endif
    typedef void (^CKCellSelectedBlock)(CKItem *data, NSIndexPath *indexPath);
    typedef CGFloat (^CKCellGetHeightBlock)(CKItem *data, NSIndexPath *indexPath);
    typedef void(^CKCellPrepareBlock)(CKItem *data, UITableViewCell *cell, NSIndexPath *indexPath);
    
    CKCellSelectedBlock CKCellSelected(CKCellSelectedBlock block);
    CKCellGetHeightBlock CKCellGetHeight(CKCellGetHeightBlock block);
    CKCellPrepareBlock CKCellPrepare(CKCellPrepareBlock block);
    
    CKItem *CKGenItem(NSDictionary *info);
    CKQueue *CKGenQueue(id<CKQueueItemDelegate> firstObject, ...) NS_REQUIRES_NIL_TERMINATION;
    CKQueue *CKPackQueue(CKQueue *firstQueue, ...) NS_REQUIRES_NIL_TERMINATION;
    
#if defined __cplusplus
};
#endif




