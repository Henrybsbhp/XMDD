//
//  HKUserStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKStore.h"

@interface HKUserStore : HKStore

///Override
- (void)reloadDataWithCode:(NSInteger)code;
@end
