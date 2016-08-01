//
//  GetUserFavoriteV2Op.h
//  XiaoMa
//
//  Created by jt on 15/10/19.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetUserFavoriteV2Op : BaseOp

///pageno
@property (nonatomic)NSInteger pageno;

@property (nonatomic,strong)NSArray * rsp_shopArray;

@end
