//
//  SubmitCommentOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface SubmitCommentOp : BaseOp
@property (nonatomic, strong) NSNumber *req_orderid;
@property (nonatomic, assign) CGFloat req_rating;
@property (nonatomic, copy) NSString *req_comment;
@property (nonatomic, copy) NSString *req_ids;
@end
