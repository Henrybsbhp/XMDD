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
@property (nonatomic,copy)NSString * shopId;

///分页数
@property (nonatomic)NSInteger pageno;

@property (nonatomic,strong)NSArray * rsp_shopCommentArray;

@end
