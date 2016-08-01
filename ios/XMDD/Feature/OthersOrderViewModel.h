//
//  OthersOrderViewModel.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/13.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"
#import "HKLoadingModel.h"

@interface OthersOrderViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, weak, readonly) UIViewController *targetVC;

- (id)initWithTableView:(JTTableView *)tableView;
- (void)resetWithTargetVC:(UIViewController *)targetVC;

@end
