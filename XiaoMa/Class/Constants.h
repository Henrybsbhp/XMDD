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

/**
 支付平台
 */
typedef enum : NSUInteger {
    PayWithAlipay,
    PayWithWechat,
    PayWithXMDDCreditCard,
    PayWithUPPay
} PaymentPlatform;

/// 支付渠道 0不要用（0表示没有选择支付渠道）
typedef enum : NSUInteger {
    PaymentChannelInstallments = 1,
    PaymentChannelAlipay,
    PaymentChannelWechat,
    PaymentChannelABCCarWashAmount,
    PaymentChannelABCIntegral,
    PaymentChannelCoupon,
    PaymentChannelXMDDCreditCard,
    PaymentChannelUPpay
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
    AdvertisementInsurance = 11,
    AdvertisementTypeActivities = 20,
    AdvertisementTypeLaunch = 30
} AdvertisementType;

#define IOSAPPID 1001
#define BaiduMapUrl @"baidumap://map/"
#define AMapUrl  @"iosamap://"
#define XIAMMAWEB @"http://www.xiaomadada.com"

#define kDefTintColor   HEXCOLOR(@"#15ac1f")
#define kDefLineColor   HEXCOLOR(@"#ebebeb")
#define kDarkLineColor   HEXCOLOR(@"#e0e0e0")

#define kKeyChainBaseServer     @"com.huika.xmdd"

//字符串定义
#define kRspPrefix      @"█ ▇ ▆ ▅ ▄ ▃ ▂"
#define kReqPrefix      @"▂ ▃ ▄ ▅ ▆ ▇ █"
#define kErrPrefix      @"〓〓〓〓〓"
#define kDefErrorPormpt      @"网络不给力，请重试"

// 如果是2D的话，可以设置为2.1，3.1，大于整数级，因为整数级别中只是缩放当前级别的图，不会去渲染更高等级的图。
#define MapZoomLevel 15.1000
#define PageAmount 10
#define kVCodePromptInteval     15
#define kLaunchBottomViewHeight     102

#define AppleNavigationStr @"苹果地图"
#define BaiduNavigationStr @"百度地图"
#define AMapNavigationStr @"高德地图"

//单例别名
#define gAppDelegate       ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define gAppMgr     [AppManager sharedManager]
#define gNetworkMgr [NetworkManager sharedManager]
#define gToast      [HKToast sharedTosast]
#define gMapHelper ([MapHelper sharedHelper])
#define gMediaMgr  ([[AppManager sharedManager] mediaMgr])
#define gPhoneHelper  ([PhoneHelper sharedHelper])
#define gAdMgr [AdvertisementManager sharedManager]

#define mainStoryboard [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define carWashStoryboard [UIStoryboard storyboardWithName:@"Carwash" bundle:nil]
#define commonStoryboard [UIStoryboard storyboardWithName:@"Common" bundle:nil]
#define otherStoryboard [UIStoryboard storyboardWithName:@"Other" bundle:nil]
#define mineStoryboard [UIStoryboard storyboardWithName:@"Mine" bundle:nil]
#define rescueStoryboard [UIStoryboard storyboardWithName:@"Rescue" bundle:nil]
#define commissionStoryboard [UIStoryboard storyboardWithName:@"Commission" bundle:nil]
#define awardStoryboard [UIStoryboard storyboardWithName:@"Award" bundle:nil]
#define insuranceStoryboard [UIStoryboard storyboardWithName:@"Insurance" bundle:nil]

#define LocationFail 7001
#define WechatPayFail 7002

//通知定义
#define kNotifyRefreshMyCarList             @"com.huika.xmdd.RefreshMyCarList"
#define kNotifyRefreshMyCarwashOrders       @"com.huika.xmdd.RefreshMyCarwashOrders"
#define kNotifyRefreshMyBankcardList        @"com.huika.xmdd.RefreshMyBankcardList"
#define kNotifyRefreshMyCouponList          @"com.huika.xmdd.RefreshMyCouponList"



#endif
