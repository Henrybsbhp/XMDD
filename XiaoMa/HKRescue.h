//
//  HKRescue.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKRescue : NSObject
@property (nonatomic, copy)   NSString  * serviceName;//服务名称
@property (nonatomic ,copy)   NSString  * rescueDesc;//服务描述
@property (nonatomic, strong) NSNumber  * rescueID;//救援服务id
@property (nonatomic, copy)   NSString  * amount;//jine
@property (nonatomic, strong) NSNumber  * serviceCount;//剩余次数
@property (nonatomic, assign) NSInteger   type;//救援类型



@end
