//
//  MutualInsGroupDetailVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailVC.h"
#import "HorizontalScrollTabView.h"
#import "MutualInsGroupDetailVM.h"
#import "MutualInsConstants.h"
#import "MutualInsStore.h"
#import "HKPopoverView.h"
#import "ExitCooperationOp.h"
#import "DeleteCooperationGroupOp.h"

NSString *const kIgnoreBaseInfo = @"_MutualInsIgnoreBaseInfo";

@interface MutualInsGroupDetailVC ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) HorizontalScrollTabView *tabBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) HKPopoverView *popoverMenu;

@property (nonatomic, strong) MutualInsGroupDetailVM *viewModel;
@property (nonatomic, strong) CKList *viewControllers;
@property (nonatomic, strong) CKList *tabItems;
@property (nonatomic, strong) CKList *menuItems;
@end

@implementation MutualInsGroupDetailVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kBackgroundColor;
    self.viewControllers = [CKList list];
    [self setupViewModel];
    [self setupNavigation];
    [self setupContainerView];
    [self setupTabBar];
    [self subscribeSignals];
    [self refetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}

#pragma mark - Setup
- (void)setupViewModel {
    self.viewModel = [MutualInsGroupDetailVM fetchOrCreateForGroupID:self.router.userInfo[kMutInsGroupID]
                                                            memberID:self.router.userInfo[kMutInsMemberID]];
}

- (void)setupNavigation {
    self.navigationItem.title = self.router.userInfo[kMutInsGroupName];
    if (![self.router.userInfo[kIgnoreBaseInfo] boolValue]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mins_menu"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(actionShowOrHideMenu:)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)setupContainerView {
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.backgroundColor = kBackgroundColor;
    [self.view addSubview:self.containerView];
}

- (void)setupTabBar {
    self.tabBar = [[HorizontalScrollTabView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.tabBar];
    self.tabBar.scrollTipBarColor = kDefTintColor;
    
    @weakify(self);
    [self.tabBar setTabBlock:^(NSInteger index) {
        @strongify(self);
        CKDict *curItem = self.tabItems[index];
        [self actionSelectTabItem:curItem];
        [self reloadDotView];
    }];
}

- (void)setupChildVCWithTabItem:(CKDict *)item {
    UIViewController *vc = [[NSClassFromString(item[@"class"]) alloc] init];
    vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
    [self addChildViewController:vc];
    [self.viewControllers addObject:vc forKey:item.key];
}

- (void)refetchData {
    if (![self.router.userInfo[kIgnoreBaseInfo] boolValue]) {
        [self.viewModel fetchBaseInfoForce:YES];
    }
    else {
        [self reloadTabBar];
    }
}
#pragma mark - Signal
- (void)subscribeSignals {
    @weakify(self);
    [[[RACObserve(self.viewModel, reloadBaseInfoSignal) distinctUntilChanged] filter:^BOOL(id value) {
         
         @strongify(self);
         return ![self.router.userInfo[kIgnoreBaseInfo] boolValue];
     }] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.containerView setHidden:YES animated:NO];
            CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
        }] subscribeNext:^(id x) {

            @strongify(self);
            [self.view stopActivityAnimation];
            [self.containerView setHidden:NO animated:YES];
            self.navigationItem.title = self.viewModel.baseInfo.rsp_groupname;
            [self reloadTabBar];
            [self reloadNavMenu];
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:error.domain tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self.viewModel fetchBaseInfoForce:YES];
            }];
        }];
    }];
}

#pragma mark - Action
- (void)actionBack:(id)sender {
    [MobClick event:@"hztuanxiangqiang" attributes:@{@"navi":@"back"}];
    [super actionBack:sender];
}


- (void)actionShowOrHideMenu:(id)sender {
    [MobClick event:@"hztuanxiangqiang" attributes:@{@"navi":@"caidan"}];
    
    if (self.popoverMenu.isActivated) {
        [self.popoverMenu dismissWithAnimated:YES];
        return;
    }
    
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
    [popover showAtAnchorPoint:CGPointMake(ScreenWidth-28, 60)
                        inView:self.navigationController.view dismissTargetView:self.view animated:YES];
    self.popoverMenu = popover;
}

