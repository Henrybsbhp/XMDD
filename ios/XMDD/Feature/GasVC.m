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
#import "NSString+RectSize.h"
#import "CBAutoScrollLabel.h"
#import "NSString+Format.h"
#import "GasStore.h"

#import "GasNormalVC.h"
#import "GasRecordVC.h"
#import "PaymentSuccessVC.h"


@interface GasVC ()
@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CBAutoScrollLabel *roundLb;
@property (nonatomic, strong) GasNormalVC *normalVC;
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
    if (IOSVersionGreaterThanOrEqualTo(@"8.1") && !IOSVersionGreaterThanOrEqualTo(@"8.4")) {
        [self.curSubVC refreshViewWithForce:YES];
    }
}

- (void)setupSubVC
{
    self.normalVC = [[GasNormalVC alloc] initWithTargetVC:self tableView:self.tableView
                                             bottomButton:self.bottomBtn bottomView:self.bottomView];
    self.curSubVC = self.normalVC;
    self.tableView.delegate = self.curSubVC;
    self.tableView.dataSource = self.curSubVC;
    CKAsyncMainQueue(^{
        [[[GasStore fetchExistsStore] getAllGasCards] send];
    });
    
    self.tableView.delegate = self.curSubVC;
    self.tableView.dataSource = self.curSubVC;
    [self.curSubVC refreshViewWithForce:YES];
}

- (void)setupHeaderView
{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setupADView
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementGas boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp501_1" mobBaseEventDict:nil];
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        UIView *header = self.headerView;
        if (ads.count == 0 || [self.headerView.subviews containsObject:ctrl.adView]) {
            return;
        }
        CGFloat height = floor(ctrl.adView.frame.size.height);
        CGFloat originHeight = floor(header.frame.size.height);
        header.frame = CGRectMake(0, 0, self.view.frame.size.width, height+originHeight);
        [header addSubview:ctrl.adView];
        [ctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(header);
            make.right.equalTo(header);
            make.top.equalTo(header);
            make.height.mas_equalTo(height);
        }];
        self.tableView.tableHeaderView = header;
    }];
    
    [self requestGasAnnnounce];
}

- (void)setupRoundLbView:(NSString *)note
{
    UIView *headerView = self.headerView;
    if (note.length == 0 || [headerView.subviews containsObject:self.roundLb]) {
        return;
    }
    
    CGFloat originHeight = floor(headerView.frame.size.height);
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 28+originHeight);
    
    _roundLb = [[CBAutoScrollLabel alloc] initWithFrame:CGRectZero];
    _roundLb.textColor = [UIColor whiteColor];
    _roundLb.font = [UIFont systemFontOfSize:12];
    _roundLb.backgroundColor = [UIColor clearColor];
    _roundLb.labelSpacing = 30;
    _roundLb.scrollSpeed = 30;
    _roundLb.fadeLength = 5.f;
    _roundLb.textColor = kGrayTextColor;
    _roundLb.text = [self appendSpace:note andWidth:ScreenWidth];
    [headerView addSubview:_roundLb];
    [_roundLb observeApplicationNotifications];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    imageView.image = [UIImage imageNamed:@"gas_notify_300"];
    imageView.contentMode=UIViewContentModeCenter;
    imageView.backgroundColor=[UIColor whiteColor];
    [headerView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView);
        make.bottom.equalTo(headerView);
        make.height.width.mas_equalTo(28);
    }];
    
    [self.roundLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right);
        make.right.equalTo(headerView);
        make.bottom.equalTo(headerView);
        make.height.mas_equalTo(28);
    }];
    
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setupBottomView
{
    UIImage *bg1 = [[UIImage imageNamed:@"btn_bg_orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage *bg2 = [[UIImage imageNamed:@"btn_bg_orange_disable"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
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

- (IBAction)actionStartPay:(id)sender
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

#pragma mark - Utility
- (NSString *)appendSpace:(NSString *)note andWidth:(CGFloat)w
{
    NSString * spaceNote = note;
    for (NSInteger i = 0;i< 1000;i++)
    {
        CGSize size = [spaceNote labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:13]];
        if (size.width > w)
            return spaceNote;
        spaceNote = [spaceNote append:@" "];
    }
    return spaceNote;
}


@end
