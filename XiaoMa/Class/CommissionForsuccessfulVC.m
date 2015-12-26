//
//  CommissionForsuccessfulVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionForsuccessfulVC.h"
#import "CommissonOrderVC.h"
@interface CommissionForsuccessfulVC ()

@end

@implementation CommissionForsuccessfulVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cm_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popOrderVC)];
}


- (void)popOrderVC {
    for(UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CommissonOrderVC class]]) {
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
            NSString * number = @"4007111111";
            [gPhoneHelper makePhone:number andInfo:@"客服电话: 4007-111-111"];
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
