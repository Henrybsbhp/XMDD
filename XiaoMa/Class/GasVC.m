//
//  GasVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasVC.h"
#import "HorizontalScrollTabView.h"
#import "ADViewController.h"
#import "UIView+DefaultEmptyView.h"
#import "HKTableViewCell.h"
#import "UIView+JTLoadingView.h"
#import "NSString+RectSize.h"
#import "NSString+Split.h"
#import "CBAutoScrollLabel.h"
#import "NSString+Format.h"
#import "GasStore.h"

#import "GasPickAmountCell.h"
#import "GasReminderCell.h"

#import "GasNormalVC.h"
#import "GasCZBVC.h"
#import "MyBankVC.h"
#import "GasCardListVC.h"
#import "GasAddCardVC.h"
#import "GasPayForCZBVC.h"
#import "GasRecordVC.h"
#import "GasPaymentResultVC.h"
#import "PayForGasViewController.h"
#import "PaymentSuccessVC.h"


@interface GasVC ()
@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) HorizontalScrollTabView *tabView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) CBAutoScrollLabel *roundLb;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIImageView *notifyImg;
@property (nonatomic, strong) GasNormalVC *normalVC;
@property (nonatomic, strong) GasCZBVC *czbVC;
@property (nonatomic, strong) GasSubVC *curSubVC;

@end

@implementation GasVC

- (void)dealloc
{
    DebugLog(@"GasVC Dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsZero;
    [self setupHeaderView];
    [self setupADView];
    [self setupBottomView];
    [self setupSubVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.roundLb refreshLabels];
    //IOS 8.1.3下面有RTLabel消失的bug，需要重新刷一下页面
    if (IOSVersionGreaterThanOrEqualTo(@"8.1.3") && !IOSVersionGreaterThanOrEqualTo(@"8.4")) {
        [self.curSubVC refreshViewWithForce:YES];
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)setupSubVC
{
    self.normalVC = [[GasNormalVC alloc] initWithTargetVC:self tableView:self.tableView
                                             bottomButton:self.bottomBtn bottomView:self.bottomView];
    self.czbVC = [[GasCZBVC alloc] initWithTargetVC:self tableView:self.tableView
                                       bottomButton:self.bottomBtn bottomView:self.bottomView];
    
    self.curSubVC = self.tabViewSelectedIndex == 0 ? self.normalVC : self.czbVC;
    self.tableView.delegate = self.curSubVC;
    self.tableView.dataSource = self.curSubVC;
    CKAsyncMainQueue(^{
        [self.curSubVC reloadData];
    });
}

- (void)setupHeaderView
{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.tabView = [[HorizontalScrollTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tabView.scrollTipBarColor = kDefTintColor;
    HorizontalScrollTabItem *item1 = [HorizontalScrollTabItem itemWithTitle:@"普通充值" normalColor:kBlackTextColor
                                                              selectedColor:kDefTintColor];
    HorizontalScrollTabItem *item2 = [HorizontalScrollTabItem itemWithTitle:@"浙商卡充值" normalColor:kBlackTextColor
                                                              selectedColor:kDefTintColor];
    self.tabView.items = @[item1, item2];
    [self.headerView addSubview:self.tabView];

    @weakify(self);
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.headerView);
        make.right.equalTo(self.headerView);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.headerView);
    }];

    [self.tabView setTabBlock:^(NSInteger index) {
        @strongify(self);
        if (index ==0) {
            [MobClick event:@"rp501_2"];
            self.curSubVC = self.normalVC;
        }
        else {
            [MobClick event:@"rp501_3"];
            self.curSubVC = self.czbVC;
        }
        self.tableView.delegate = self.curSubVC;
        self.tableView.dataSource = self.curSubVC;
        [self.curSubVC refreshViewWithForce:YES];
    }];
    
    [self.tabView reloadDataWithBoundsSize:CGSizeMake(ScreenWidth, 44) andSelectedIndex:self.tabViewSelectedIndex];
    
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setupADView
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementGas boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp501_1"];
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        if (ads.count > 0) {
            UIView *headerView = self.headerView;
            if ([headerView.subviews containsObject:self.adctrl.adView])
            {
                return;
            }
            CGFloat height = floor(self.adctrl.adView.frame.size.height);
            CGFloat originHeight = floor(headerView.frame.size.height);
            headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, height+originHeight);
            [headerView addSubview:self.adctrl.adView];
            [self.adctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(headerView);
                make.right.equalTo(headerView);
                make.top.equalTo(headerView);
                make.height.mas_equalTo(height);
            }];
            self.tableView.tableHeaderView = self.headerView;
        }
    }];
    
    [self requestGasAnnnounce];
}

