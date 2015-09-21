
//
//  InsuranceDetailPlanModel.h
//  XiaoMa
//
//  Created by jt on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InsuranceCalcHelper.h"
#import "JDFlipNumberView.h"

@interface InsuranceDetailPlanModel : NSObject<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) JDFlipNumberView *flipNumberView;

@property (nonatomic,strong)NSMutableArray * insuranceArry;
@property (nonatomic)CGFloat totalPrice;
@property (nonatomic)InsuranceCalcHelper * calcHelper;

@property (nonatomic)CGFloat carPrice;

/**
 *  选中的车险
 */
@property (nonatomic,strong)NSArray * selectInsurance;

- (instancetype)initWithSelectInsurance:(NSArray *)array andCarPrice:(CGFloat)price;

- (void)animateToTargetValue;
- (void)noAnimateToTargetValue;

// 获取inslist，/insurance/appointment接口需要
- (NSArray *)inslistForVC;
@end
