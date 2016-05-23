//
//  ReactTestViewController.m
//  XiaoMa
//
//  Created by jt on 16/2/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactTestViewController.h"
#import "ReactView.h"
#import "ReactNativeManager.h"

@interface ReactTestViewController()

@property (weak, nonatomic) IBOutlet ReactView *rctView;

@end

@implementation ReactTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavi];
    [self checkAndUpdatePackage];
}


- (void)setupNavi
{
    self.navigationItem.title = @"React Native";
}

- (void)checkAndUpdatePackage
{
    @weakify(self);
    [[[[ReactNativeManager sharedManager] rac_checkAndUpdatePackageIfNeeded] initially:^{
        
        [gToast showingWithText:@"Loading"];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast showSuccess:@"更新成功"];
        [self loadWithModuleName:self.modulName];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    } others:^{
        
        @strongify(self);
        [gToast dismiss];
        [self loadWithModuleName:self.modulName];
    }];
}

- (void)loadWithModuleName:(NSString *)moduleName
{
#if !DEBUG
    CKAsyncMainQueue(^{
        NSURL *url = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
        [self.rctView rct_requestWithUrl:url andModulName:moduleName];
    });
#else
    [self.rctView rct_requestWithUrl:[[ReactNativeManager sharedManager] latestJSBundleUrl] andModulName:moduleName];
#endif
    
}


@end
