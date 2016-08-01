//
//  CarEvaluateOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarEvaluateOp : BaseOp

@property (nonatomic)CGFloat req_mile;
@property (nonatomic, strong)NSNumber *req_modelid;
@property (nonatomic, strong)NSDate *req_buydate;
@property (nonatomic, strong)NSNumber *req_carid;
@property (nonatomic, strong)NSNumber *req_cityid;
@property (nonatomic, strong)NSString *req_licenseno;


@property (nonatomic)CGFloat rsp_normalPrice;
@property (nonatomic)CGFloat rsp_betterPrice;
@property (nonatomic)CGFloat rsp_bestPrice;
@property (nonatomic, copy)NSString *rsp_url;
@property (nonatomic, copy)NSString *rsp_tip;
@property (nonatomic, strong)NSNumber *rsp_carid;
@property (nonatomic, strong)NSString *rsp_sharecode;

@end
