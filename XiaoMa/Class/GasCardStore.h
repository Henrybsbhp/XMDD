//
//  GasCardStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"

enum : NSInteger {
    kGasGetAllCardBaseInfos = 1000,
    kGasGetCardNormalInfo,
    kGasGetCardCZBInfo
}GasCardEventCode;

@interface GasCardStore : HKUserStore

- (CKStoreEvent *)getAllCardBaseInfos;
- (CKStoreEvent *)getCardNormalInfoByGID:(NSNumber *)gid;
- (CKStoreEvent *)getCardCZBInfoByGID:(NSNumber *)gid CZBID:(NSNumber *)cid;

@end
