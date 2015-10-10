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

@property (nonatomic, strong) JTQueue *cache;

- (RACSignal *)rac_getAllInsOrders;
- (RACSignal *)rac_getInsOrderByID:(NSNumber *)orderID;

+ (void)reloadOrderByID:(NSNumber *)orderid;

@end
