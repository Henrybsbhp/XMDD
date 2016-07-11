//
//  CooperationGroupListVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CooperationGroupListVC.h"
#import "CooperationGroupListVM.h"
#import "GetCooperationGroupOp.h"

@interface CooperationGroupListVC ()
@property (weak, nonatomic) IBOutlet UIButton *groupBeginBtn;
@property (weak, nonatomic) IBOutlet UIButton *groupEndBtn;
@property (weak, nonatomic) IBOutlet UIView *groupBeginLine;
@property (weak, nonatomic) IBOutlet UIView *groupEndLine;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

@property (strong, nonatomic) CooperationGroupListVM *groupBeginVM;
@property (strong, nonatomic) CooperationGroupListVM *groupEndVM;

@end

@implementation CooperationGroupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.groupBeginVM getCooperationGroupList];
    [self.groupEndVM getCooperationGroupList];
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

-(void)setupUI
{
    @weakify(self)
    
    self.applyBtn.layer.cornerRadius = 5;
    self.applyBtn.layer.masksToBounds = YES;
    
    self.groupBeginBtn.selected = YES;
    self.groupBeginTable.hidden = NO;
    self.groupEndBtn.selected = NO;
    self.groupEndTable.hidden = YES;
    
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
    
}


#pragma mark - LazyLoad

-(CooperationGroupListVM *)groupBeginVM
{
    if (!_groupBeginVM)
    {
        _groupBeginVM = [[CooperationGroupListVM alloc]initWithTableView:self.groupBeginTable andType:GroupStatusTypeBegin andTargetVC:self];
    }
    return _groupBeginVM;
}

-(CooperationGroupListVM *)groupEndVM
{
    if (!_groupEndVM)
    {
        _groupEndVM = [[CooperationGroupListVM alloc]initWithTableView:self.groupEndTable andType:GroupStatusTypeEnd andTargetVC:self];
    }
    return _groupEndVM;
}


@end
