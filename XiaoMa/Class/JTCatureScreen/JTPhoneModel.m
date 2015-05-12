//
//  JTPhoneModel.m
//  Owner
//
//  Created by apple on 14-7-23.
//  Copyright (c) 2014年 tonpe. All rights reserved.
//

#import "JTPhoneModel.h"

@interface JTPhoneModel()
@property (nonatomic, strong) UIWebView *callWebView;
@end


@implementation JTPhoneModel

- (UIWebView *)makeCall:(NSString *)phoneNumber
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]];
    DebugLog(@"%@",phoneURL);
    if (!self.callWebView)
    {
        self.callWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:phoneURL];
    [self.callWebView loadRequest:request];
    return self.callWebView;
}

+ (void)makeCall:(NSString *)phoneNumber forTargetView:(UIView *)view
{
    UIWebView *callView = [[view subviews] firstObjectByFilteringOperator:^BOOL(id obj) {
        
        return [obj isKindOfClass:[UIWebView class]];
    }];
    if (!callView)
    {
        callView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [view addSubview:callView];
    }
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]];
    NSURLRequest *request = [NSURLRequest requestWithURL:phoneURL];
    [callView loadRequest:request];
}
@end