//
//  SharedNotifyOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/1.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedNotifyOp : BaseOp

//分享通知渠道
@property (nonatomic, copy)NSString * req_channel;

//该分享是否有领券
@property (nonatomic, assign)NSInteger rsp_flag;

@end
