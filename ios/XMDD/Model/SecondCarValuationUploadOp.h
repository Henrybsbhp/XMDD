//
//  SecondCarValuationUploadOp.h
//  XiaoMa
//
//  Created by RockyYe on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface SecondCarValuationUploadOp : BaseOp

//车记录ID
@property (nonatomic,strong) NSNumber *req_carId;
//车主名
@property (nonatomic,strong) NSString *req_contatName;
//联系电话
@property (nonatomic,strong) NSString *req_contatPhone;
//渠道英文名称,多个以逗号分隔
@property (nonatomic,strong) NSString *req_channelEngs;
//渠道英文名称,多个以逗号分隔
@property (nonatomic,strong) NSNumber *req_sellercityid;



@end
