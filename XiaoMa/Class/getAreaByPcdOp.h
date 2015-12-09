//
//  getAreaByPcdOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getAreaByPcdOp : BaseOp

@property (nonatomic, strong)NSString *req_province;
@property (nonatomic, strong)NSString *req_city;
@property (nonatomic, strong)NSString *req_district;

@property (nonatomic, strong)NSString *rsp_province;
@property (nonatomic, strong)NSString *rsp_city;
@property (nonatomic, strong)NSString *rsp_district;
@property (nonatomic, assign)NSInteger rsp_refId;

@end
