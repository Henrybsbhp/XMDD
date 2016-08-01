//
//  GetSystemHomeModuleOp.h
//  XiaoMa
//
//  Created by fuqi on 16/4/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "HomePicModel.h"

@interface GetSystemHomeModuleOp : BaseOp

@property (nonatomic)NSInteger appid;
@property (nonatomic,copy)NSString * version;
@property (nonatomic,copy)NSString * province;
@property (nonatomic,copy)NSString * city;
@property (nonatomic,copy)NSString * district;

@property (nonatomic,strong)HomePicModel * homeModel;
//@property (nonatomic,strong)NSArray<HomeItem *>* rsp_modulesArray;

@end
