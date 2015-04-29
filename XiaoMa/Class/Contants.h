//
//  Contants.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#ifndef XiaoMa_Contants_h
#define XiaoMa_Contants_h

/// 服务类型
typedef enum : NSUInteger {
    ShopServiceCarWash = 1,
    ShopServiceRescue,
    ShopServiceAgency,
} ShopServiceType;

/// 支付渠道
typedef enum : NSUInteger {
    PaymentChannelInstallments = 1,
    PaymentChannelAlipay,
    PaymentChannelWechat,
    PaymentChannelABCCarWashAmount,
    PaymentChannelABCIntegral,
    PaymentChannelCoupon
} PaymentChannelType;

/// 支付渠道
//1-首页广告
//2-洗车广告
//3-银行卡绑定页广告
//10-APP滑动广告
//20：活动类
typedef enum : NSUInteger {
    AdvertisementHomePage = 1,
    AdvertisementCarWash = 2,
    AdvertisementBankCardBinding = 3,
    AdvertisementAppSlide = 10,
    AdvertisementTypeActivities = 20
} AdvertisementType;

#define IOSAPPID 2001
#define BaiduMapUrl @"baidumap://map/"
#define AMapUrl  @"iosamap://"

#define kDefTintColor   HEXCOLOR(@"#15ac1f")
#define kDefLineColor   HEXCOLOR(@"#e0e0e0")

//字符串定义
#define kRspPrefix      @"█ ▇ ▆ ▅ ▄ ▃ ▂"
#define kReqPrefix      @"▂ ▃ ▄ ▅ ▆ ▇ █"
#define kErrPrefix      @"〓〓〓〓〓"

#define MapZoomLevel 12.0000

#define AppleNavigationStr @"苹果导航"
#define BaiduNavigationStr @"百度导航"
#define AMapNavigationStr @"高德导航"

//单例别名
#define gAppDelegate       ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define gAppMgr     [AppManager sharedManager]
#define gNetworkMgr [NetworkManager sharedManager]
#define gToast      [HKToast sharedTosast]
#define gAlipayHelper       ([AlipayHelper sharedHelper])
#define gWechatHelper       ([WeChatHelper sharedHelper])
#define gMapHelper ([MapHelper sharedHelper])
#define gMediaMgr  ([MultiMediaManager sharedManager])

#define mainStoryboard [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define carWashStoryboard [UIStoryboard storyboardWithName:@"Carwash" bundle:nil]
#define commonStoryboard [UIStoryboard storyboardWithName:@"Common" bundle:nil]
#define otherStoryboard [UIStoryboard storyboardWithName:@"Other" bundle:nil]


#define LocationFail 7001
#define WechatPayFail 7002


#endif
