//
//  HKCellData.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKCellData.h"
#import "HKStore.h"

@implementation HKCellData
@synthesize cellID = _cellID, tag = _tag;

+ (HKCellData *)dataWithCellID:(NSString *)cellid tag:(id)tag
{
    HKCellData *data = [[HKCellData alloc] init];
    data->_cellID = cellid;
    data->_tag = tag;
    return data;
}

- (BOOL)equalByCellID:(NSString *)cellid tag:(id)tag
{
    if ([self.cellID equalByCaseInsensitive:cellid] && (!tag || [tag isEqual:self.tag])) {
        return YES;
    }
    return NO;
}

- (void)setInfoFrom:(NSDictionary *)dict
{
    if (dict) {
        if (!self.info) {
            _info = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
        else {
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [self.info setObject:obj forKey:key];
            }];
        }
    }
}

@end
