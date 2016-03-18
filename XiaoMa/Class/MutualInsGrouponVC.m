//
//  MutualInsGrouponVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponVC.h"
#import "AddCloseAnimationButton.h"
#import "PullDownAnimationButton.h"
#import "HKPopoverView.h"
#import "MutualInsGrouponSubVC.h"
#import "ExitCooperationOp.h"
#import "MutualInsHomeVC.h"
#import "GetCooperationMygroupDetailOp.h"
#import "MutualInsOrderInfoVC.h"


@interface MutualInsGrouponVC ()

@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) AddCloseAnimationButton *menuButton;
@property (weak, nonatomic) IBOutlet UIView *topSubView;
@property (nonatomic, weak) MutualInsGrouponSubVC *topSubVC;

/**
 *  协议记录ID
 */
@property (nonatomic,strong)NSNumber * contractid;

@end

@implementation MutualInsGrouponVC

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"史上最强团";
    [self setupNavigationBar];
    
    [self requestMyGroupDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (segue.identifier && [segue.identifier isEqualToString:@"MutualInsGrouponSubVC"]) {
        self.topSubVC = (MutualInsGrouponSubVC *)segue.destinationViewController;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}
#pragma mark - Setup
- (void)setupNavigationBar
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    AddCloseAnimationButton *button = [[AddCloseAnimationButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [button addTarget:self action:@selector(actionShowOrHideMenu:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.menuButton = button;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:container];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

#pragma mark - Action
- (void)actionShowOrHideMenu:(id)sender
{
    BOOL closing = self.menuButton.closing;
    [self.menuButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        HKPopoverViewItem *item1 = [HKPopoverViewItem itemWithTitle:@"邀请入团" imageName:@"mins_person"];
        HKPopoverViewItem *item2 = [HKPopoverViewItem itemWithTitle:@"退出该团" imageName:@"mins_exit"];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 160) items:@[item1,item2]];
        
        [popover setDidSelectedBlock:^(NSUInteger index) {
            
            if (index == 0)
            {
                
            }
            else
            {
                [self requestExitGroup];
            }
        }];
        @weakify(self);
        [popover setDidDismissedBlock:^(BOOL animated) {
            @strongify(self);
            [self.menuButton setClosing:NO WithAnimation:animated];
        }];
        [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                            inView:self.navigationController.view dismissTargetView:self.view animated:YES];
        self.popoverMenu = popover;
    }
}

#pragma mark - Utility
- (void)requestMyGroupDetail
{
    GetCooperationMygroupDetailOp * op = [[GetCooperationMygroupDetailOp alloc] init];
    op.req_groupid = self.group.groupId;
    op.req_memberid = self.group.memberId;
    
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetCooperationMygroupDetailOp * rop) {
        
        self.contractid = rop.rsp_contractid;
        
        MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
        vc.contractId = self.contractid;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
    }];
}


- (void)requestExitGroup
{
    ExitCooperationOp * op = [[ExitCooperationOp alloc] init];
    op.req_memberid = self.group.memberId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"退团中..."];
    }] subscribeNext:^(ExitCooperationOp * rop) {
        
        [gToast dismiss];
        for (UIViewController * vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:NSClassFromString(@"MutualInsHomeVC")])
            {
                
                [self.navigationController popToViewController:vc animated:YES];
                [((MutualInsHomeVC *)vc) requestMyGourpInfo];
                return ;
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

@end
