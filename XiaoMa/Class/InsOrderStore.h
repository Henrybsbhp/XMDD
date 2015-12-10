//
//  InsOrderStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"
#import "JTQueue.h"

@interface InsOrderStore : HKUserStore

- (HKStoreEvent *)getAllInsOrders;
- (HKStoreEvent *)getInsOrderByID:(NSNumber *)orderID;

@end
