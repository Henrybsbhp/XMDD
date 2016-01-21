//
//  CKDatasource.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKDatasource.h"

@interface CKDatasource ()
@property (nonatomic, strong) NSMutableDictionary *subDataDict;
@property (nonatomic, strong) NSMutableArray *subDataArray;
@end

@implementation CKDatasource

- (instancetype)initWithKey:(NSString *)dkey
{
    self = [super init];
    if (self) {
        _dataKey = dkey;
        _info = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)dataWithKey:(NSString *)dkey
{
    CKDatasource *data = [[self alloc] initWithKey:dkey];
    return data;
}

+ (instancetype)dataWithKey:(NSString *)dkey subDatas:(NSArray *)subDatas
{
    CKDatasource *data = [[self alloc] initWithKey:dkey];
    [data.subDataArray addObjectsFromArray:subDatas];
    return data;
}

+ (instancetype)dataWithKey:(NSString *)dkey info:(NSDictionary *)info
{
    CKDatasource *data = [[self alloc] initWithKey:dkey];
    [data.info setDictionary:info];
    return data;
}

- (instancetype)subDataByID:(NSString *)did
{
    return self.subDataDict[did];
}

- (void)addSubData:(CKDatasource *)subdata
{
    [self.subDataArray addObject:subdata];
    [self.subDataDict setObject:subdata forKey:subdata.dataKey];
}

- (void)addSubDatasFromArray:(NSArray *)subs
{
    for (CKDatasource *subdata in subs) {
        [self addSubData:subdata];
    }
}

- (void)removeSubDataForKey:(NSString *)subkey
{
    if (subkey) {
        CKDatasource *subdata = _subDataDict[subkey];
        [self.subDataArray safetyRemoveObject:subdata];
    }
}

- (void)removeSubDataAtIndex:(NSInteger)index
{
    CKDatasource *subdata = [self.subDataArray safetyObjectAtIndex:index];
    if (subdata) {
        [self.subDataDict removeObjectForKey:subdata.dataKey];
    }
}

- (void)insertSubData:(CKDatasource *)subdata atIndex:(NSInteger)index
{
    if (subdata) {
        [self.subDataArray safetyInsertObject:subdata atIndex:index];
        [self.subDataDict safetySetObject:subdata forKey:subdata.dataKey];
    }
}

- (CKDatasource *)subDataAtIndex:(NSInteger)index
{
    return [self.subDataArray safetyObjectAtIndex:index];
}

- (CKDatasource *)subDataForKey:(NSString *)subkey
{
    if (subkey) {
        return [self.subDataDict objectForKey:subkey];
    }
    return nil;
}

- (NSArray *)allSubDatas
{
    return [NSArray arrayWithArray:self.subDataArray];
}

- (NSUInteger)countOfSubDatas
{
    return [self.subDataArray count];
}
#pragma mark - Utility
- (NSMutableDictionary *)subDataDict
{
    if (!_subDataDict) {
        _subDataDict = [NSMutableDictionary dictionary];
    }
    return _subDataDict;
}

- (NSMutableArray *)subDataArray
{
    if (!_subDataArray) {
        _subDataArray = [NSMutableArray array];
    }
    return _subDataArray;
}

@end

#pragma mark - C语言扩展
CKDataBlock2 CKDataGetCellHeight(CKDataBlock2 block)
{
    return [block copy];
}

CKDataBlock3 CKDataPrepareCell(CKDataBlock3 block)
{
    return [block copy];
}

CKDataBlock1 CKDataSelectCell(CKDataBlock1 block)
{
    return [block copy];
}
