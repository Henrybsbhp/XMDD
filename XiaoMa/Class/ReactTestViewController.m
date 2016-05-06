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
    
    [[[[ReactNativeManager sharedManager] rac_checkAndUpdatePackageIfNeeded] initially:^{
        
        [gToast showingWithText:@"Loading"];
    }] subscribeNext:^(id x) {
        
        [gToast showSuccess:@"更新成功"];
        [self.rctView rct_requestWithUrl:[[ReactNativeManager sharedManager] latestJSBundleUrl] andModulName:@"HelloProject"];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    } others:^{
        
        [gToast dismiss];
        [self.rctView rct_requestWithUrl:[[ReactNativeManager sharedManager] latestJSBundleUrl] andModulName:@"HelloProject"];
    }];
//    CKAsyncMainQueue(^{
//        
//        NSString * str = @"http://localhost:8081/index.ios.bundle?platform=ios&dev=true";
//        NSURL * strUrl = [NSURL URLWithString:str];
//        [self.rctView rct_requestWithUrl:strUrl andModulName:@"HelloProject"];
//        
//    });
}

- (void)setupNavi
{
    self.navigationItem.title = @"React Native";
}



@end
