//
//  InsLicensePopVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InsLicensePopVC.h"
#import <MZFormSheetController.h>
#import "CKLine.h"
#import "WebVC.h"

@interface InsLicensePopVC ()
@property (nonatomic, strong) WebVC *webvc;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSString *licenseUrl;
@end

@implementation InsLicensePopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavigationBar];
    [self setupBottomView];
    [self setupWebVC];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar
{
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ins_close"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
    closeItem.tintColor = [UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItem = closeItem;
}

- (void)setupBottomView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:view];
    self.bottomView = view;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"确认以上信息" forState:UIControlStateNormal];
    [button setTitleColor:HEXCOLOR(@"#20ab2a") forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:self action:@selector(actionAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    CKLine *line = [[CKLine alloc] initWithFrame:CGRectZero];
    line.lineAlignment = CKLineAlignmentHorizontalTop;
    [view addSubview:line];
    
    @weakify(self);
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(50);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.equalTo(view);
        make.top.equalTo(view);
        make.right.equalTo(view);
    }];
}

- (void)setupWebVC
{
    self.webvc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
    self.webvc.url = self.licenseUrl;
    self.webvc.autoShowBackButton = YES;
    [self addChildViewController:self.webvc];
    [self.view addSubview:self.webvc.view];
    @weakify(self);
    [self.webvc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}


#pragma mark - Action
- (void)actionDismiss:(id)sender
{
}

- (void)actionAgreement:(id)sender
{
}


+ (RACSignal *)rac_showInView:(UIView *)view withLicenseUrl:(NSString *)url title:(NSString *)title
{
    CGSize size = CGSizeMake(view.frame.size.width-30, view.frame.size.height-80);
    InsLicensePopVC *vc = [[InsLicensePopVC alloc] init];
    vc.title = title;
    vc.licenseUrl = url;
    JTNavigationController *nvc = [[JTNavigationController alloc] initWithRootViewController:vc];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:nvc];
    sheet.cornerRadius = 2.5;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    sheet.shouldCenterVertically = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    [MZFormSheetController sharedBackgroundWindow].backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [sheet presentAnimated:YES completionHandler:nil];

    RACSubject *subject = [RACSubject subject];
    [[[vc rac_signalForSelector:@selector(actionDismiss:)] take:1] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
        [subject sendCompleted];
    }];
    
    [[[vc rac_signalForSelector:@selector(actionAgreement:)] take:1] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
        [subject sendNext:@YES];
        [subject sendCompleted];
    }];
    return subject;
}

@end
