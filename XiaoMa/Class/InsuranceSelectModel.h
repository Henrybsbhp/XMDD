//
//  InsuranceSelectModel.h
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceSelectModel : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *view;
@property (nonatomic,strong)NSArray * selectInsurance;

/// 座位数
@property (nonatomic,strong)NSNumber * numOfSeat;


- (void)setupInsuranceArray;

- (NSArray *)inslistForVC;

@end
