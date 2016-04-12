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
#import "CarsListVC.h"
#import "HKTableViewCell.h"
#import "GuideStore.h"
#import "DetailWebVC.h"
#import "CKDatasource.h"
#import "MyCarStore.h"
#import "HKMyCar.h"
#import "CarsListVC.h"

#import "ShopDetailVC.h"

@interface MineVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *PlaceholdLabel;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) GuideStore *guideStore;
@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) HKMyCar *myDefaultCar;
@property (nonatomic, assign) BOOL shouldShowNewbieDot;

@property (nonatomic, assign) BOOL isViewAppearing;
@property (nonatomic, assign) BOOL isCarVC;

@end

@implementation MineVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MineVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBgView];
    [self observeUserInfo];
    [self setupGuideStore];
    [self setupMyCarStore];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    self.isCarVC = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    //如果当前视图的导航条没有发生跳转，则不做处理
    if (![self.navigationController.topViewController isEqual:self]) {
        //如果当前视图的viewWillAppear和viewWillDisappear的间隔太短会导致navigationBar隐藏显示不正常
        //所以此时应该禁止navigationBar的动画,并在主线程中进行
        if (self.isViewAppearing) {
            CKAsyncMainQueue(^{
                if (!self.isCarVC) {
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                }
            });
        }
        else {
            if (!self.isCarVC) {
                [self.navigationController setNavigationBarHidden:NO animated:animated];
            }
            
        }
        self.isCarVC = NO;
    }
}

#pragma mark - Setup
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

//设置新手引导的store
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

//设置爱车的store
- (void)setupMyCarStore
{
    self.carStore = [MyCarStore fetchOrCreateStore];
    @weakify(self);
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(id store, CKEvent *evt) {
        
        @strongify(self);
        [[evt signal] subscribeNext:^(id x) {
            @strongify(self);
            self.myDefaultCar = [self.carStore defalutCar];
        }];
    }];
}

#pragma mark - Datasource
- (CKDict *)topData
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"top", kCKCellID:@"TopCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 69;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        UIButton *leftBtn = [cell.contentView viewWithTag:1002];
        UIButton *rightBtn = [cell.contentView viewWithTag:2002];
        
        [[[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionPushToTickets];
         }];
        
        [[[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionPushToCouponPkgViewController];
         }];
        
        [[[[RACObserve(gAppMgr, myUser) distinctUntilChanged] flattenMap:^RACStream *(JTUser *user) {
            
            if (user) {
                return [RACObserve(user, hasNewMsg) distinctUntilChanged];
            }
            return [RACSignal return:@NO];
        }] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber *hasmsg) {
            
            BOOL showDot = [hasmsg boolValue];
            if (showDot) {
//                [rightTitleL showDotWithOffset:CGPointMake(36, 0)];
                [self.messagesButton setHighlighted:YES];
            }
            else {
//                [rightTitleL hideDot];
                [self.messagesButton setHighlighted:NO];
            }
        }];
        
//        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
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
        UILabel *licenseLabel = (UILabel *)[cell.contentView viewWithTag:1003];
        hkcell.customSeparatorInset = UIEdgeInsetsMake(0, 48, 0, 0);
        
        iconV.image = [UIImage imageNamed:data[@"img"]];
        titleL.text = data[@"title"];

        BOOL isContainlicenseLb = [data[@"isContainLicense"] boolValue];
        licenseLabel.hidden = !isContainlicenseLb;
        
        [[RACObserve(self,myDefaultCar) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(HKMyCar *defaultCar) {
            
            licenseLabel.text = defaultCar.licencenumber;
        }];
        
        [hkcell prepareCellForTableView:self.tableView atIndexPath:indexPath];
        
        [self removeSectionSeparatorInHKTableViewCell:hkcell];
    });

    return data;
}

// 移除 Section 的分割线
- (void)removeSectionSeparatorInHKTableViewCell:(HKTableViewCell *)cell;
{
    if (!cell.currentIndexPath ||
        [cell.targetTableView numberOfRowsInSection:cell.currentIndexPath.section] > cell.currentIndexPath.row+1) {
        
    } else {
        
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalBottom];
        
    }
    
    if (cell.currentIndexPath.row == 0) {
        
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
        
    }
    else {
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
    }
}

