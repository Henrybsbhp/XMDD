//
//  ViolationDelegateCommitSuccessVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationDelegateCommitSuccessVC.h"
#import "ViolationMissionHistoryVC.h"

@interface ViolationDelegateCommitSuccessVC ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *myCommisionBtn;
@property (weak, nonatomic) IBOutlet UILabel *successTipLabel;

@end

@implementation ViolationDelegateCommitSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self setupNavi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.router.disableInteractivePopGestureRecognizer = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.router.disableInteractivePopGestureRecognizer = NO;
}

#pragma mark - Setup

-(void)setupUI
{
    self.successTipLabel.text = [self.successMsg stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    self.myCommisionBtn.layer.cornerRadius = 5;
    self.myCommisionBtn.layer.masksToBounds = YES;
}

-(void)setupNavi
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}


#pragma mark - Action

-(void)actionBack
{
    if (self.router.userInfo[kOriginRoute])
    {
        UIViewController *vc = [self.router.userInfo[kOriginRoute] targetViewController];
        [self.router.navigationController popToViewController:vc animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)actionJumpToMyCommisionVC:(id)sender
{
    ViolationMissionHistoryVC *vc = [UIStoryboard vcWithId:@"ViolationMissionHistoryVC" inStoryboard:@"Violation"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
