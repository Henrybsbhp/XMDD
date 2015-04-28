//
//  UpdateInsuranceCalculateOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface UpdateInsuranceCalculateOp : BaseOp
@property (nonatomic, strong) NSString *req_cid;
@property (nonatomic, strong) NSString *req_idpic;
@property (nonatomic, strong) NSString *req_driverpic;
@property (nonatomic, strong) NSString *req_drivercopypic;

@end
