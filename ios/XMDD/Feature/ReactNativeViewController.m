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
@property (nonatomic, strong, readonly) NSDictionary *properties;
@end

@implementation ReactNativeViewController

- (instancetype)initWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:properties];
        [props setObject:moduleName forKey:@"component"];
        _properties = props;
        _modulName = moduleName;

        self.router.navigationBarHidden = YES;
        self.router.disableInteractivePopGestureRecognizer = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
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

- (void)checkAndUpdatePackage
{
    @weakify(self);
    [[[[ReactNativeManager sharedManager] rac_checkAndUpdatePackageIfNeeded] initially:^{

        @strongify(self);
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self loadWithModuleName:@"App" properties:self.properties];
        [self.view stopActivityAnimation];
    } error:^(NSError *error) {

        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:kImageFailConnect text:@"加载失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [self checkAndUpdatePackage];
        }];
        
    } others:^{
        
        @strongify(self);
        [self loadWithModuleName:@"App" properties:self.properties];
        [self.view stopActivityAnimation];
    }];
}

- (void)loadWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties
{
#if REACT_DEV == 1
//在线运行
    NSURL *url = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=false"];
#else
//本地运行
    NSURL *url = [[ReactNativeManager sharedManager] latestJSBundleUrl];
#endif
    [self.rctView rct_requestWithUrl:url modulName:moduleName properties:properties];
}


@end
