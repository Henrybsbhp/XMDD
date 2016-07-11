//
//  MutualInsHomeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeVC.h"
#import "SystemGroupListVC.h"
#import "GroupIntroductionVC.h"
#import "MutualInsGrouponVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsAskClaimsVC.h"
#import "GetCooperationConfiOp.h"
#import "GetCooperationMyGroupOp.h"
#import "HKMutualGroup.h"
#import "HKTimer.h"
#import "MutualInsStore.h"
#import "MutualInsPicUpdateVC.h"
#import "UIView+JTLoadingView.h"
#import "UIView+RoundedCorner.h"
#import "DeleteCooperationGroupOp.h"
#import "AddCloseAnimationButton.h"
#import "HKPopoverView.h"
#import "EditCarVC.h"
#import "MutualInsSuspendedAdVC.h"
#import "HKAdvertisement.h"
#import "AdListData.h"
#import "MutualInsAskForCompensationVC.h"

@interface MutualInsHomeVC ()

@property (nonatomic, strong) AddCloseAnimationButton *menuButton;
@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) CKList *menuItems;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *datasource;

@property (nonatomic, strong) GetCooperationConfiOp *config;
@property (nonatomic, strong) MutualInsStore *minsStore;
@property (nonatomic, strong) NSMutableArray * myGroupArray;
@property (nonatomic, strong) NSMutableArray <HKMutualCar *> *myCarArray;

@property (nonatomic, assign) NSTimeInterval leftTime;

@property (nonatomic, assign) BOOL isViewAppearing;
@property (nonatomic, assign) BOOL isShowSuspendedAd;
@end

@implementation MutualInsHomeVC

-(void)dealloc
{
    DebugLog(@"MutualInsHomeVC dealloc");
}

- (void)awakeFromNib {
    self.router.key = @"MutualInsHomeVC";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"shouye" attributes:@{@"shouye":@"shouye0001"}];
    
    [self setNavigationBar];
    [self setItemList];
    [self setupMutualInsStore];
    self.tableView.hidden = YES;
    CKAsyncMainQueue(^{
        [self reloadIfNeeded];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    [self showSuspendedAdIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAppearing = NO;
    [self.popoverMenu dismissWithAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showSuspendedAdIfNeeded
{
    if (self.isViewAppearing && !self.isShowSuspendedAd) {
        
        self.isShowSuspendedAd = YES;
        
        @weakify(self);
        RACSignal *signal = [gAdMgr rac_getAdvertisement:AdvertisementMutualIns];
        [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
            
            @strongify(self);
            NSMutableArray * mutableArr = [[NSMutableArray alloc] init];
            for (int i = 0; i < ads.count; i ++) {
                HKAdvertisement * adDic = ads[i];
                //广告是否已经看过
                if (![AdListData checkAdAlreadyAppeard:adDic]) {
                    [mutableArr addObject:adDic];
                }
            }
            if (mutableArr.count > 0) {
                [MutualInsSuspendedAdVC presentInTargetVC:self withAdList:mutableArr];
            }
        }];
    }
}

- (void)setNavigationBar {
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    AddCloseAnimationButton *button = [[AddCloseAnimationButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [button addTarget:self action:@selector(actionShowOrHideMenu:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.menuButton = button;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:container]];
}

- (void)setItemList
{
    self.menuItems = $([self menuPlanButton],
                       [self menuRegistButton],
                       [self menuHelpButton],
                       [self menuPhoneButton]);
}

- (id)menuPlanButton
{
    if (!self.minsStore.rsp_mygroupOp.isShowPlanButton) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"plan",@"title":@"内测计划",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self;
        vc.titleStr = @"自组团介绍";
        vc.groupType = MutualGroupTypeSelf;
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuRegistButton
{
    if (!self.minsStore.rsp_mygroupOp.isShowRegistButton) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"regist",@"title":@"内测登记",@"img":@"mec_edit"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        NSString * urlStr;
#if XMDDEnvironment==0
        urlStr = @"http://dev01.xiaomadada.com/paaweb/general/neice1035/input?token=";
#elif XMDDEnvironment==1
        urlStr = @"http://dev.xiaomadada.com/paaweb/general/neice1035/input?token=";
#else
        urlStr = @"http://www.xiaomadada.com/paaweb/general/neice1035/input?token=";
#endif
        
        vc.url = [urlStr append:gNetworkMgr.token];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuHelpButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"help",@"title":@"使用帮助",@"img":@"mins_question"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0012"}];
        @strongify(self);
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        
        NSString * urlStr;
#if XMDDEnvironment==0
        urlStr = @"http://xiaomadada.com/xmdd-web/xmdd-app/qa.html";
#elif XMDDEnvironment==1
        urlStr = @"http://xiaomadada.com/xmdd-web/xmdd-app/qa.html";
#else
        urlStr = @"http://xiaomadada.com/xmdd-web/xmdd-app/qa.html";
#endif
        
        vc.url = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuPhoneButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"phone",@"title":@"联系客服",@"img":@"mins_phone"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0013"}];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [gPhoneHelper makePhone:@"4007111111"];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
        [alert show];
    });
    return dict;
}

- (void)setupMutualInsStore
{
    self.minsStore = [MutualInsStore fetchOrCreateStore];
    @weakify(self);
    [self.minsStore subscribeWithTarget:self domain:kDomainMutualInsSimpleGroups receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        [self reloadFormSignal:evt.signal];
    }];
}

- (void)resetTableView
{
    if (![self.tableView isRefreshViewExists]) {
        @weakify(self);
        [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
            @strongify(self);
            [[self.minsStore reloadSimpleGroups] send];
        }];
    }
    self.tableView.hidden = NO;
}

#pragma mark - Action
- (void)actionShowOrHideMenu:(id)sender {
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0001"}];
    
    BOOL closing = self.menuButton.closing;
    [self.menuButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        
        NSArray *items = [self.menuItems.allObjects arrayByMappingOperator:^id(CKDict *obj) {
            return [HKPopoverViewItem itemWithTitle:obj[@"title"] imageName:obj[@"img"]];
        }];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 200) items:items];
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
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0002"}];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Reload
- (void)reloadFormSignal:(RACSignal *)signal
{
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else if (![self.view isActivityAnimating]) {
            self.tableView.hidden = YES;
            self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
    }] subscribeNext:^(id x) {

        @strongify(self);
        if (self.minsStore.simpleGroups) {
            self.myGroupArray = [NSMutableArray arrayWithArray:self.minsStore.simpleGroups.allObjects];
        }
        if (self.minsStore.unMutuanlCarList) {
            self.myCarArray = [NSMutableArray arrayWithArray:self.minsStore.unMutuanlCarList.allObjects];
        }
        if ([self reloadIfNeeded]) {
            if ([self.tableView isRefreshViewExists]) {
                [self.tableView.refreshView endRefreshing];
            }
            else {
                [self.view stopActivityAnimation];
                [self resetTableView];
            }
            [self setItemList];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self reloadIfNeeded];
            }];
        }
    }];
}

