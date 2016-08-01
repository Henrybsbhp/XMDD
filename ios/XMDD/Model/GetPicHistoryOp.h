//
//  GetPicHistoryOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "PictureRecord.h"

@interface GetPicHistoryOp : BaseOp
@property (nonatomic, assign) NSInteger req_picType;
@property (nonatomic, strong) NSArray *rsp_records;
@end
