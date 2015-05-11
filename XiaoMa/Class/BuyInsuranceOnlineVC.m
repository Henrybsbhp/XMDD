//
//  BuyInsuranceOnlineVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BuyInsuranceOnlineVC.h"
#import "UploadInfomationVC.h"
#import "WebVC.h"

@interface BuyInsuranceOnlineVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BuyInsuranceOnlineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.webView reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
