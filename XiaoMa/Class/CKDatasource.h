//
//  CKDatasource.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

///info的默认Key
#define kCKCellID           @"__cellid"
#define kCKGetCellHeight    @"__getcellheight"
#define kCKPrepareCell      @"__preparecell"
#define kCKSelectCell       @"__selectcell"

@interface CKDatasource : NSObject
@property (nonatomic, strong, readonly) NSString *dataKey;
@property (nonatomic, strong, readonly) NSMutableDictionary *info;
///用于触发KVO的刷新。(用法：在页面上先用KVO监听该属性，在info发生改变时，设置 forceRerend = !forceRerend，即可通知页面刷新)
@property (nonatomic, assign) BOOL forceRerend;

+ (instancetype)dataWithKey:(NSString *)dkey subDatas:(NSArray *)subDatas;
+ (instancetype)dataWithKey:(NSString *)dkey info:(NSDictionary *)info;
+ (instancetype)dataWithKey:(NSString *)dkey;

- (void)addSubData:(CKDatasource *)subdata;
- (void)addSubDatasFromArray:(NSArray *)subs;
- (void)removeSubDataForKey:(NSString *)subkey;
- (void)removeSubDataAtIndex:(NSInteger)index;
- (void)insertSubData:(CKDatasource *)subdata atIndex:(NSInteger)index;
- (CKDatasource *)subDataAtIndex:(NSInteger)index;
- (CKDatasource *)subDataForKey:(NSString *)subkey;
- (NSArray *)allSubDatas;
- (NSUInteger)countOfSubDatas;

@end

#pragma mark - C语言扩展(主要为了自动补全block)
#if defined __cplusplus
extern "C"
{
#endif
    typedef void (^CKDataBlock1)(CKDatasource *data);
    typedef CGFloat (^CKDataBlock2)(CKDatasource *data);
    typedef UITableViewCell *(^CKDataBlock3)(CKDatasource *data, UITableViewCell *cell);
    
    CKDataBlock2 CKDataGetCellHeight(CKDataBlock2 block);
    CKDataBlock3 CKDataPrepareCell(CKDataBlock3 block);
    CKDataBlock1 CKDataSelectCell(CKDataBlock1 block);
#if defined __cplusplus
};
#endif


