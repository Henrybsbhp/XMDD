//
//  HKRescueHistory.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKRescueHistory : NSObject

/** type
 *  0. 年检协办
 *  1. 拖车
 *  2. 泵电
 *  3. 换胎
 */
@property (nonatomic, strong) NSNumber  *type;//救援类型

/**commentStatus
 *  0. 未评价
 *  1. 已评价
 */
@property (nonatomic, strong) NSNumber  *commentStatus;//评价状态

/**rescueStatus
 *  2已申请
 *  3已完成
 *  4已取消
 *  5处理中
 */
@property (nonatomic, strong) NSNumber  *rescueStatus;//救援状态

@property (nonatomic, strong) NSDate *applyTime;//申请时间
@property (nonatomic, copy) NSString *serviceName;//服务名称
@property (nonatomic, copy) NSString *licenceNumber;//车牌号
@property (nonatomic, strong) NSNumber *applyId;//申请记录id
@property (nonatomic, strong) NSString  *appointTime;//预约时间

@end

