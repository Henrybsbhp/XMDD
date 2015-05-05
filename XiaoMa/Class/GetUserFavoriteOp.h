//
//  GetUserFavoriteOp.h
//  XiaoMa
//
//  Created by jt on 15-4-30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetUserFavoriteOp : BaseOp

///pageno
@property (nonatomic)NSInteger pageno;

@property (nonatomic,strong)NSArray * rsp_shopArray;

@end