- (void)actionSelectTabItem:(CKDict *)item {
    if (![self.viewControllers objectForKey:item.key]) {
        [self setupChildVCWithTabItem:item];
    }
    for (CKDict *aitem in [self.tabItems allObjects]) {
        UIViewController *vc = self.viewControllers[aitem.key];
        if ([item isEqual:aitem]) {
            vc.view.frame = CGRectMake(0, 45, ScreenWidth, self.view.frame.size.height - 45);
            vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [self.containerView addSubview:vc.view];
        } else {
            [vc.view removeFromSuperview];
        }
    }
    CKCellSelectedBlock selectedBlock = item[kCKCellSelected];
    if (selectedBlock) {
        selectedBlock(item, nil);
    }
}

#pragma mark - Menu
- (void)reloadNavMenu {
    [self.popoverMenu dismissWithAnimated:YES];
    self.menuItems = $([self menuItemMyOrder],
                       [self menuItemInvite],
                       [self menuItemQuit],
                       [self menuItemMakeCall],
                       [self menuItemDeleteGroup],
                       [self menuItemUsinghelp]);
}

- (id)menuItemInvite {
    if (self.viewModel.baseInfo.rsp_invitebtnflag == 0) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Invite",@"title":@"邀请好友",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"caidan":@"yaoqing"}];
        UIViewController * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
        [vc setValue:self.viewModel.baseInfo.req_groupid forKey:@"groupId"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuItemQuit {
    if (self.viewModel.baseInfo.rsp_isexit == 0) {
        return CKNULL;
    }
    
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Quit",@"title":@"退出该团",@"img":@"mins_exit"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"caidan":@"tuichu"}];
        
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
        
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"caidan":@"kefu"}];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [gPhoneHelper makePhone:@"4007111111"];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客户电话\n 4007-111-111" ActionItems:@[cancel,confirm]];
        [alert show];
    });
    return dict;
}

- (id)menuItemMyOrder {
    if ([self.viewModel.baseInfo.rsp_contractid integerValue] == 0) {
        return CKNULL;
    }
    
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Order",@"title":@"我的订单",@"img":@"mins_order"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"caidan":@"dingdan"}];
        UIViewController *vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
        [vc setValue:self.viewModel.baseInfo.rsp_contractid forKey:@"contractId"];
        vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
        vc.router.userInfo[kOriginRoute] = self.router;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

///删除该团
- (id)menuItemDeleteGroup {
    if (self.viewModel.baseInfo.rsp_isdelete == 0) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Delete",@"title":@"删除该团",@"img":@"mins_close"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"caidan":@"shantuan"}];
        HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
        alert.topTitle = @"温馨提示";
        alert.imageName = @"mins_bulb";
        alert.message = @"删除后，您将无法看到该团记录。确定现在删除？";
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        @weakify(self);
        HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            
            @strongify(self);
            [self requestDeleteGroup];
        }];
        alert.actionItems = @[cancel, improve];
        [alert show];
    });
    return dict;
}

