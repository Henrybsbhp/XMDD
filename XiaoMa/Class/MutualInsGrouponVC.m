//
//  MutualInsGrouponVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponVC.h"
#import "AddCloseAnimationButton.h"
#import "CKDatasource.h"
#import "HKPopoverView.h"
#import "GetCooperationMygroupDetailOp.h"
#import "ExitCooperationOp.h"

#import "MutualInsGrouponSubVC.h"
#import "MutualInsGrouponSubMsgVC.h"
#import "MutualInsHomeVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsOrderInfoVC.h"
#import "InviteByCodeVC.h"

typedef enum : NSInteger
{
    MutualInsScrollDirectionUnknow = 0,
    MutualInsScrollDirectionDown = 1,
    MutualInsScrollDirectionUp = 2
}MutualInsScrollDirection;

@interface MutualInsGrouponVC ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, assign) MutualInsScrollDirection scrollDirection;

@end

@interface MutualInsGrouponVC ()

@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) AddCloseAnimationButton *menuButton;
@property (nonatomic, strong) MutualInsGrouponSubVC *topSubVC;
@property (nonatomic, strong) MutualInsGrouponSubMsgVC *bottomSubVC;

@property (nonatomic, strong) GetCooperationMygroupDetailOp *groupDetail;
@property (nonatomic, assign) BOOL isExpandingOrClosing;
@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MutualInsGrouponVC

#pragma mark - System
- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.group.groupName;
    [self setupTopSubVC];
    [self requestGroupDetailInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (!segue.identifier) {
        return;
    }
    if ([segue.identifier isEqualToString:@"MutualInsGrouponSubVC"]) {
        self.topSubVC = (MutualInsGrouponSubVC *)segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"MutualInsGrouponSubMsgVC"]) {
        self.bottomSubVC = (MutualInsGrouponSubMsgVC *)segue.destinationViewController;
    }
}

#pragma mark - Setup
- (void)setupTopSubVC {
    @weakify(self);
    self.topSubVC.title = self.navigationItem.title;
    [self.topSubVC setShouldExpandedOrClosed:^(BOOL expanded) {
        @strongify(self);
        [self setExpanded:expanded animated:YES];
    }];
}

- (void)setupNavigationRightItem {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    AddCloseAnimationButton *button = [[AddCloseAnimationButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [button addTarget:self action:@selector(actionShowOrHideMenu:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.menuButton = button;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:container]];
}
#pragma mark - Action
- (void)actionShowOrHideMenu:(id)sender {
    BOOL closing = self.menuButton.closing;
    [self.menuButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        NSArray *items = [self.menuItems arrayByMappingOperator:^id(CKDict *obj) {
            return [HKPopoverViewItem itemWithTitle:obj[@"title"] imageName:obj[@"img"]];
        }];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 160) items:items];
        @weakify(self);
        [popover setDidSelectedBlock:^(NSUInteger index) {
            @strongify(self);
            CKDict *dict = [self.menuItems safetyObjectAtIndex:index];
            CKCellSelectedBlock block = dict[kCKCellSelected];
            if (block) {
                block(dict, [NSIndexPath indexPathForRow:index inSection:0]);
            }
        }];
        
        [popover setDidDismissedBlock:^(BOOL animated) {
            @strongify(self);
            [self.menuButton setClosing:NO WithAnimation:animated];
        }];
        [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                            inView:self.navigationController.view dismissTargetView:self.view animated:YES];
        self.popoverMenu = popover;
    }
}

#pragma mark - Reload
- (void)reloadData {
    //刷新上层子视图
    self.topSubVC.groupDetail = self.groupDetail;
    [self.topSubVC reloadDataWithStatus:self.groupDetail.rsp_status];
    @weakify(self);
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(self.topSubVC.expandedHeight);
    }];

    //刷新下层视图
    self.bottomSubVC.groupMembers = self.groupDetail.rsp_members;
    self.bottomSubVC.group = self.group;
    [self.bottomSubVC reloadData];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(self.scrollView.frame.size.height - self.topSubVC.closedHeight + 5);
    }];
    //刷新菜单按钮
    [self reloadMenuItems];
}

