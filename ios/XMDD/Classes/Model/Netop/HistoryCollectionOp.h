//
//  HistoryCollectionOp.h
//  XiaoMa
//
//  Created by RockyYe on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface HistoryCollectionOp : BaseOp
/**
 *估值时间
 */
@property (nonatomic,strong) NSNumber *req_evaluateTime;

/**
 *  获取数据数组
 */
@property (nonatomic,strong) NSArray *rsp_dataArr;

@end