//使用帮助
- (id)menuItemUsinghelp
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"Help",@"title":@"使用帮助",@"img":@"mins_question"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"caidan":@"shiyongbangzhu"}];
        UIViewController *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        [vc setValue:self forKey:@"originVC"];
        [vc setValue:kMutualInsGroupDetailHelpUrl forKey:@"url"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

#pragma mark - DotView
- (void)reloadDotView {
    long long timetag =  self.viewModel.baseInfo.rsp_huzhulstupdatetime;
    BOOL hidden = ![self.viewModel shouldUpdateTimetag:timetag forKey:@"fund"];
    [self.tabBar setDotHidden:hidden atIndex:[self.tabItems indexOfObjectForKey:@"fund"]];
    
    timetag = self.viewModel.baseInfo.rsp_newslstupdatetime;
    hidden = ![self.viewModel shouldUpdateTimetag:timetag forKey:@"message"];
    [self.tabBar setDotHidden:hidden atIndex:[self.tabItems indexOfObjectForKey:@"message"]];
}

#pragma mark - TabBar
- (void)reloadTabBar {
    self.tabItems = $([self tabItemMe], [self tabItemFund],
                      [self tabItemMembers], [self tabItemNoticeBoard],
                      [self tabItemMessages]
                      );
    NSInteger selectedIndex = 0;
    
    self.tabBar.items = [[self.tabItems allObjects] arrayByMappingOperator:^id(CKDict *dict) {
        return [HorizontalScrollTabItem itemWithTitle:dict[@"title"] normalColor:kBlackTextColor selectedColor:kDefTintColor];
    }];
    //显示所有tab
    [self.tabBar reloadDataWithBoundsSize:CGSizeMake(ScreenWidth, 45) andSelectedIndex:selectedIndex];
    //加载小红点
    [self reloadDotView];
    //选中一个tab
    CKDict *item = self.tabItems[selectedIndex];
    [self actionSelectTabItem:item];
}

- (id)tabItemMe {
    if (self.viewModel.baseInfo.rsp_showselfflag == 0 || [self.router.userInfo[kIgnoreBaseInfo] boolValue]) {
        return CKNULL;
    }
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"me", @"title": @"我", @"class": @"MutualInsGroupDetailMeVC"}];
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"dingbu":@"wo"}];
        [self.viewModel fetchMyInfoForce:NO];

    });
    return item;
}


- (CKDict *)tabItemFund {
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"fund", @"title": @"互助金", @"class": @"MutualInsGroupDetailFundVC"}];
    
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"dingbu":@"huzhujin"}];
        NSString *key = data[kCKItemKey];
        [self.viewModel fetchFundInfoForce:NO];
        //保存时间戳
        [self.viewModel saveTimetagIfNeeded:self.viewModel.baseInfo.rsp_huzhulstupdatetime forKey:key];
    });
    return item;
    
}

- (CKDict *)tabItemMembers {
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"member", @"title": @"成员", @"class": @"MutualInsGroupDetailMembersVC"}];

    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"dingbu":@"chengyuan"}];
        [self.viewModel fetchMembersInfoForce:NO];
    });
    return item;
    
}

- (id)tabItemNoticeBoard {
    
    if (self.viewModel.baseInfo.rsp_showpublicityflag == 0 || [self.router.userInfo[kIgnoreBaseInfo] boolValue]) {
        return CKNULL;
    }
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"notice", @"title": @"公示", @"class": @"MutualInsGroupDetailNoticeBoardVC"}];
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        // 提前加上友盟
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"dingbu":@"gongshi"}];
        [self.viewModel fetchNoticeInfoForce:NO];
        
    });
    return item;
}

- (CKDict *)tabItemMessages {
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"message", @"title": @"动态", @"class": @"MutualInsGroupDetailMessagesVC"}];
    
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"hztuanxiangqiang" attributes:@{@"dingbu":@"dongtai"}];
        NSString *key = data[kCKItemKey];
        [self.viewModel fetchMessagesInfoForce:NO];
        //保存时间戳
        [self.viewModel saveTimetagIfNeeded:self.viewModel.baseInfo.rsp_newslstupdatetime forKey:key];
    });
    return item;
}

#pragma mark - Request
- (void)requestExitGroup {
    ExitCooperationOp * op = [[ExitCooperationOp alloc] init];
    op.req_memberid = self.viewModel.baseInfo.req_memberid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"退团中..."];
    }] subscribeNext:^(ExitCooperationOp * rop) {
        @strongify(self);
        [gToast dismiss];
        [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] send];
        [self actionBack:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)requestDeleteGroup {
    DeleteCooperationGroupOp *op = [DeleteCooperationGroupOp operation];
    op.req_groupid = self.viewModel.baseInfo.req_groupid;
    op.req_memberid = self.viewModel.baseInfo.req_memberid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在删除团..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast showSuccess:@"删除成功！"];
        [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] send];
        [self actionBack:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}
@end
