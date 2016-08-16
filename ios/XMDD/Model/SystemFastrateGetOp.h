//
//  SystemFastrateGetOp.h
//  XiaoMa
//
//  Created by jt on 15/9/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "JTShop.h"

@interface SystemFastrateGetOp : BaseOp

/// 洗车服务的评论内容
@property (nonatomic,strong)NSArray * rsp_commentlist;

/// 保养服务的评论内容
@property (nonatomic,strong)NSArray * rsp_bycommentlist;

/// 美容服务的评论内容
@property (nonatomic,strong)NSArray * rsp_mrcommentlist;

@end
