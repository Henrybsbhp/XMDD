//
//  JTUser.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTUser.h"
#import "XiaoMa.h"
#import "GetUserCarOp.h"

@implementation JTUser

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _favorites = [[FavoriteModel alloc] init];
    }
    return self;
}


@end

