//
//  UnusedCouponVModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"

@interface UnusedCouponVModel : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) JTTableView *tableView;

- (id)initWithTableView:(JTTableView *)tableView;
- (void)reloadData;
@end
