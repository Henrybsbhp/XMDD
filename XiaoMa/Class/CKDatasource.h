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

@protocol CKItemDelegate <NSObject>

- (id<NSCopying>)key;
- (instancetype)setKey:(id<NSCopying>)key;

@end



@interface CKList : CKQueue<CKItemDelegate>

+ (instancetype)list;
+ (instancetype)listWithArray:(NSArray *)array;

@end



@interface CKDict : NSObject<CKItemDelegate>

@property (nonatomic, assign) BOOL forceReload;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (CKDict *)dictWith:(NSDictionary *)dict;
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;
- (id)objectForKeyedSubscript:(id)key;

@end



#pragma mark - C语言扩展(主要为了自动补全block以及简化方法调用)

#if defined __cplusplus
extern "C"
{
#endif
    typedef void (^CKCellSelectedBlock)(CKDict *data, NSIndexPath *indexPath);
    typedef CGFloat (^CKCellGetHeightBlock)(CKDict *data, NSIndexPath *indexPath);
    typedef void(^CKCellPrepareBlock)(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath);

    CKCellSelectedBlock CKCellSelected(CKCellSelectedBlock block);
    CKCellGetHeightBlock CKCellGetHeight(CKCellGetHeightBlock block);
    CKCellPrepareBlock CKCellPrepare(CKCellPrepareBlock block);
    
    CKList *CKGenList(id firstObject, ...) NS_REQUIRES_NIL_TERMINATION;

#define $(...) CKGenList(__VA_ARGS__,nil)
#if defined __cplusplus
};
#endif




