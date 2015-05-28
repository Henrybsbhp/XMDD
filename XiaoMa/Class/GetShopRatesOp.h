//
//  GetShopRatesOp.h
//  XiaoMa
//
//  Created by jt on 15-4-15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetShopRatesOp : BaseOp

///商户ID
@property (nonatomic,strong)NSNumber * shopId;

///分页数
@property (nonatomic)NSInteger pageno;

///评价总数
@property (nonatomic)NSInteger rsp_totalNum;

@property (nonatomic,strong)NSArray * rsp_shopCommentArray;

@end
