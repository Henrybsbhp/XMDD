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

@interface PaymentSuccessVC ()

@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@end

@implementation PaymentSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subLabel.text = self.title;
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
    
    
}
- (IBAction)commentAction:(id)sender {
    
    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
    HKServiceOrder * order = [[HKServiceOrder alloc] init];
    order.orderid = self.orderId;
    vc.order = order;
    [vc setCustomActionBlock:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
