//
//  InsranceOrderViewModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsranceOrderViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, weak, readonly) UIViewController *targetVC;

- (void)reloadData;
- (void)resetWithTargetVC:(UIViewController *)targetVC;
@end
