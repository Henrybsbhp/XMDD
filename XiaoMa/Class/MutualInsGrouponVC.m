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
#import "DeleteCooperationGroupOp.h"
#import "MutualInsStore.h"

#import "MutualInsGrouponSubVC.h"
#import "MutualInsGrouponSubMsgVC.h"
#import "MutualInsHomeVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsOrderInfoVC.h"
#import "InviteByCodeVC.h"
#import "CreateGroupVC.h"

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

@property (nonatomic, strong) MutualInsStore *minsStore;
@property (nonatomic, strong) GetCooperationMygroupDetailOp *groupDetail;
@property (nonatomic, assign) BOOL isExpandingOrClosing;
@property (nonatomic, strong) CKList *menuItems;

@end

@implementation MutualInsGrouponVC

#pragma mark - System
- (void)dealloc {
    
    DebugLog(@"MutualInsGrouponVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationBar];
    [self setupSubVC];
    [self setupMutualInsStore];
    [[self.minsStore reloadDetailGroupByMemberID:self.group.memberId andGroupID:self.group.groupId] send];
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
- (void)setupNavigationBar {
    self.navigationItem.title = self.group.groupName.length > 0 ? self.group.groupName : @"团详情";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
}

- (void)setupSubVC {
    @weakify(self);
    self.topSubVC.title = self.navigationItem.title;
    self.topSubVC.originVC = self;
    [self.topSubVC setShouldExpandedOrClosed:^(BOOL expanded) {
        @strongify(self);
        [self setExpanded:expanded animated:YES];
    }];
}

- (void)setupMutualInsStore {
    self.minsStore = [MutualInsStore fetchOrCreateStore];
    @weakify(self);
    [self.minsStore subscribeWithTarget:self domain:kDomainMutualInsDetailGroups receiver:^(id store, CKEvent *evt) {
        
        @strongify(self);
        GetCooperationMygroupDetailOp *op = evt.object;
        if ([self.group.groupId isEqual:op.req_groupid]) {
            [self reloadFromSignal:evt.signal];
        }
    }];
}

- (void)resetNavigationItemWithTitle:(NSString *)title {

    if (title.length > 0) {
        self.navigationItem.title  = title;
    }
    
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
        NSArray *items = [self.menuItems.allObjects arrayByMappingOperator:^id(CKDict *obj) {
            return [HKPopoverViewItem itemWithTitle:obj[@"title"] imageName:obj[@"img"]];
        }];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 160) items:items];
        @weakify(self);
        [popover setDidSelectedBlock:^(NSUInteger index) {
            @strongify(self);
            CKDict *dict = self.menuItems[index];
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

- (void)actionBack:(id)sender {
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Reload
- (void)reloadFromSignal:(RACSignal *)signal {
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.containerView.hidden = NO;
        self.groupDetail = x;

        [self resetNavigationItemWithTitle:self.groupDetail.rsp_groupname];
        [self reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:@"获取团详情失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [[self.minsStore reloadDetailGroupByMemberID:self.group.memberId andGroupID:self.group.groupId] send];
        }];
    }];
}

- (void)reloadData {

    //刷新上层子视图
    self.topSubVC.groupDetail = self.groupDetail;
    [self.topSubVC reloadDataWithStatus:self.groupDetail.rsp_status];
    @weakify(self);
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(self.topSubVC.expandedHeight);
    }];

    //刷新下层视图
    self.bottomSubVC.groupMembers = self.groupDetail.rsp_members;
    self.bottomSubVC.group = self.group;
    [self.bottomSubVC reloadData];
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(self.scrollView.frame.size.height - self.topSubVC.closedHeight + 5);
    }];
    //刷新菜单按钮
    [self reloadMenuItems];
    
    [self setExpanded:self.topSubVC.isExpanded animated:NO];
}

- (void)reloadMenuItems {
    [self.popoverMenu dismissWithAnimated:YES];
    
    MutInsStatus status = self.groupDetail.rsp_status;
    if (status == MutInsStatusToBePaid || status == MutInsStatusPaidForAll || status == MutInsStatusPaidForSelf) {
        self.menuItems = $([self menuItemMyOrder], [self menuItemMakeCall]);
    }
    else if (status == MutInsStatusAgreementTakingEffect) {
        self.menuItems = $([self menuItemMyOrder], [self menuItemInvite], [self menuItemMakeCall]);
    }
    else if (status == MutInsStatusReviewFailed || status == MutInsStatusGroupDissolved ||
             status == MutInsStatusGroupExpired || status == MutInsStatusJoinFailed) {
        self.menuItems = $([self menuItemRegroup], [self menuItemDeleteGroup], [self menuItemMakeCall]);
    }
    else {
        self.menuItems = $([self menuItemInvite], [self menuItemQuit], [self menuItemMakeCall]);
    }
}

#pragma mark - Request
- (void)requestExitGroup {
    ExitCooperationOp * op = [[ExitCooperationOp alloc] init];
    op.req_memberid = self.group.memberId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"退团中..."];
    }] subscribeNext:^(ExitCooperationOp * rop) {
        @strongify(self);
        [gToast dismiss];
        [[self.minsStore reloadSimpleGroups] sendAndIgnoreError];
        for (UIViewController * vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:NSClassFromString(@"MutualInsHomeVC")])
            {
                [self.navigationController popToViewController:vc animated:YES];
                return ;
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)requestDeleteGroup {
    DeleteCooperationGroupOp *op = [DeleteCooperationGroupOp operation];
    op.req_groupid = self.group.groupId;
    op.req_memberid = self.group.memberId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在删除团..."];
    }] subscribeNext:^(id x) {

        @strongify(self);
        [gToast showSuccess:@"删除成功！"];
        [self actionBack:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - MenuItems
- (CKDict *)menuItemInvite {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"邀请入团",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
        vc.groupId = self.groupDetail.rsp_groupid;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuItemQuit {
    if (self.groupDetail.rsp_ifgroupowner) {
        return CKNULL;
    }
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
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
        vc.contractId = self.groupDetail.rsp_contractid;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

///重新组团
- (CKDict *)menuItemRegroup {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Regroup",@"title":@"重新组团",@"img":@"mins_regroup"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CreateGroupVC * vc = [UIStoryboard vcWithId:@"CreateGroupVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

///删除该团
- (CKDict *)menuItemDeleteGroup {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Delete",@"title":@"删除该团",@"img":@"mins_close"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [self requestDeleteGroup];
    });
    return dict;
}

#pragma mark - Animate
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    self.isExpandingOrClosing = YES;
    self.topSubVC.isExpanded = expanded;
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    CGFloat bottom = expanded ? dvalue : 0;
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(0, expanded ? 0 : dvalue);
            self.bottomSubVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
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
        self.bottomSubVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
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

