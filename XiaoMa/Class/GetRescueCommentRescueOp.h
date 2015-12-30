//
//  GetRescueCommentRescueOp.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescueCommentRescueOp : BaseOp

@property (nonatomic, strong) NSNumber  * applyId;//申请记录ID
@property (nonatomic, strong) NSNumber  * responseSpeed;//反应速度
@property (nonatomic, strong) NSNumber  * arriveSpeed;//到达速度
@property (nonatomic, strong) NSNumber  * serviceAttitude;//服务态度
@property (nonatomic, copy)   NSString  * comment;//评价内容
@property (nonatomic, strong) NSNumber  * rescueType;//1.救援评价。2.协办评价

@end