- (BOOL)reloadIfNeeded
{
    @weakify(self);
    if (!self.config) {
        RACSignal *signal = [[[GetCooperationConfiOp operation] rac_postRequest] doNext:^(id x) {
            @strongify(self);
            self.config = x;
        }];
        [self reloadFormSignal:signal];
        return NO;
    }
    
    if (gAppMgr.myUser && !self.myGroupArray) {
        [[self.minsStore reloadSimpleGroups] send];
        return NO;
    }
    [self setDataSource];
    return YES;
}

- (void)setDataSource
{
    self.datasource = [CKList list];
    
    self.datasource = $($([self setHelpCell], [self setButtonCell], [self setTitleCell], CKJoin([self setMyGroupCell]), CKJoin([self setMyCarCell]), [self setAddCarCell]));
    
    [self.tableView reloadData];
}

- (CKDict *)setHelpCell {
    //初始化身份标识
    CKDict * help = [CKDict dictWith:@{kCKItemKey:@"help", kCKCellID:@"HelpCell"}];
    //cell行高
    help[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 123;
    });
    //cell准备重绘
    @weakify(self);
    help[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *titleLabel = [cell.contentView viewWithTag:1001];
        UILabel *descLabel = [cell.contentView viewWithTag:1002];
        UIButton *feeButton = [cell.contentView viewWithTag:1003];
        
        @strongify(self);
        titleLabel.text = self.config.rsp_selfgroupname;
        descLabel.text = self.config.rsp_selfgroupdesc;
        [feeButton setCornerRadius:3 withBorderColor:kDefTintColor borderWidth:0.5];
        
        [[[feeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0003"}];
            [self helpAction];
        }];
    });
    help[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0004"}];
        [self helpCellSelectAction];
    });
    return help;
}

