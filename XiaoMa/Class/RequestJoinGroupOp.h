//
//  RequestJoinGroupOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface RequestJoinGroupOp : BaseOp

// 团暗号
@property (nonatomic, copy) NSString *cipher;

// 团信息 Dict
@property (nonatomic, strong) NSDictionary *groupDict;

@end
