//
//  GetSystemPromotionOp.h
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKAdvertisement.h"

@interface GetSystemPromotionOp : BaseOp

@property (nonatomic)AdvertisementType type;

@property (nonatomic,strong)NSArray * rsp_advertisementArray;

@end