- (CKDict *)setButtonCell {
    //初始化身份标识
    CKDict * button = [CKDict dictWith:@{kCKItemKey:@"button", kCKCellID:@"BtnCell"}];
    //cell行高
    button[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 70;
    });
    //cell准备重绘
    @weakify(self);
    button[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton *payButton = (UIButton *)[cell.contentView viewWithTag:1001];
        UIButton *joinButton = (UIButton *)[cell.contentView viewWithTag:1002];
        
        [payButton setCornerRadius:5 withBackgroundColor:HEXCOLOR(@"#FF4E70")];
        [joinButton setCornerRadius:5 withBackgroundColor:kDefTintColor];
        
        //我要赔
        [[[payButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0006"}];
            
            if ([LoginViewModel loginIfNeededForTargetViewController:self])
            {
                MutualInsAskForCompensationVC *vc = [UIStoryboard vcWithId:@"MutualInsAskForCompensationVC" inStoryboard:@"MutualInsClaims"];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }];
        //去入团
        [[[joinButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0005"}];
            @strongify(self);
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    });
    return button;
}

- (id)setTitleCell {
    if (self.myGroupArray.count == 0) {
        return CKNULL;
    }
    //初始化身份标识
    CKDict * section = [CKDict dictWith:@{kCKItemKey:@"section", kCKCellID:@"SectionCell"}];
    //cell行高
    section[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 32;
    });
    return section;
}

- (NSMutableArray *)setMyGroupCell {
    NSMutableArray *groupArr = [[NSMutableArray alloc] init];
    for (HKMutualGroup * group in self.myGroupArray) {
        //初始化身份标识
        CKDict * myGroup = [CKDict dictWith:@{kCKItemKey:@"myGroup", kCKCellID:@"MyGroupCell"}];
        //cell行高
        myGroup[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 161;
        });
        //cell准备重绘
        @weakify(self);
        myGroup[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            
            UILabel *nameLabel = [cell.contentView viewWithTag:1001];
            UILabel *carIdLabel = [cell.contentView viewWithTag:1002];
            UILabel *statusLabel = [cell.contentView viewWithTag:1003];
            UILabel *timeLabel = [cell.contentView viewWithTag:1004];
            UIButton *opeBtn = [cell.contentView viewWithTag:1005];
            
            nameLabel.text = group.groupName;
            carIdLabel.text = group.licenseNumber;
            statusLabel.text = group.statusDesc;
            
            if ([group.leftTime integerValue] != 0)
            {
                @strongify(self);
                RACDisposable * disp = [[[HKTimer rac_timeCountDownWithOrigin:[group.leftTime integerValue] / 1000 andTimeTag:group.leftTimeTag] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * timeStr) {
                    
                    @strongify(self);
                    if (![timeStr isEqualToString:@"end"]) {
                        timeLabel.text = [NSString stringWithFormat:@"%@ \n%@", group.tip, timeStr];
                    }
                    else {
                        [disp dispose];
                        [[self.minsStore reloadSimpleGroups] send];
                    }
                }];
                [[self rac_deallocDisposable] addDisposable:disp];
            }
            else if (group.contractperiod.length != 0)
            {
                timeLabel.text = [NSString stringWithFormat:@"%@ \n%@", group.tip, group.contractperiod];
            }
            else {
                timeLabel.text = @"";
            }
            
            opeBtn.hidden = !(group.btnStatus == GroupBtnStatusInvite || group.btnStatus == GroupBtnStatusDelete || group.btnStatus == GroupBtnStatusUpdate);
            
            if (group.btnStatus)
            {
                if (group.btnStatus == GroupBtnStatusInvite) {
                    [opeBtn setTitle:@"邀请好友" forState:UIControlStateNormal];
                    [opeBtn setCornerRadius:3 withBackgroundColor:kDefTintColor];
                }
                else if (group.btnStatus == GroupBtnStatusDelete){
                    [opeBtn setTitle:@"删除" forState:UIControlStateNormal];
                    [opeBtn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#FF4E70")];
                }
                else if (group.btnStatus == GroupBtnStatusUpdate) {
                    [opeBtn setTitle:@"完善资料" forState:UIControlStateNormal];
                    [opeBtn setCornerRadius:3 withBackgroundColor:kDefTintColor];
                }
                [[[opeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                    
                    if (group.btnStatus == GroupBtnStatusInvite) {
                        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0010"}];
                    }
                    else if (group.btnStatus == GroupBtnStatusDelete){
                        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0014"}];
                    }
                    else if (group.btnStatus == GroupBtnStatusUpdate) {
                        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0015"}];
                    }
                    @strongify(self);
                    NSIndexPath * cellPath = [self.tableView indexPathForCell:cell];
                    [self operationBtnAction:x withGroup:group withIndexPath:cellPath];
                }];
            }
        });
        myGroup[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
            @strongify(self);
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0011"}];
            //我的团详情页面
            MutualInsGrouponVC *vc = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
            vc.routeInfo = [CKDict dictWith:@{}];
            vc.group = group;
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
        });
        [groupArr addObject:myGroup];
    }
    
    return groupArr;
}

- (NSMutableArray *)setMyCarCell {
    
    NSMutableArray *carArr = [[NSMutableArray alloc] init];
    for (HKMutualCar * car in self.myCarArray) {
        //初始化身份标识
        CKDict * myCar = [CKDict dictWith:@{kCKItemKey:@"myCar", kCKCellID:@"MyCarCell"}];
        //cell行高
        myCar[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 108;
        });
        //cell准备重绘
        @weakify(self);
        myCar[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            
            UIImageView *brandImageView = [cell.contentView viewWithTag:1001];
            UILabel *licensenumLabel = [cell.contentView viewWithTag:1002];
            UIButton *joinGroup = [cell.contentView viewWithTag:1003];
            UILabel *mutualPrice = [cell.contentView viewWithTag:1004];
            UILabel *couponPrice = [cell.contentView viewWithTag:1005];
            
            [brandImageView setImageByUrl:car.brandLogo withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
            licensenumLabel.text = car.licenseNum;
            [joinGroup setCornerRadius:3 withBorderColor:kDefTintColor borderWidth:0.5];
            [[[joinGroup rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0008"}];
                //团列表
                SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
                vc.originVC = self;
//                vc.originCarId = car.carId;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            mutualPrice.text = [NSString stringWithFormat:@"%@元", car.premiumPrice];
            couponPrice.text = [NSString stringWithFormat:@"%@", car.couponMoney];
        });
        myCar[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
            @strongify(self);
            [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0009"}];
            //团列表
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
//            vc.originCarId = car.carId;
            [self.navigationController pushViewController:vc animated:YES];
            
        });
        [carArr addObject:myCar];
    }
    
    return carArr;
}

- (id)setAddCarCell {
    int groupCount = 0;
    for (HKMutualGroup * group in self.myGroupArray) {
        if ([group.memberId intValue] != 0) {
            groupCount ++;
        }
    }
    if (groupCount + self.myCarArray.count >= 5) {
        return CKNULL;
    }
    //初始化身份标识
    CKDict * addCar = [CKDict dictWith:@{kCKItemKey:@"addCar", kCKCellID:@"AddCarCell"}];
    //cell行高
    addCar[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 108;
    });
    @weakify(self);
    addCar[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0007"}];
        //添加爱车
        @strongify(self);
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
            [vc.model setFinishBlock:^(HKMyCar *car) {
                
                @strongify(self);
                CKEvent *evt = [self.minsStore reloadSimpleGroups];
                [self reloadFormSignal:evt.signal];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    });
    return addCar;
}

#pragma mark - Utilitly
- (void)operationBtnAction:(id)opeBtn withGroup:(HKMutualGroup * )group withIndexPath:(NSIndexPath *)indexPath
{
    if (group.btnStatus == GroupBtnStatusInvite) {
        
        InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
        vc.groupId = group.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (group.btnStatus == GroupBtnStatusDelete){
    
        HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
        alert.topTitle = @"温馨提示";
        alert.imageName = @"mins_bulb";
        alert.message = @"删除后，您将无法看到该团记录。确定现在删除？";
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        @weakify(self);
        HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            
            @strongify(self);
            
            //删除我的团操作 团长和团员调用新接口，入参不同
            DeleteCooperationGroupOp * op = [DeleteCooperationGroupOp operation];
            op.req_memberid = group.memberId;
            op.req_groupid = group.groupId;
            [[[[op rac_postRequest] flattenMap:^RACStream *(id value) {
                @strongify(self);
                return [[self.minsStore reloadSimpleGroups] send];
            }] initially:^{
                [gToast showingWithText:@"删除中..."];
            }] subscribeNext:^(id x) {
                [gToast showText:@"删除成功"];
            } error:^(NSError *error) {
                [gToast showError:error.domain];
            }];
        }];
        alert.actionItems = @[cancel, improve];
        [alert show];
        
    }
    else if (group.btnStatus == GroupBtnStatusUpdate) {
        
        //完善资料
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = group.memberId;
        vc.groupId = group.groupId;
        vc.groupName = group.groupName;
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//费用估算
- (void)helpAction
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.originVC = self;
#if XMDDEnvironment==0
    vc.url = @"http://dev01.xiaomadada.com/xmdd-web/xmdd-app/cost.html";
#elif XMDDEnvironment==1
    vc.url = @"http://dev.xiaomadada.com/xmdd-web/xmdd-app/cost.html";
#else
    vc.url = @"http://www.xiaomadada.com/xmdd-web/xmdd-app/cost.html";
#endif
    [self.navigationController pushViewController:vc animated:YES];
}

//费用估算背后区域点击
- (void)helpCellSelectAction
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.originVC = self;
#if XMDDEnvironment==0
    vc.url = @"http://dev01.xiaomadada.com/xmdd-web/xmdd-app/xmhuzhu.html";
#elif XMDDEnvironment==1
    vc.url = @"http://dev.xiaomadada.com/xmdd-web/xmdd-app/xmhuzhu.html";
#else
    vc.url = @"http://www.xiaomadada.com/xmdd-web/xmdd-app/xmhuzhu.html";
#endif
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        block(data, indexPath);
    }
}
@end
