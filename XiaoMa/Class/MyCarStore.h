//
//  MyCarStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"
#import "MyCarsModel.h"

@interface MyCarStore : HKUserStore
@property (nonatomic, strong) MyCarsModel *carModel;
@end
