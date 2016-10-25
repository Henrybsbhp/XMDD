//
//  GetRescueCommentOp.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/14.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescueCommentOp : BaseOp
@property (nonatomic, strong) NSNumber    *   applyId;

/** type
 *  0. 年检协办
 *  1. 拖车
 *  2. 泵电
 *  3. 换胎
 */
@property (nonatomic, strong) NSNumber    *   type;
@property (nonatomic, strong) NSMutableArray * rescueDetailArray;

/// 评价记录 ID
@property (nonatomic, assign) NSInteger commentID;

/// 反应速度
@property (nonatomic, assign) NSInteger responseSpeed;

/// 到达速度
@property (nonatomic, assign) NSInteger arriveSpeed;

/// 服务态度
@property (nonatomic, assign) NSInteger serviceAttitude;

/// 评价内容
@property (nonatomic, copy) NSString *comment;
@end
