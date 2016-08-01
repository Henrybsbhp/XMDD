//
//  CommissionSuccessVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionSuccessVC.h"
#import "CommissionOrderVC.h"


@interface CommissionSuccessVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CommissionSuccessVC
- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissionSuccessVC dealloc");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(popOrderVC)];
}


- (void)popOrderVC {
    for(UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CommissionOrderVC class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionForsuccessfulVC1" forIndexPath:indexPath];
        return cell;
    }else if (indexPath.row == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionForsuccessfulVC2" forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell searchViewWithTag:1001];
        UILabel *timeLb = (UILabel *)[cell searchViewWithTag:1002];
        label.text = self.licenceNumber;
        timeLb.text = [self.timeValue dateFormatForYYMMdd2];
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionForsuccessfulVC3" forIndexPath:indexPath];
        UIButton *btn = (UIButton *)[cell searchViewWithTag:1005];
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        
        
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            /**
             *  联系客服事件
             */
            
            [MobClick event:@"rp803_1"];
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                [gPhoneHelper makePhone:@"4007111111"];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
            [alert show];
        }];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 135;
    }else if (indexPath.row == 1){
        return 170;
    }else {
        return 150;
    }
}

@end
