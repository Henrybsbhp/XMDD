//
//  InsIntroVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/26.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InsIntroVC.h"
#import "InsuranceVC.h"

@implementation InsIntroVC

- (void)awakeFromNib {
    self.url = kInsuranceIntroUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"保险服务";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
}

- (IBAction)actionEnter:(id)sender {
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"baoxianshouye":@"baoxianshouye0002"}];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        InsuranceVC *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)actionBack
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"baoxianshouye":@"baoxianshouye0001"}];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
