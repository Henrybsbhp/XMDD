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
}

- (IBAction)actionEnter:(id)sender {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        InsuranceVC *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
