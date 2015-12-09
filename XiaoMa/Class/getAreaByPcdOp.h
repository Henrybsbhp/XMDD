//
//  getAreaByPcdOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKLocationDataModel.h"

@interface getAreaByPcdOp : BaseOp

@property (nonatomic, strong)NSString *req_province;
@property (nonatomic, strong)NSString *req_city;
@property (nonatomic, strong)NSString *req_district;

@property (nonatomic, strong)HKAreaInfoModel *rsp_province;
@property (nonatomic, strong)HKAreaInfoModel *rsp_city;
@property (nonatomic, strong)HKAreaInfoModel *rsp_district;

@end
