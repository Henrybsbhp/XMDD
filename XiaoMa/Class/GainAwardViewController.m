//
//  GainAwardViewController.m
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GainAwardViewController.h"
#import "GainUserAwardOp.h"
#import "GainedViewController.h"

@interface GainAwardViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GainAwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"GainAwardViewController dealloc");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger width = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    CGFloat height;
    switch (width) {
        case 320:
            height = 506;
            break;
        case 375:
            height = 606;
            break;
        case 414:
            height = 674;
            break;
        default:
            height = 504;
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    
    UIImageView * bgView = (UIImageView *)[cell searchViewWithTag:101];
//    UIImageView * elementView = (UIImageView *)[cell searchViewWithTag:102];
    UIButton * gainBtn = (UIButton *)[cell searchViewWithTag:103];
    UILabel * numLb = (UILabel *)[cell searchViewWithTag:104];
//    UILabel * tipLb = (UILabel *)[cell searchViewWithTag:105];
    
    NSInteger deviceWidth = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    NSString * imageName = [NSString stringWithFormat:@"award_bg_%ld",(long)deviceWidth];
    bgView.image = [UIImage imageNamed:imageName];
    
    [[[gainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [self requestGainAward];
    }];
    
    
    numLb.text = [NSString stringWithFormat:@"已有%ld人领取",(long)self.gainedNum];
    
    return cell;
}

#pragma mark - Utilitly
- (void)requestGainAward
{
    GainUserAwardOp * op = [GainUserAwardOp operation];
    op.req_province = gMapHelper.addrComponent.province;
    op.req_city = gMapHelper.addrComponent.city;
    op.req_district = gMapHelper.addrComponent.district;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"抢红包啦..."];
    }] subscribeNext:^(GainUserAwardOp * op) {
        
        [gToast dismiss];
        GainedViewController * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"GainedViewController"];
        vc.amount = op.rsp_amount;
        vc.tip = op.rsp_tip;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}



@end
