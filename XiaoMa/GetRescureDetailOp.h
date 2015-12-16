//
//  GetRescureDetailOp.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescureDetailOp : BaseOp
@property (nonatomic, assign) NSInteger       rescueid;

@property (nonatomic, copy) NSString    * serviceObject;//服务对象
@property (nonatomic, copy) NSString    * feesacle;//收费标准
@property (nonatomic, copy) NSString    * serviceProject;//服务项目
@property (nonatomic, strong) NSMutableArray  * rescueDetailArray;//返回的是一个字典

@end
