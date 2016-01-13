//
//  GetSystemHomePicOp.h
//  XiaoMa
//
//  Created by jt on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "HomePicModel.h"

@interface GetSystemHomePicOp : BaseOp

@property (nonatomic)NSInteger appid;
@property (nonatomic,copy)NSString * version;

@property (nonatomic,strong)HomePicModel * homeModel;

@end
