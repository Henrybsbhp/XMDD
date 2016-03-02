//
//  MineVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MineVC.h"
#import "XiaoMa.h"
#import "GetUserBaseInfoOp.h"
#import "MyOrderListVC.h"
#import "MyCouponVC.h"
#import "MyInfoViewController.h"
#import "AboutViewController.h"
#import "MessageListVC.h"
#import "MyCollectionViewController.h"
#import "CouponPkgViewController.h"
#import "UIView+ShowDot.h"
#import "CardDetailVC.h"
#import "UnbundlingVC.h"
#import "CarListVC.h"
#import "HKTableViewCell.h"
#import "GuideStore.h"
#import "DetailWebVC.h"
#import "CKDatasource.h"

@interface MineVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *PlaceholdLabel;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) GuideStore *guideStore;
@property (nonatomic, assign) BOOL shouldShowNewbieDot;

@end

@implementation MineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBgView];
    [self observeUserInfo];
    [self setupGuideStore];
    [self reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MineVC dealloc");
}

- (void)setupBgView
{
    @weakify(self);
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view.mas_top).offset(0);
    }];
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] init];
    [self.bgView addGestureRecognizer:gesture];
    self.bgView.userInteractionEnabled = YES;
    [[gesture rac_gestureSignal] subscribeNext:^(id x) {
        
        if([LoginViewModel loginIfNeededForTargetViewController:self])
        {
            [MobClick event:@"rp301_9"];
            MyInfoViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyInfoViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [MobClick event:@"rp301_1"];
        }
    }];
}

- (void)refreshAvatarView
{
    if (gAppMgr.myUser.avatarUrl.length)
    {
        [self.avatarView setImageByUrl:gAppMgr.myUser.avatarUrl withType:ImageURLTypeMedium defImage:@"cm_avatar" errorImage:@"cm_avatar"];
    }
    else
    {
        self.avatarView.image = [UIImage imageNamed:@"cm_avatar"];
    }
}

- (void)observeUserInfo
{
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(JTUser *user) {
        
        @strongify(self);
        if (!user) {
            self.avatarView.image = [UIImage imageNamed:@"cm_avatar"];
            self.nameLabel.hidden = YES;
            self.accountLabel.hidden = YES;
            self.PlaceholdLabel.hidden = NO;
            [self.tableView reloadData];
        }
        else {
            self.PlaceholdLabel.hidden = YES;
            self.nameLabel.hidden = NO;
            self.accountLabel.hidden = NO;
            RAC(self.nameLabel, text) = RACObserve(user, userName);
            RAC(self.accountLabel, text) = RACObserve(user, userID);
            UIImageView *avatarView = self.avatarView;
            [[[RACObserve(user, avatarUrl) distinctUntilChanged] flattenMap:^RACStream *(NSString *url) {
                return [gMediaMgr rac_getImageByUrl:url withType:ImageURLTypeMedium defaultPic:@"cm_avatar" errorPic:@"cm_avatar"];
            }] subscribeNext:^(id x) {
                
                [UIView transitionWithView:avatarView
                                  duration:1.0
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [avatarView setImage:x];
                                    avatarView.alpha = 1.0;
                                } completion:NULL];
//                avatarView.image = x;
            }];
            [self reloadUserInfo];
        }
    }];
}

- (void)reloadUserInfo
{
    [[GetUserBaseInfoOp rac_fetchUserBaseInfo] subscribeNext:^(GetUserBaseInfoOp *op) {

        [self.tableView reloadData];
    }];
}

#pragma mark - Guide
- (void)setupGuideStore
{
    self.guideStore = [GuideStore fetchOrCreateStore];
    self.shouldShowNewbieDot = self.guideStore.shouldShowNewbieGuideDot;
    @weakify(self);
    [self.guideStore subscribeWithTarget:self domain:kDomainNewbiewGuide receiver:^(CKStore *store, CKEvent *evt) {
        @strongify(self);
        [[evt signal] subscribeNext:^(id x) {
            @strongify(self);
            self.shouldShowNewbieDot = self.guideStore.shouldShowNewbieGuideDot;
        }];
    }];
}

