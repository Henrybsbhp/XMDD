//
//  CommitSuccessVC.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CommitSuccessVC.h"
#import "SocialShareViewController.h"
#import "ShareResponeManager.h"
#import "HomePageVC.h"
#import "UIView+Layer.h"
#import "GetShareButtonOpV2.h"


@interface CommitSuccessVC ()
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;


@end

@implementation CommitSuccessVC

- (void)dealloc
{
    DebugLog(@"CommitSuccessVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    self.tipLabel.text = @"您的信息已成功提交，客服将在24小时内与您取得联系，请保持手机畅通";
    self.tipLabel.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 50;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:YES];
}


- (void)setupUI
{
    [self.shareBtn makeCornerRadius:5.0f];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cm_nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToHomePage)];
}


- (void)backToHomePage
{
    /**
     *  返回估值首页事件
     */
    [MobClick event:@"rp605_1"];
    NSArray *viewControllers = self.navigationController.viewControllers;
    [self.navigationController popToViewController:[viewControllers safetyObjectAtIndex:1] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)shareClick:(id)sender {
    /**
     *  分享事件
     */
    [MobClick event:@"rp605_2"];
    [self shareApp];
}

- (void)shareApp
{
    [gToast showingWithText:@"分享信息拉取中..."];
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneAppCarSell;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneAppCarSell;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110_7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

@end
