//
//  BuyInsuranceOnlineVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BuyInsuranceOnlineVC.h"
#import "UploadInfomationVC.h"
#import "BeInterestedInInsuranceOp.h"
#import "WebVC.h"

#define kInsuranceOlineUrl  @"http://www.xiaomadada.com/apphtml/aichebao.html"

@implementation BuyInsuranceOnlineVC

- (void)viewDidLoad {
    self.url = kInsuranceOlineUrl;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp123"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp123"];

}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

#pragma mark - Action
///我感兴趣
- (IBAction)actionInterested:(id)sender {
    [MobClick event:@"rp123-2"];
    if (![LoginViewModel loginIfNeededForTargetViewController:self]) {
        return;
    }
    NSString *msg = @"感谢您对爱车宝感兴趣，是否需要工作人员在1个工作日内电话联系您，为您更详细地介绍爱车宝？";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil
                                          cancelButtonTitle:@"算了吧" otherButtonTitles:@"必须的", nil];
    [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
        //我感兴趣
        if ([number integerValue] == 1) {
            [MobClick event:@"rp123-4"];
            BeInterestedInInsuranceOp *op = [BeInterestedInInsuranceOp new];
            [[[op rac_postRequest] initially:^{
                
                [gToast showingWithText:@"正在提交..."];
            }] subscribeNext:^(id x) {
                
                [gToast showText:@"收到啦～工作人员将于1个工作日内电话联系您，为您更详细的介绍爱车宝！"];
            } error:^(NSError *error) {
                
                if (error.code == 6001) {
                    [gToast showText:@"收到啦～工作人员将于1个工作日内电话联系您，为您更详细的介绍爱车宝！"];
                }
                else {
                    [gToast showError:error.domain];
                }
            }];
        }
        //算了
        else {
            [MobClick event:@"rp123-3"];
        }
    }];
    [alert show];
}

///电话咨询
- (IBAction)actionMakeCall:(id)sender {
    [MobClick event:@"rp123-1"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"咨询电话：4007-111-111"];
}

- (IBAction)actionHelp:(id)sender
{
    WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
    vc.title = @"什么是爱车宝保险？";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionUploadInfo:(id)sender
{
    UploadInfomationVC *vc = [UIStoryboard vcWithId:@"UploadInfomationVC" inStoryboard:@"Insurance"];
    vc.originVC = self.originVC;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
