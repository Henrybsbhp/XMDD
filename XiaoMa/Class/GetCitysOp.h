//
//  GetCitysOp.h
//  XiaoMa
//
//  Created by jt on 15/12/1.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetCitysOp : BaseOp

@property (nonatomic, strong) NSNumber *timetag;

@property (nonatomic,strong)NSArray * provinceArray;

@property (nonatomic,strong)NSArray * cityArray;


@end
