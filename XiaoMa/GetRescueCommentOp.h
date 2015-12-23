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
@property (nonatomic, strong) NSNumber    *   type;
@property (nonatomic, strong) NSMutableArray * rescueDetailArray;
@end
