//
//  CooperationGroupListVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsSystemGroupListVC.h"
#import "MutInsSystemGroupListVM.h"
#import "GetCooperationGroupOp.h"
#import "GroupIntroductionVC.h"
#import "GetCooperationUsercarListOp.h"
#import "MutualInsPickCarVC.h"
#import "MutualInsPicUpdateVC.h"

@interface MutInsSystemGroupListVC ()

@property (strong, nonatomic) MutInsSystemGroupListVM *groupBeginVM;

@end

@implementation MutInsSystemGroupListVC

- (void)dealloc
{
    DebugLog(@"MutInsSystemGroupListVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupNavigationBar];
    
    [self.groupBeginVM getCooperationGroupList];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupUI
{
    self.applyBtn.layer.cornerRadius = 5;
    self.applyBtn.layer.masksToBounds = YES;
}

#pragma mark - Action

- (IBAction)actionApply:(id)sender
{
    [MobClick event:@"huzhutuan" attributes:@{@"huzhutuan":@"huzhutuan5"}];
    GroupIntroductionVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"GroupIntroductionVC"];
    vc.groupType = MutualGroupTypeSystem;
    [self.router.navigationController pushViewController:vc animated:YES];
}

-(void)actionBack
{
    [MobClick event:@"huzhutuan" attributes:@{@"huzhutuan":@"huzhutuan1"}];
    
    self.groupBeginVM = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - LazyLoad

-(MutInsSystemGroupListVM *)groupBeginVM
{
    if (!_groupBeginVM)
    {
        _groupBeginVM = [[MutInsSystemGroupListVM alloc] initWithTableView:self.groupBeginTable andType:GroupStatusTypeBegin andTargetVC:self];
    }
    return _groupBeginVM;
}

@end
