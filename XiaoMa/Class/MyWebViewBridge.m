//
//  MyWebViewBridge.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/22.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "MyWebViewBridge.h"
#import "SocialShareViewController.h"

typedef NS_ENUM(NSInteger, MenuItemsType) {
    menuItemsTypeShare                  = 0,
    menuItemsTypeCollection             = 1
};

@implementation MyWebViewBridge

- (instancetype)initBridgeWithWebView:(WVJB_WEBVIEW_TYPE *)webView andDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *) delegate
{
    self = [super init];
    if (self)
    {
        self.myBridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:delegate handler:^(id data, WVJBResponseCallback responseCallback) {
            //注册bridge，并用于接收所有JS的send方法
            //        NSLog(@"ObjC received message from JS: %@", data);
            //        responseCallback(@"Response for message from ObjC");
        }];
    }
    return self;

}

- (void)setUserTokenHandler
{
    id data;
    if (gNetworkMgr.token) {
        data = @{ @"token" : gNetworkMgr.token};
    }
    else {
        data = nil;
    }
    [self.myBridge callHandler:@"setUserTokenHandler" data:data responseCallback:^(id response) {
        DebugLog(@"setUserTokenHandler responded: %@", response);
    }];
}

- (UIBarButtonItem *)setSingleMenu:(NSDictionary *)singleDic
{
    MenuItemsType type = [singleDic integerParamForName:singleDic[@"type"]];
    UIBarButtonItem *right;
    if (type == menuItemsTypeShare) {
        right = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    }
    else {
        
    }
    [right setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
    return right;
}

- (void)shareAction
{
    [self.myBridge callHandler:@"getShareParamHandler" data:nil responseCallback:^(id response) {
        DebugLog(@"share response%@", response);
        NSDictionary *shareDic = response;
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.tt = [shareDic stringParamForName:@"title"];
        vc.subtitle = [shareDic stringParamForName:@"desc"];
        
        //可能可直接传url
        [[gMediaMgr rac_getImageByUrl:shareDic[@"imgUrl"] withType:ImageURLTypeMedium defaultPic:nil errorPic:nil] subscribeNext:^(id x) {
            vc.image = x;
            vc.webimage = x;
        }];
        vc.urlStr = shareDic[@"linkUrl"];
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [vc setFinishAction:^{
            
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110-7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
    }];
}

@end
