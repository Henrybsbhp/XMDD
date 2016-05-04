//
//  ReactTestViewController.m
//  XiaoMa
//
//  Created by jt on 16/2/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactTestViewController.h"
#import "ReactView.h"

@interface ReactTestViewController()

@property (weak, nonatomic) IBOutlet ReactView *rctView;

@end

@implementation ReactTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavi];
    
    
    CKAsyncMainQueue(^{
        
        NSString * str = @"http://192.168.1.77:8081/index.ios.bundle?platform=ios&dev=true";
        NSURL * strUrl = [NSURL URLWithString:str];
        NSBundle * bundle = [NSBundle mainBundle];
        NSString * urlString = [bundle pathForResource:@"main" ofType:@"jsbundle"];
        
        NSURL * jsURL = [NSURL fileURLWithPath:urlString];
        [self.rctView rct_requestWithUrl:strUrl andModulName:_modulName];
        
    });
}

- (void)setupNavi
{
    self.navigationItem.title = @"React Native";
}



@end