- (void)reloadMenuItems {
    [self.popoverMenu dismissWithAnimated:YES];
    
    MutInsStatus status = self.groupDetail.rsp_status;
    if (status == MutInsStatusToBePaid || status == MutInsStatusPaidForAll || status == MutInsStatusGettedAgreement) {
        self.menuItems = @[[self menuItemMyOrder], [self menuItemMakeCall]];
    }
    else if (status == MutInsStatusAgreementTakingEffect) {
        self.menuItems = @[[self menuItemInvite], [self menuItemQuit], [self menuItemMakeCall]];
    }
    else if (status == MutInsStatusAgreementTakingEffect) {
        self.menuItems = @[[self menuItemMyOrder], [self menuItemInvite], [self menuItemMakeCall]];
    }
    else if (status == MutInsStatusAgreementTakingEffect) {
        self.menuItems = @[[self menuItemInvite], [self menuItemMakeCall]];
    }
    else {
        self.menuItems = @[[self menuItemInvite], [self menuItemQuit], [self menuItemMakeCall]];
    }
}

#pragma mark - Request
- (void)requestGroupDetailInfo {
    GetCooperationMygroupDetailOp *op = [GetCooperationMygroupDetailOp operation];
    op.req_groupid = self.group.groupId;
    op.req_memberid = self.group.memberId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.containerView.hidden = NO;
        self.groupDetail = x;
        [self setupNavigationRightItem];
        [self reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:@"获取团详情失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [self requestGroupDetailInfo];
        }];
    }];
}

- (void)requestExitGroup {
    ExitCooperationOp * op = [[ExitCooperationOp alloc] init];
    op.req_memberid = self.group.memberId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"退团中..."];
    }] subscribeNext:^(ExitCooperationOp * rop) {
        @strongify(self);
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

#pragma mark - MenuItems
- (CKDict *)menuItemInvite {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"邀请入团",@"img":@"mins_person"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        InviteByCodeVC *vc = [
    });
    return dict;
}

- (CKDict *)menuItemQuit {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Quit",@"title":@"退出该团",@"img":@"mins_exit"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self requestExitGroup];
    });
    return dict;
}

- (CKDict *)menuItemMakeCall {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Call",@"title":@"联系客服",@"img":@"mins_phone"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"客服电话: 4007-111-111"];
    });
    return dict;
}

- (CKDict *)menuItemMyOrder {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Order",@"title":@"我的订单",@"img":@"mins_order"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
        vc.contractId = self.groupDetail.rsp_contractid;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

#pragma mark - Animate
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    self.isExpandingOrClosing = YES;
    self.topSubVC.isExpanded = expanded;
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(0, expanded ? 0 : dvalue);
        } completion:^(BOOL finished) {
            self.isExpandingOrClosing = NO;
            self.topSubVC.shouldStopWaveView = !expanded;
            self.scrollDirection = MutualInsScrollDirectionUnknow;
        }];
    }
    else {
        self.scrollView.contentOffset = CGPointMake(0, expanded ? 0 : dvalue);
        self.isExpandingOrClosing = NO;
        self.topSubVC.shouldStopWaveView = !expanded;
        self.scrollDirection = MutualInsScrollDirectionUnknow;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (self.scrollView.contentOffset.y < dvalue/2 && !self.topSubVC.isExpanded) {
        [self setExpanded:YES animated:YES];
    }
    else if (self.scrollView.contentOffset.y > dvalue/2 && self.topSubVC.isExpanded) {
        [self setExpanded:NO animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (!decelerate && self.scrollView.contentOffset.y < dvalue/2 && self.scrollView.contentOffset.y > 0) {
        [self setExpanded:YES animated:YES];
    }
    else if (!decelerate && self.scrollView.contentOffset.y > dvalue/2 && self.scrollView.contentOffset.y < dvalue) {
        [self setExpanded:NO animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (!self.isExpandingOrClosing && self.scrollView.contentOffset.y < dvalue/2 && self.scrollView.contentOffset.y > 0) {
        [self setExpanded:YES animated:YES];
    }
    else if (!self.isExpandingOrClosing && self.scrollView.contentOffset.y > dvalue/2 && self.scrollView.contentOffset.y < dvalue) {
        [self setExpanded:NO animated:YES];
    }
}

@end

