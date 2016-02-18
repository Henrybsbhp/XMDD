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
        
        NSString * strUrl = @"http://localhost:8081/index.ios.bundle?platform=ios&dev=true";
        [self.rctView rct_requestWithUrlStr:strUrl];
    });
    
    
}

- (void)setupNavi
{
    self.navigationItem.title = @"React Native";
}



@end
