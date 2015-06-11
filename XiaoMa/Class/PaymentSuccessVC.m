//
//  PaymentSuccessVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PaymentSuccessVC.h"
#import "XiaoMa.h"
#import "CarwashOrderCommentVC.h"
#import "HKServiceOrder.h"
#import "SocialShareViewController.h"

@interface PaymentSuccessVC ()

@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@end

@implementation PaymentSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subLabel.text = self.subtitle;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp110"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp110"];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

- (void)actionBack:(id)sender
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [super actionBack:sender];
    }
}
- (IBAction)shareAction:(id)sender {
    
    [MobClick event:@"rp110-1"];
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = @"小马达达－一分洗车，十分满意";
    vc.subtitle = @"我完成了洗车，你也来试试吧";
    vc.image = [UIImage imageNamed:@"wechat_share_carwash"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_carwash"];
    vc.urlStr = XIAMMAWEB;
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [vc setFinishAction:^{
        
        [sheet dismissAnimated:YES completionHandler:nil];
    }];

    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [MobClick event:@"rp110-7"];
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}
- (IBAction)commentAction:(id)sender {
    [MobClick event:@"rp110-2"];
    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
    vc.order = self.order;
    @weakify(self);
    [vc setCommentSuccess:^{
        
        @strongify(self);
        [self.commentBtn setTitle:@"已评价" forState:UIControlStateNormal];
        self.commentBtn.enabled = NO;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
