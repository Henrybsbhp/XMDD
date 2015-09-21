//
//  CarwashOrderViewModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"
#import "HKLoadingModel.h"

@interface CarwashOrderViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, weak, readonly) UIViewController *targetVC;

- (id)initWithTableView:(JTTableView *)tableView;
- (void)resetWithTargetVC:(UIViewController *)targetVC;

@end
