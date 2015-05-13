//
//  LogAlertView.h
//  XiaoNiuShared
//
//  Created by jt on 14-8-5.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogAlertView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)UILabel * title;
@property (strong, nonatomic)UITableView *tableview;
@property (strong, nonatomic)UIButton *cancelBtn;
@property (strong, nonatomic)UIButton *okBtn;
@property (strong, nonatomic)UIView * bgView;
@property (strong, nonatomic)UIButton *superBtn;

@property (strong, nonatomic)NSArray * logArray;

@property (strong, nonatomic)void(^selectBlock)(NSInteger index);

@end
