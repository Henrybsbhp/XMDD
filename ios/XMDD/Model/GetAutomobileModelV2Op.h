//
//  GetAutomobileModelV2Op.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetAutomobileModelV2Op : BaseOp

@property (nonatomic, strong) NSNumber *req_seriesid;
@property (nonatomic, strong) NSArray *rsp_modelList;

@end
