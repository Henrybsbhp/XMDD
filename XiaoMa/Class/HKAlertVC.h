//
//  HKAlertVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKAlertVC : UIViewController

@property (nonatomic, strong) NSArray *actionTitles;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) void (^actionHandler)(NSInteger index, HKAlertVC *alertView);

- (void)showWithActionHandler:(void(^)(NSInteger index, HKAlertVC *alertView))handler;
- (void)dismiss;

@end
