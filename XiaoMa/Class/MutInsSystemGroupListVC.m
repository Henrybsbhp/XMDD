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
@property (weak, nonatomic) IBOutlet UIButton *groupBeginBtn;
@property (weak, nonatomic) IBOutlet UIButton *groupEndBtn;
@property (weak, nonatomic) IBOutlet UIView *groupBeginLine;
@property (weak, nonatomic) IBOutlet UIView *groupEndLine;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

@property (strong, nonatomic) MutInsSystemGroupListVM *groupBeginVM;
@property (strong, nonatomic) MutInsSystemGroupListVM *groupEndVM;

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
    [self.groupEndVM getCooperationGroupList];
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
    
    self.groupBeginBtn.selected = YES;
    self.groupBeginTable.hidden = NO;
    self.groupEndBtn.selected = NO;
    self.groupEndTable.hidden = YES;
    
    @weakify(self)
    [[self.groupBeginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [self changeUIByVCIsBegin:YES];
    }];
    
    [[self.groupEndBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [self changeUIByVCIsBegin:NO];
    }];
}

#pragma mark - Utility

-(void)changeUIByVCIsBegin:(BOOL)type
{
    
    self.groupBeginBtn.selected = type;
    self.groupEndBtn.selected = !type;
    
    if (type)
    {
        self.groupBeginLine.backgroundColor = HEXCOLOR(@"#18D06A");
        self.groupEndLine.backgroundColor = HEXCOLOR(@"#FFFFFF");
    }
    else
    {
        self.groupBeginLine.backgroundColor = HEXCOLOR(@"#FFFFFF");
        self.groupEndLine.backgroundColor = HEXCOLOR(@"#18D06A");
    }
    
    self.groupBeginTable.hidden = !type;
    self.groupEndTable.hidden = type;
    
}


#pragma mark - Action

- (IBAction)actionApply:(id)sender
{
    GroupIntroductionVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"GroupIntroductionVC"];
    vc.groupType = MutualGroupTypeSystem;
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - LazyLoad

-(MutInsSystemGroupListVM *)groupBeginVM
{
    if (!_groupBeginVM)
    {
        _groupBeginVM = [[MutInsSystemGroupListVM alloc]initWithTableView:self.groupBeginTable andType:GroupStatusTypeBegin andTargetVC:self];
    }
    return _groupBeginVM;
}

-(MutInsSystemGroupListVM *)groupEndVM
{
    if (!_groupEndVM)
    {
        _groupEndVM = [[MutInsSystemGroupListVM alloc]initWithTableView:self.groupEndTable andType:GroupStatusTypeEnd andTargetVC:self];
    }
    return _groupEndVM;
}


@end
