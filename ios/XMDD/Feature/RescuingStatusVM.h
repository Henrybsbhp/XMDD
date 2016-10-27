//
//  RescuingStatusVM.h
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GeneralTableViewVM.h"
#import "GetRescueOrCommissionDetailOp.h"

@interface RescuingStatusVM : GeneralTableViewVM

@property (nonatomic, assign) NSInteger vcType;

@property (nonatomic, strong) GetRescueOrCommissionDetailOp *rescueDetialOp;

/// 记录 ID，请求数据的输入参数
@property (nonatomic, strong) NSNumber *applyID;

@property (nonatomic, strong) UIButton *confirmButton;

/// 判断是否从推送主页面进入
@property (nonatomic) BOOL isEnterFromHomePage;

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC;

- (void)initialSetup;

@end
