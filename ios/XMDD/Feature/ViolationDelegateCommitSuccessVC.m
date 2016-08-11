//
//  ViolationDelegateCommitSuccessVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationDelegateCommitSuccessVC.h"
#import "ViolationMissionHistoryVC.h"

@interface ViolationDelegateCommitSuccessVC ()
@property (weak, nonatomic) IBOutlet UIButton *myCommisionBtn;

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
#pragma mark - Setup

-(void)setupUI
{
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
    ViolationMissionHistoryVC *vc = [UIStoryboard vcWithId:@"ViolationMissionHistoryVC" inStoryboard:@"Temp_YZC"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
