//
//  UsedCouponVModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"
#import "HKLoadingModel.h"

@interface UsedCouponVModel : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;

- (id)initWithTableView:(JTTableView *)tableView;

@end
