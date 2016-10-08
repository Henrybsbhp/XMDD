//
//  HKReactNativeViewController.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeViewController.h"
#import "ReactNativeManager.h"
#import "UIView+JTLoadingView.h"
#import "UIView+DefaultEmptyView.h"

@interface ReactNativeViewController ()
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, strong) HKNavigationBar *navigationBar;
@property (nonatomic, strong, readonly) NSDictionary *properties;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation ReactNativeViewController

- (instancetype)initWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:properties];
        [props setObject:moduleName forKey:@"component"];
        [props setObject:@(gAppMgr.myUser ? YES : NO) forKey:@"isLogin"];
        _properties = props;
        _modulName = moduleName;
        self.router.navigationBarHidden = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNavigationBar];
    [self setupRCTView];
    [self checkAndUpdatePackage];
}

- (void)dealloc {
    [self.rctView removeFromSuperview];
    self.rctView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar {
    self.navigationBar = [[HKNavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 67)];
    self.navigationBar.hidden = self.navigationBarHidden;
    self.navigationBar.titleLabel.text = self.properties[@"title"];
    [self.navigationBar.backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigationBar];
}

- (void)setupRCTView {
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    [self.view addSubview:self.containerView];
    
    self.rctView = [[ReactView alloc] initWithFrame:self.view.bounds];
    self.rctView.backgroundColor = [UIColor whiteColor];
    self.rctView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    [self.containerView addSubview:self.rctView];
    
    [self.view bringSubviewToFront:self.navigationBar];
}

#pragma mark - Setter
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated {
    _navigationBarHidden = navigationBarHidden;
    if (navigationBarHidden != self.navigationBar.hidden) {
        [self.navigationBar setHidden:navigationBarHidden animated:animated];
    }
}
#pragma mark - Load
- (void)checkAndUpdatePackage
{
    @weakify(self);
    [[[[ReactNativeManager sharedManager] rac_checkAndUpdatePackageIfNeeded] initially:^{

        @strongify(self);
        [self.containerView hideDefaultEmptyView];
        [self.containerView startActivityAnimationWithType:MONActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.containerView stopActivityAnimation];
        [self loadWithModuleName:@"App" properties:self.properties];
    } error:^(NSError *error) {

        @strongify(self);
        [self.containerView stopActivityAnimation];
        [self.containerView showImageEmptyViewWithImageName:kImageFailConnect text:@"加载失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [self checkAndUpdatePackage];
        }];
        
    } others:^{
        
        @strongify(self);
        [self.containerView stopActivityAnimation];
        [self loadWithModuleName:@"App" properties:self.properties];
    }];
}

- (void)loadWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties
{
#if REACT_DEV == 1
//在线运行
//    NSURL *url = [NSURL URLWithString:@"http://192.168.1.28:8081/index.ios.bundle?platform=ios&dev=true"];
    NSURL *url = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
#else
//本地运行
    NSURL *url = [[ReactNativeManager sharedManager] latestJSBundleUrl];
#endif
    [self.rctView rct_requestWithUrl:url modulName:moduleName properties:properties];
}


@end
