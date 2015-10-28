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

#pragma mark - 传递用户token
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

#pragma mark - 获取地理位置信息
- (void)registerSetPosition
{
    [self.myBridge registerHandler:@"getCurrentPosition" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * longitudeStr = [NSString stringWithFormat:@"%f", gMapHelper.coordinate.longitude];
        NSString * latitudeStr = [NSString stringWithFormat:@"%f", gMapHelper.coordinate.latitude];
        NSString * province = gAppMgr.addrComponent.province;
        NSString * city = gAppMgr.addrComponent.city;
        NSString * district = gAppMgr.addrComponent.district;
        if (longitudeStr && longitudeStr && latitudeStr) {
            NSDictionary * dic = @{@"province":province, @"city":city, @"district":district, @"longitude":longitudeStr, @"latitude":latitudeStr};
            responseCallback(dic);
        }
    }];
}

#pragma mark - 点击查看大图
- (void)registerShowImage
{
    [self.myBridge registerHandler:@"callShowImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary * dic = data;
        NSString * imageUrl = [dic stringParamForName:@"imgUrl"];
        [self showImages:imageUrl];
    }];
}

- (void)showImages:(NSString *)urlStr
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIScrollView * backgroundView= [[UIScrollView alloc]
                                    initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    backgroundView.showsHorizontalScrollIndicator = NO;
    backgroundView.backgroundColor = [UIColor colorWithHex:@"#0000000" alpha:0.6f];
    backgroundView.alpha = 0;
    [backgroundView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    [[gMediaMgr rac_getImageByUrl:urlStr withType:ImageURLTypeOrigin defaultPic:@"cm_webimg_default" errorPic:@"cm_webimg_default"] subscribeNext:^(id x) {
        UIImage * img = x;
        CGRect frame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height-img.size.height*[UIScreen mainScreen].bounds.size.width/img.size.width)/2, [UIScreen mainScreen].bounds.size.width, img.size.height*[UIScreen mainScreen].bounds.size.width/img.size.width);
        imageView.frame = frame;
        [imageView setImage:img];
    } error:^(NSError *error) {
        [gToast showError:@"大图加载失败，请稍后重试"];
        [imageView setImage:[UIImage imageNamed:@"cm_webimg_default"]]; //默认错误大图
    }];
    
    [backgroundView addSubview:imageView];
    
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

#pragma mark - 右上角菜单按钮（目前只有分享）
- (UIBarButtonItem *)setSingleMenu:(NSDictionary *)singleDic
{
    MenuItemsType type = [singleDic integerParamForName:singleDic[@"type"]];
    UIBarButtonItem *right;
    if (type == menuItemsTypeShare) {
        right = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    }
    else {
        //其他单个右上角功能按钮
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
