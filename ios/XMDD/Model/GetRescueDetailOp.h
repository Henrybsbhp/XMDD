//
//  GetRescueDetailOp.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescueDetailOp : BaseOp
@property (nonatomic, assign) NSInteger   rescueid;

/** type
 *  0. 年检协办
 *  1. 拖车
 *  2. 泵电
 *  3. 换胎
 */
@property (nonatomic, strong) NSNumber  * type;

@property (nonatomic, copy) NSString    * serviceObject;//服务对象
@property (nonatomic, copy) NSString    * feesacle;//收费标准
@property (nonatomic, copy) NSString    * serviceProject;//服务项目
@property (nonatomic, strong) NSMutableArray  * rescueDetailArray;//返回的是一个字典

@end
