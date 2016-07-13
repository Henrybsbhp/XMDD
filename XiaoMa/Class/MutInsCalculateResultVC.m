//
//  MutInsCalculateResultVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsCalculateResultVC.h"
#import "MutualInsVC.h"
#import "MutInsSystemGroupListVC.h"

@interface MutInsCalculateResultVC ()
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *premiumPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@end

@implementation MutInsCalculateResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Setup

-(void)setUI
{
    
    self.joinBtn.layer.cornerRadius = 5;
    self.joinBtn.layer.masksToBounds = YES;
    
    self.brandNameLabel.text = [NSString stringWithFormat:@"%@",self.model.brandName];
    self.frameNoLabel.text = [NSString stringWithFormat:@"%@",self.model.frameNo];
    self.premiumPriceLabel.text = [NSString stringWithFormat:@"%@",self.model.premiumPrice];
    self.serviceFeeLabel.text = [NSString stringWithFormat:@"%@",self.model.serviceFee];
    self.shareMoneyLabel.text = [NSString stringWithFormat:@"%@",self.model.shareMoney];
    self.noteLabel.text = [NSString stringWithFormat:@"%@",self.model.note];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Action

- (IBAction)actionJoin:(id)sender {
    
    MutInsSystemGroupListVC * vc = [UIStoryboard vcWithId:@"MutInsSystemGroupListVC" inStoryboard:@"Temp"];
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionBack:(id)sender
{
    if (self.router.userInfo[kOriginRoute])
    {
        [self.router.navigationController popToRouter:self.router.userInfo[kOriginRoute] animated:YES];
    }
    else
    {
        CKRouter * route = [self.router.navigationController.routerList objectForKey:@"MutualInsVC"];
        if (route)
        {
            [self.router.navigationController popToRouter:route animated:YES];
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
@end
