//
//  GasNormalVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/26.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GasNormalVC : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak, readonly) UIViewController *targetVC;
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UIButton *bottomBtn;

- (instancetype)initWithTargetVC:(UIViewController *)vc tableView:(UITableView *)table bottomButton:(UIButton *)btn;
- (BOOL)reloadDataIfNeeded;

@end
