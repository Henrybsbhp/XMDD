//
//  IllegalItemViewController.h
//  XiaoMa
//
//  Created by jt on 15/11/24.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViolationModel.h"

typedef enum : NSUInteger {
    BeforeQuery,
    Querying,
    AfterQuery
} QueryStatus;

@interface ViolationItemViewController : HKViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;


@property (nonatomic,strong)ViolationModel * violationModel;

@property (nonatomic,strong)HKMyCar * car;
@property (nonatomic,strong)NSArray * carArray;

@end
