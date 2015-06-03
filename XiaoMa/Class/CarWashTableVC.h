//
//  CarWashTableVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarWashTableVC : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic)NSInteger type;
@property (strong, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIView *headerView;
///禁止广告
@property (nonatomic, assign) BOOL forbidAD;
///override
- (void)reloadDataWithText:(NSString *)text error:(NSError *)error;
@end
