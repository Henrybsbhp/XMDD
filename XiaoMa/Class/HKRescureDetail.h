//
//  HKRescureDetail.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKRescureDetail : NSObject
@property (nonatomic, strong) NSNumber  * rescueid;//服务id
@property (nonatomic, copy) NSString    * serviceobject;//服务对象
@property (nonatomic, copy) NSString    * feesacle;//收费标准
@property (nonatomic, copy) NSString    * serviceproject;//服务项目
@end
