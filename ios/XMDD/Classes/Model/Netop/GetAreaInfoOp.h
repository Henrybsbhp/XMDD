//
//  GetAreaInfoOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKLocationDataModel.h"

typedef NS_ENUM(NSInteger, AreaType) {
    AreaTypeProvince = 1,
    AreaTypeCity = 2,
    AreaTypeDicstrict
};

@interface GetAreaInfoOp : BaseOp

@property (nonatomic, assign) long long req_updateTime;
@property (nonatomic)NSInteger req_type;
@property (nonatomic)NSInteger req_areaId;

@property (nonatomic, strong)NSArray *rsp_areaArray;
@property (nonatomic, assign)long long rsp_maxTime;

@end
