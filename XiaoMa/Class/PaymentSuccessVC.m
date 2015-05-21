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

@end

@implementation PaymentSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subLabel.text = self.subtitle;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
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
    
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = @"tt";
    vc.subtitle = @"subtt";
    vc.image = [UIImage imageNamed:@"wechat_logo"];
    vc.urlStr = @"http://www.baidu.com";
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];

    
    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}
- (IBAction)commentAction:(id)sender {
    
    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
    vc.order = self.order;
    [vc setCustomActionBlock:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
