//
//  InsuranceResultVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/7/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceResultVC.h"
#import "DrawingBoardView.h"
#import "AnimationBoardView.h"
#import "InsuranceVC.h"
#import "JTLabel.h"
#import "SocialShareViewController.h"

@interface InsuranceResultVC ()

@property (assign, nonatomic) InsuranceResult insuranceResultType;
@property (weak, nonatomic) IBOutlet DrawingBoardView *drawView;
@property (weak, nonatomic) IBOutlet JTLabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *failureContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (nonatomic, assign) BOOL navPopGestureEnable;

- (IBAction)shareAction:(id)sender;

@end

@implementation InsuranceResultVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp327"];
    [(JTNavigationController *)self.navigationController setShouldAllowInteractivePopGestureRecognizer:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp327"];
    [(JTNavigationController *)self.navigationController setShouldAllowInteractivePopGestureRecognizer:YES];
}

- (void)actionBack:(id)sender
{
    UIViewController *vc = self.originVC;
    if (!vc) {
        vc = [self.navigationController.viewControllers firstObjectByFilteringOperator:^BOOL(id obj) {
            return [(UIViewController *)obj isKindOfClass:NSClassFromString(@"InsuranceVC")];
        }];
    }
    if (vc) {
        [self.navigationController popToViewController:vc animated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self postCustomNotificationName:kNotifyRefreshDetailInsuranceOrder object:self.orderID];
    [self postCustomNotificationName:kNotifyRefreshInsuranceOrders object:nil];
}

-(void)setResultType:(InsuranceResult) resultType
{
    self.insuranceResultType = resultType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.insuranceResultType == OrderSuccess) {
        self.navigationItem.title = @"预约结果";
        self.resultLabel.text = self.resultTitle ? self.resultTitle : @"恭喜，预约成功 ！";
        self.resultLabel.textColor = [UIColor colorWithHex:@"#fa8585" alpha:1.0f];
        NSString * content = self.resultContent ? self.resultContent :
            @"工作人员将尽快联系您，为您办理相关保险事宜，请保持手机畅通，谢谢您的信任，请耐心等待！";
        self.failureContentLabel.attributedText = [self setLabelContent:content];
        self.shareButton.hidden = YES;
        
        AnimationBoardView *animationView = [[AnimationBoardView alloc] init];
        [animationView successAnimation];
        [self.drawView addSubview:animationView];
        
    }
    else if (self.insuranceResultType == PaySuccess) {
        self.resultLabel.text = self.resultTitle ? self.resultTitle :  @"恭喜，支付成功 ！";
        self.resultLabel.textColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
        self.failureContentLabel.hidden = YES;
        self.shareButton.layer.masksToBounds = YES;
        self.shareButton.layer.cornerRadius = 11;
        
        [self.drawView drawSuccess];
    }
    else {
        self.resultLabel.text = self.resultTitle ? self.resultTitle : @"支付失败 ！";
        self.resultLabel.textColor = [UIColor colorWithHex:@"#e72c2c" alpha:1.0f];
        NSString * content = self.resultContent ? self.resultContent : @"失败原因：请检查网络！";
        self.failureContentLabel.attributedText = [self setLabelContent:content];
        self.shareButton.hidden = YES;
        
        [self.drawView drawFailure];
    }
}

- (NSMutableAttributedString *) setLabelContent:(NSString *) contentStr
{
    //设置行间距、居中等
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentStr.length)];
    return attributedStr;
}

- (IBAction)shareAction:(id)sender {
    [MobClick event:@"rp327-2"];
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = @"我在小马达达上购买了车险，赚大发了！";
    vc.subtitle = @"终于等到这一天，好运来到我身边，小马达达车险大“放”假期！嘘，一般人我不告诉他！";
    vc.image = [UIImage imageNamed:@"wechat_share_ins"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_ins"];
    //    vc.urlStr = XIAMMAWEB;
    vc.urlStr = @"www.xiaomadada.com";
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
@end
