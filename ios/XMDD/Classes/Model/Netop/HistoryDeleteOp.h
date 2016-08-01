//
//  HistoryDeleteOp.h
//  XiaoMa
//
//  Created by RockyYe on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface HistoryDeleteOp : BaseOp

/**
 *  估值记录ID.多条记录以逗号隔开记录ID
 */
@property (nonatomic,copy) NSString *req_evaluateIds;

@end
