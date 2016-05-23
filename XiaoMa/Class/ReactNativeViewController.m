//
//  HKReactNativeViewController.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeViewController.h"
#import "ReactNativeManager.h"

@interface ReactNativeViewController ()
@property (nonatomic, strong, readonly) NSDictionary *properties;
@end

@implementation ReactNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.properties[@"title"];
    [self setupRCTView];
    [self checkAndUpdatePackage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.rctView removeFromSuperview];
    self.rctView = nil;
}

- (void)setupRCTView {
    self.rctView = [[ReactView alloc] initWithFrame:self.view.bounds];
    self.rctView.backgroundColor = [UIColor whiteColor];
    self.rctView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.rctView];
}

- (instancetype)initWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        _modulName = moduleName;
        _properties = properties;
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)checkAndUpdatePackage
{
    @weakify(self);
    [[[[ReactNativeManager sharedManager] rac_checkAndUpdatePackageIfNeeded] initially:^{
        
        [gToast showingWithText:@"Loading"];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast showSuccess:@"更新成功"];
        [self loadWithModuleName:self.modulName properties:self.properties];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    } others:^{
        
        @strongify(self);
        [gToast dismiss];
        [self loadWithModuleName:self.modulName properties:self.properties];
    }];
}

- (void)loadWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties
{
#if DEBUG
//    [self.rctView rct_requestWithUrl:[[ReactNativeManager sharedManager] latestJSBundleUrl] andModulName:moduleName];
    CKAsyncMainQueue(^{
        NSURL *url = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
        [self.rctView rct_requestWithUrl:url modulName:moduleName properties:properties];
    });
#else
    [self.rctView rct_requestWithUrl:[[ReactNativeManager sharedManager] latestJSBundleUrl] andModulName:moduleName];
#endif
    
}


@end
