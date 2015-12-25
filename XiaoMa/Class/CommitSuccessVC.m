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
#import "GetShareButtonOp.h"


@interface CommitSuccessVC ()
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;


@end

@implementation CommitSuccessVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    self.tipLabel.text=@"您的信息已成功提交，客服将在24小时内与您取得联系，请保持手机畅通";
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
    [MobClick event:@"605-1"];
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
    [MobClick event:@"605-2"];
    [self shareApp];
}

- (void)shareApp
{
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.sceneType = ShareSceneApp;
    vc.btnTypeArr = @[@1, @2, @3, @4];
//    vc.tt = @"小马达达 —— 一分钱洗车";
//    vc.subtitle = @"我正在使用1分钱洗车，洗车超便宜，你也来试试吧！";
    vc.image = [UIImage imageNamed:@"wechat_share_carwash"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_carwash"];
//    vc.urlStr = kAppShareUrl;
    
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    [vc setClickAction:^{
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    //单例模式下，不需要处理回调应将单例的block设置为空，否则将执行上次set的block
    [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
        
    }];
    [[ShareResponeManagerForQQ init] setFinishAction:^(NSString * code, ShareResponseType type){
        
    }];
}

@end