- (void)setupRoundLbView:(NSString *)note
{
    if (note.length)
    {
        UIView *headerView = self.headerView;
        
        if ([headerView.subviews containsObject:self.backgroundView])
        {
            return;
        }
        
        CGFloat originHeight = floor(headerView.frame.size.height);
        headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 28+originHeight);
        
        CGFloat width = self.view.frame.size.width;
        NSString * p = [self appendSpace:note andWidth:width];
        self.roundLb.text = p;
        self.roundLb.textColor=[UIColor grayColor];
        UIView *upLine = [UIView new];
        upLine.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.7];
        UIView *downLine = [UIView new];
        downLine.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.7];
        
        
        [self.backgroundView addSubview:self.roundLb];
        [self.backgroundView addSubview:self.notifyImg];
        [self.backgroundView addSubview:upLine];
        [self.backgroundView addSubview:downLine];
        
        [headerView addSubview:self.backgroundView];
        
        [upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_top);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_bottom);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        [self.roundLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(28);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(upLine.mas_bottom);
            make.height.mas_equalTo(28);
        }];
        [self.notifyImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(upLine.mas_bottom);
            make.height.width.mas_equalTo(28);
        }];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headerView.mas_left);
            make.right.mas_equalTo(headerView.mas_right);
            make.bottom.mas_equalTo(headerView.mas_bottom).offset(-44);
            make.height.mas_equalTo(28);
        }];
        
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)setupBottomView
{
    UIImage *bg1 = [[UIImage imageNamed:@"gas_btn_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage *bg2 = [[UIImage imageNamed:@"gas_btn_bg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.bottomBtn setBackgroundImage:bg1 forState:UIControlStateNormal];
    [self.bottomBtn setBackgroundImage:bg2 forState:UIControlStateDisabled];
    self.bottomBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bottomBtn.titleLabel.minimumScaleFactor = 0.7;
}

#pragma mark - request
- (void)requestGasAnnnounce
{
    GetGaschargeConfigOp * op = [GetGaschargeConfigOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetGaschargeConfigOp * op) {
        
        [self setupRoundLbView:op.rsp_tip];
    }];
}

#pragma mark - Action
- (IBAction)actionGotoRechargeRecords:(id)sender
{
    [MobClick event:@"rp501_16"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasRecordVC *vc = [UIStoryboard vcWithId:@"GasRecordVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)actionPay:(id)sender
{
    [self.curSubVC actionPay];
}

- (IBAction)actionAgreement:(id)sender
{
    [MobClick event:@"rp501_12"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"油卡充值服务协议";
    vc.url = kGasLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionBack:(id)sender
{
    NSArray * viewcontrollers = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontrollers safetyObjectAtIndex:viewcontrollers.count - 2];
    if ([vc isKindOfClass:[PaymentSuccessVC class]])
    {
        [self.tabBarController setSelectedIndex:0];
        UIViewController * firstTabVC = [self.tabBarController.viewControllers safetyObjectAtIndex:0];
        [self.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:firstTabVC];
        
        [self.navigationController popToRootViewControllerAnimated:YES];

        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Other
- (void)setTabViewSelectedIndex:(NSInteger)tabViewSelectedIndex
{
    _tabViewSelectedIndex = tabViewSelectedIndex;
    [self.tabView setSelectedIndex:tabViewSelectedIndex animated:NO];
}

-(UIImageView *)notifyImg
{
    if (!_notifyImg)
    {
        _notifyImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
        _notifyImg.image = [UIImage imageNamed:@"gas_notify"];
        _notifyImg.contentMode=UIViewContentModeCenter;
        _notifyImg.backgroundColor=[UIColor whiteColor];
    }
    return _notifyImg;
}

-(UIView *)backgroundView
{
    if (!_backgroundView)
    {
        _backgroundView=[[UIView alloc]init];
        _backgroundView.backgroundColor=[UIColor whiteColor];
    }
    return _backgroundView;
}

- (NSString *)appendSpace:(NSString *)note andWidth:(CGFloat)w
{
    NSString * spaceNote = note;
    while (1) {
        CGSize size = [spaceNote sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];
        if (size.width > w)
            return spaceNote;
        spaceNote = [spaceNote append:@" "];
    }
}


@end
