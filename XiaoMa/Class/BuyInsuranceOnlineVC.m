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

@interface BuyInsuranceOnlineVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BuyInsuranceOnlineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadWebView
{
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:kInsuranceOlineUrl]];
    [self.webView loadRequest:req];
}
#pragma mark - Action
///我感兴趣
- (IBAction)actionInterested:(id)sender {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        BeInterestedInInsuranceOp *op = [BeInterestedInInsuranceOp new];
        [[[op rac_postRequest] initially:^{
          
            [gToast showingWithText:@"正在提交..."];
        }] subscribeNext:^(id x) {
            
            [gToast showSuccess:@"提交成功!"];
        } error:^(NSError *error) {
            
            if (error.code == 6001) {
                [gToast showSuccess:@"提交成功!"];
            }
            else {
                [gToast showError:error.domain];
            }
        }];
    }
}

///电话咨询
- (IBAction)actionMakeCall:(id)sender {
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"4007-111-111"];
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
