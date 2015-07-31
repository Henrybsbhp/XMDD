//
//  InsuranceCalcHelper.h
//  XiaoMa
//
//  Created by jt on 15/7/30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceCalcHelper : NSObject

/**
 *  车价
 */
@property (nonatomic)CGFloat carPrice;

/**
 *  车座数量
 */
@property (nonatomic)NSInteger numOfSeat;

/**
 *  是否进口车
 */
@property (nonatomic)BOOL isImportedCard;




@end
