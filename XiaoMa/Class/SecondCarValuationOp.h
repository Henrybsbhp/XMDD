//
//  SecondCarValuationOp.h
//  XiaoMa
//
//  Created by RockyYe on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface SecondCarValuationOp : BaseOp

//帮卖城市ID
@property (nonatomic,strong) NSNumber *req_sellerCityId;

//获取数据数组
@property (nonatomic,strong) NSArray *rsp_dataArr;

//获取数据数组
@property (nonatomic,strong) NSString *rsp_tip;

@end
