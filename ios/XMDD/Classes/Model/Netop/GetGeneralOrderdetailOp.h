//
//  GetGeneralOrderdetailOp.h
//  XiaoMa
//
//  Created by jt on 15/11/16.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetGeneralOrderdetailOp : BaseOp

@property (nonatomic,copy)NSString * tradeNo;
@property (nonatomic,copy)NSString * tradeType;

@property (nonatomic,copy)NSString * rsp_prodlogo;

@property (nonatomic,copy)NSString * rsp_prodname;

@property (nonatomic,copy)NSString * rsp_proddesc;

@property (nonatomic)CGFloat rsp_originprice;

@property (nonatomic)CGFloat rsp_couponprice;

@property (nonatomic)CGFloat rsp_fee;

@property (nonatomic,strong)NSArray * rsp_paychannels;

@property (nonatomic,strong)NSArray * rsp_czbCards;

@end
