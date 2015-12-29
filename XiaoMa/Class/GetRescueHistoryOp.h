//
//  GetRescueHistoryOp.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescueHistoryOp : BaseOp
@property (nonatomic, assign) long long  applytime;
@property (nonatomic, assign) NSInteger  type;
@property (nonatomic, strong) NSArray *req_applysecueArray;
@end
