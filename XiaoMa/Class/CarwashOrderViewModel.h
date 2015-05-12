//
//  CarwashOrderViewModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarwashOrderViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, weak) UIViewController *targetVC;
- (void)reloadData;

@end