#pragma mark - Datasource
- (void)reloadData
{
    CKDict *top = [self topData];
    CKDict *car = [self normalDataWithInfo:@{kCKItemKey:@"car", @"img":@"me_car", @"title":@"爱车", @"evt":@"rp301_4"}];
    car[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
        [self.navigationController pushViewController:vc animated:YES];
    });

    CKDict *bank = [self normalDataWithInfo:@{kCKItemKey:@"bank", @"img":@"me_bank", @"title":@"银行卡", @"evt":@"rp301_10"}];
    bank[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        UIViewController *vc = [UIStoryboard vcWithId:@"MyBankVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *order = [self normalDataWithInfo:@{kCKItemKey:@"order", @"img":@"me_order", @"title":@"订单", @"evt":@"rp301_5"}];
    order[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        MyOrderListVC *vc = [UIStoryboard vcWithId:@"MyOrderListVC" inStoryboard:@"Mine"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *pkg = [self normalDataWithInfo:@{kCKItemKey:@"pkg", @"img":@"me_pkg", @"title":@"礼包", @"evt":@"rp301_6"}];
    pkg[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        CouponPkgViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"CouponPkgViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *collect = [self normalDataWithInfo:@{kCKItemKey:@"collect", @"img":@"me_collect", @"title":@"收藏", @"evt":@"rp301_7"}];
    collect[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        MyCollectionViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyCollectionViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *active = [self activeData];
    
    CKDict *setting = [self normalDataWithInfo:@{kCKItemKey:@"setting", @"img":@"me_setting", @"title":@"关于", @"evt":@"rp301_8", @"nologin":@YES}];
    setting[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        AboutViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });

    self.datasource = $($(top),
                        $(car,bank,order,pkg,collect),
                        $(active),
                        $(setting));
    [self.tableView reloadData];
}

- (CKDict *)topData
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"top", kCKCellID:@"TopCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 64;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKTableViewCell *hkcell = (HKTableViewCell *)cell;
        UIButton *leftBtn = [cell.contentView viewWithTag:1002];
        UILabel *rightTitleL = [cell.contentView viewWithTag:2001];
        UIButton *rightBtn = [cell.contentView viewWithTag:2002];
        
        [[[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionPushToTickets];
         }];
        
        [[[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionPushToMessages];
         }];
        
        [[[[RACObserve(gAppMgr, myUser) distinctUntilChanged] flattenMap:^RACStream *(JTUser *user) {
            
            if (user) {
                return [RACObserve(user, hasNewMsg) distinctUntilChanged];
            }
            return [RACSignal return:@NO];
        }] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber *hasmsg) {
            
            BOOL showDot = [hasmsg boolValue];
            if (showDot) {
                [rightTitleL showDotWithOffset:CGPointMake(36, 0)];
            }
            else {
                [rightTitleL hideDot];
            }
        }];
        
        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    });
    return data;
}

- (CKDict *)normalDataWithInfo:(NSDictionary *)info
{
    CKDict *data = [CKDict dictWith:info];
    data[kCKCellID] = @"NormalCell";
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        HKTableViewCell *hkcell = (HKTableViewCell *)cell;
        UIImageView *iconV = [cell.contentView viewWithTag:1001];
        UILabel *titleL = [cell.contentView viewWithTag:1002];
        UILabel *subTitleL = [cell.contentView viewWithTag:1003];
        
        iconV.image = [UIImage imageNamed:data[@"img"]];
        titleL.text = data[@"title"];
        subTitleL.text = nil;
        
        [hkcell prepareCellForTableView:self.tableView atIndexPath:indexPath];
    });

    return data;
}

- (CKDict *)activeData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"ActiveCell"}];

    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 64;
    });

    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        HKTableViewCell *hkcell = (HKTableViewCell *)cell;
        UIImageView *dotV = [cell viewWithTag:1003];
        
        [[RACObserve(self, shouldShowNewbieDot) takeUntilForCell:cell] subscribeNext:^(NSNumber *show) {
            dotV.hidden = ![show boolValue];
        }];
        
        [hkcell prepareCellForTableView:self.tableView atIndexPath:indexPath];
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp301_11"];
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.url = kNewbieGuideUrl;
        [self.navigationController pushViewController:vc animated:YES];
        [self.guideStore setNewbieGuideAppeared];
    });
    
    return data;
}

#pragma mark - Action
-(void)actionPushToTickets
{
    [MobClick event:@"rp301_2"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPushToMessages
{
    [MobClick event:@"rp301_3"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        MessageListVC *vc = [UIStoryboard vcWithId:@"MessageListVC" inStoryboard:@"Message"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.datasource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    if (data[@"evt"]) {
        [MobClick event:data[@"evt"]];
    }
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        //无需登录
        if ([data[@"nologin"] boolValue]) {
            block(data, indexPath);
        }
        //需要登录
        else if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            block(data, indexPath);
        }
    }
}


@end
