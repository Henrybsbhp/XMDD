//
//  GetAutomobileSeriesV2Op.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetAutomobileSeriesV2Op : BaseOp

@property (nonatomic, strong) NSNumber *req_brandid;
@property (nonatomic, strong) NSArray *rsp_seriesList;

@end
