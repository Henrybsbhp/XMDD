//
//  HKAlertVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKAlertActionItem.h"

@interface HKAlertVC : UIViewController

@property (nonatomic, strong) NSArray *actionItems;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic) BOOL isShowing;
///(default is YES)
@property (nonatomic, assign) BOOL autoDismiss;

- (void)show;
- (void)showWithActionHandler:(void(^)(NSInteger index, id alertVC))actionHandler;
- (void)dismiss;

@end





