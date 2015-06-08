//
//  GetSystemVersionOp.h
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetSystemVersionOp : BaseOp

///标识客户端的类型与版本 1001:安卓端版本 01 2001:IOS 端版本 01
@property (nonatomic)NSInteger appid;

///当前客户端运行的版本编号
@property (nonatomic,copy)NSString * version;

///当前客户端运行的操作系统及编号,格式: iOS 7.0.2;Android 4.3.1
@property (nonatomic,copy)NSString * os;

///更新版本号
@property (nonatomic,copy)NSString * rsp_version;

///是否强制更新
@property (nonatomic)BOOL rsp_mandatory;

///更新地址
@property (nonatomic,copy)NSString * rsp_link;

///更新内容
@property (nonatomic,copy)NSString * rsp_updateinfo;

@end
