//
//  IllegalItemViewController.h
//  XiaoMa
//
//  Created by jt on 15/11/24.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViolationModel.h"
#import "HKPageControl.h"

typedef enum : NSUInteger {
    BeforeQuery,
    Querying,
    AfterQuery
} QueryStatus;

@interface ViolationItemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet HKPageControl *pageControl;

@property (nonatomic,strong)ViolationModel * model;

@property (nonatomic,strong)HKMyCar * car;
@property (nonatomic,strong)NSArray * carArray;

@end
