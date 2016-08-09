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


#pragma mark - Action

- (IBAction)actionJumpToMyCommisionVC:(id)sender {
    ViolationMissionHistoryVC *vc = [UIStoryboard vcWithId:@"ViolationMissionHistoryVC" inStoryboard:@"Temp_YZC"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
