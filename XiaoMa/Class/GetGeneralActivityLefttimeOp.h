//
//  GetGeneralActivityLefttimeOp.h
//  XiaoMa
//
//  Created by jt on 15/11/18.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetGeneralActivityLefttimeOp : BaseOp

@property (nonatomic,copy)NSString * tradeType;

@property (nonatomic)NSTimeInterval rsp_lefttime;

@end