- (CKDict *)activeData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"ActiveCell"}];

    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 73;
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
        
        [self removeSectionSeparatorInHKTableViewCell:hkcell];
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

- (void)actionPushToCouponPkgViewController
{
    [MobClick event:@"rp301_6"];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        CouponPkgViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"CouponPkgViewController"];
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
    return 48;
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


#pragma mark - Utility
- (void)refreshAvatarView
{
    if (gAppMgr.myUser.avatarUrl.length)
    {
        [self.avatarView setImageByUrl:gAppMgr.myUser.avatarUrl withType:ImageURLTypeMedium defImage:@"Common_Avatar_imageView" errorImage:@"Common_Avatar_imageView"];
    }
    else
    {
        self.avatarView.image = [UIImage imageNamed:@"Common_Avatar_imageView"];
    }
}

- (void)observeUserInfo
{
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(JTUser *user) {
        
        @strongify(self);
        if (!user) {
            self.avatarView.image = [UIImage imageNamed:@"Common_Avatar_imageView"];
            self.nameLabel.hidden = NO;
            self.accountLabel.hidden = NO;
            self.PlaceholdLabel.hidden = YES;
            self.nameLabel.text = @"未登录";
            self.accountLabel.text = @"点击登录";
            self.myDefaultCar = nil;
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
                return [gMediaMgr rac_getImageByUrl:url withType:ImageURLTypeMedium defaultPic:@"Common_Avatar_imageView" errorPic:@"Common_Avatar_imageView"];
            }] subscribeNext:^(id x) {
                
                [UIView transitionWithView:avatarView
                                  duration:1.0
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [avatarView setImage:x];
                                    avatarView.alpha = 1.0;
                                } completion:NULL];
            }];
            [self reloadUserInfo];
            [self reloadData];
        }
    }];
}

- (void)reloadUserInfo
{
    [[GetUserBaseInfoOp rac_fetchUserBaseInfo] subscribeNext:^(GetUserBaseInfoOp *op) {
        
        [self.tableView reloadData];
    }];
}

- (IBAction)messagesButton:(UIButton *)sender
{
    [self actionPushToMessages];
}

- (void)reloadData
{
    [[self.carStore getDefaultCar] send];
    
    CKDict *top = [self topData];
    
    CKDict *car = [self normalDataWithInfo:@{kCKItemKey:@"car", @"img":@"Mine_myCar_imageView", @"title":@"爱车", @"evt":@"rp301_4",@"isContainLicense":@(YES)}];
    car[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        CarsListVC *vc = [UIStoryboard vcWithId:@"CarsListVC" inStoryboard:@"Car"];
        vc.model.allowAutoChangeSelectedCar = YES;
        self.isCarVC = YES;
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *bank = [self normalDataWithInfo:@{kCKItemKey:@"bank", @"img":@"Mine_bankCard_imageView", @"title":@"银行卡", @"evt":@"rp301_10"}];
    bank[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        UIViewController *vc = [UIStoryboard vcWithId:@"MyBankVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *order = [self normalDataWithInfo:@{kCKItemKey:@"order", @"img":@"Mine_order_imageView", @"title":@"订单", @"evt":@"rp301_5"}];
    order[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        MyOrderListVC *vc = [UIStoryboard vcWithId:@"MyOrderListVC" inStoryboard:@"Mine"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    
    CKDict *collect = [self normalDataWithInfo:@{kCKItemKey:@"collect", @"img":@"Mine_collectStar_imageView", @"title":@"收藏", @"evt":@"rp301_7"}];
    collect[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        MyCollectionViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyCollectionViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    CKDict *active = [self activeData];
    
    CKDict *setting = [self normalDataWithInfo:@{kCKItemKey:@"setting", @"img":@"Mine_about_imageView", @"title":@"关于", @"evt":@"rp301_8", @"nologin":@YES}];
    setting[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        AboutViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    self.datasource = $($(top),
                        $(car,bank),
                        $(order, collect),
                        $(active),
                        $(setting));
    [self.tableView reloadData];
}




@end
