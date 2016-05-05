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
#import "HKMessageAlertVC.h"

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

@property (nonatomic, assign) CGFloat bottomScrollViewOffsetY;

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
        self.topSubVC.group = self.group;
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
    
    [self.bottomSubVC setDidMessageAvatarTaped:^(NSNumber *memberID) {
        @strongify(self);
        [self.topSubVC requestDetailInfoForMember:memberID];
    }];

    [self.bottomSubVC setDidScrollBlock:^(UIScrollView *scrollView, CGPoint newOffset, CGPoint oldOffset) {
        @strongify(self);
        CGFloat dvalue = newOffset.y - oldOffset.y;
        self.bottomScrollViewOffsetY = dvalue >= 0 ? self.bottomScrollViewOffsetY + dvalue : 0;
        if (self.bottomScrollViewOffsetY > 20 && !self.isExpandingOrClosing) {
            [self setExpanded:NO animated:YES];
        }
    }];
}

- (void)setupMutualInsStore {
    self.minsStore = [MutualInsStore fetchOrCreateStore];
    @weakify(self);
    [self.minsStore subscribeWithTarget:self domain:kDomainMutualInsDetailGroups receiver:^(id store, CKEvent *evt) {
        
        @strongify(self);
        GetCooperationMygroupDetailOp *op = evt.object;
        if ([self.group.groupId isEqual:op.req_groupid]) {
            self.group.memberId = op.req_memberid;
            [self reloadFromSignal:evt.signal];
        }
    } ];
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
    if (!closing) {
        [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0001"}];
    }

    [self.menuButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        NSArray *items = [self.menuItems.allObjects arrayByMappingOperator:^id(CKDict *obj) {
            return [HKPopoverViewItem itemWithTitle:obj[@"title"] imageName:obj[@"img"]];
        }];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 320) items:items];
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
    [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0002"}];
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
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取团详情失败，点击重试" tapBlock:^{
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
    if (status == MutInsStatusUnderReview) {
        self.menuItems = $([self menuItemInvite], [self menuItemMakeCall], [self menuItemUsinghelp]);
    }
    else if (status == MutInsStatusAgreementTakingEffect) {
        self.menuItems = $([self menuItemInvite], [self menuItemMyOrder], [self menuItemMakeCall], [self menuItemUsinghelp]);
    }
    else if (status == MutInsStatusToBePaid || status == MutInsStatusPaidForAll ||
             status == MutInsStatusPaidForSelf || status == MutInsStatusGettedAgreement) {
        self.menuItems = $([self menuItemInvite], [self menuItemMyOrder], [self menuItemMakeCall], [self menuItemUsinghelp]);
    }
    else if (status == MutInsStatusReviewFailed || status == MutInsStatusGroupDissolved ||
             status == MutInsStatusGroupExpired || status == MutInsStatusJoinFailed) {
        self.menuItems = $([self menuItemInvite], [self menuItemRegroup], [self menuItemDeleteGroup], [self menuItemMakeCall],
                           [self menuItemUsinghelp]);
    }
    else {
        self.menuItems = $([self menuItemInvite], [self menuItemQuit], [self menuItemMakeCall], [self menuItemUsinghelp]);
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
        [[self.minsStore reloadSimpleGroups] send];
        [self actionBack:nil];
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
        [[self.minsStore reloadSimpleGroups] send];
        [self actionBack:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - MenuItems
- (id)menuItemInvite {
    if (self.groupDetail.rsp_invitebtnflag == 0) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"邀请好友",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0007"}];
        InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
        vc.groupId = self.groupDetail.rsp_groupid;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuItemQuit {
    //如果是自助团团长且团长没有车，应该隐藏掉退团按钮
    if (self.groupDetail.rsp_ifgroupowner && !self.groupDetail.rsp_ifownerhascar) {
        return CKNULL;
    }
    
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Quit",@"title":@"退出该团",@"img":@"mins_exit"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0008"}];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:kDefTintColor clickBlock:^(id alertVC) {
            [self requestExitGroup];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您确认退出该团？退出后将无法查看团内信息。" ActionItems:@[cancel,confirm]];
        [alert show];
    });
    return dict;
}

- (CKDict *)menuItemMakeCall {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Call",@"title":@"联系客服",@"img":@"mins_phone"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0009"}];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [gPhoneHelper makePhone:@"4007111111"];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客户电话\n 4007-111-111" ActionItems:@[cancel,confirm]];
        [alert show];
    });
    return dict;
}

- (CKDict *)menuItemMyOrder {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Order",@"title":@"我的订单",@"img":@"mins_order"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0012"}];
        MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
        vc.contractId = self.groupDetail.rsp_contractid;
        vc.group = self.group;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

///重新组团
- (id)menuItemRegroup {
    if (self.groupDetail.rsp_type == 2) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Regroup",@"title":@"重新组团",@"img":@"mins_regroup"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CreateGroupVC * vc = [UIStoryboard vcWithId:@"CreateGroupVC" inStoryboard:@"MutualInsJoin"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

///删除该团
- (id)menuItemDeleteGroup {
    
    if (self.groupDetail.rsp_ifgroupowner) {
        id member = [self.groupDetail.rsp_members firstObjectByFilteringOperator:^BOOL(MutualInsMemberInfo *info) {
            return info.showflag;
        }];
        if (member) {
            return CKNULL;
        }
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Delete",@"title":@"删除该团",@"img":@"mins_close"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0013"}];
        [self requestDeleteGroup];
    });
    return dict;
}

//使用帮助
- (id)menuItemUsinghelp
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Help",@"title":@"使用帮助",@"img":@"questionMark_300"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {

        @strongify(self);
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        vc.url = @"http://xiaomadada.com/apphtml/tuanxiangqing-help.html";
        [self.navigationController pushViewController:vc animated:YES];
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
            self.bottomScrollViewOffsetY = 0;
        }];
    }
    else {
        self.scrollView.contentOffset = CGPointMake(0, expanded ? 0 : dvalue);
        self.isExpandingOrClosing = NO;
        self.topSubVC.shouldStopWaveView = !expanded;
        self.bottomScrollViewOffsetY = 0;
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

