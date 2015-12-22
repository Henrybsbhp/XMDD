//
//  ShareUserCouponOp.h
//  XiaoMa
//
//  Created by jt on 15-5-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface ShareUserCouponOp : BaseOp

@property (nonatomic,strong)NSNumber * cid;

@property (nonatomic,copy)NSString * rsp_linkUrl;

@property (nonatomic,copy)NSString * rsp_weiboUrl;

@property (nonatomic,copy)NSString * rsp_wechatUrl;

@property (nonatomic,copy)NSString * rsp_content;

@property (nonatomic,copy)NSString * rsp_title;

@end
