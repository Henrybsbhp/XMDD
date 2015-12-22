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
    /// 精洗，用心洗
    ShopServiceCarwashWithHeart
} ShopServiceType;

/**
 支付平台
 */

/// 支付渠道 0不要用（0表示没有选择支付渠道）
typedef enum : NSUInteger {
    PaymentChannelInstallments = 1,
    PaymentChannelAlipay,
    PaymentChannelWechat,
    PaymentChannelABCCarWashAmount,
    PaymentChannelABCIntegral,
    PaymentChannelCoupon,
    PaymentChannelCZBCreditCard,
    PaymentChannelUPpay
} PaymentChannelType;

/// 支付渠道
//1-首页广告
//2-洗车广告
//3-银行卡绑定页广告
//6-拖车广告
//7-泵电广告
//8-换胎广告
//4-加油广告
//10-APP滑动广告
//11-保险广告
//12-估值广告
//20：活动类
typedef enum : NSUInteger {
    AdvertisementHomePage = 1,
    AdvertisementCarWash = 2,
    AdvertisementBankCardBinding = 3,
    AdvertisementGas = 4,
    AdvertisementTrailer = 6,
    AdvertisementTrailerPumpPower = 7,
    AdvertisementTrailerPumpPowerChangeTheTire = 8,
    AdvertisementAppSlide = 10,
    AdvertisementInsurance = 11,
    AdvertisementValuation = 12,
    AdvertisementTypeActivities = 20,
    AdvertisementTypeLeaunch = 30
} AdvertisementType;

///分享页面类型
//2-洗车完成分享
//3-每周礼券红包分享
//4-保险支付完成分享
//5-油卡充值完成分享
//6-优惠券分享（转赠）
//7-其他分享（jsbridge中的分享和App分享）
typedef enum : NSUInteger {
    ShareSceneCarwash = 2,
    ShareSceneGain = 3,
    ShareSceneInsurance = 4,
    ShareSceneGas = 5,
    ShareSceneCoupon = 6,
    ShareSceneValuation = 7,
    ShareSceneLocalShare
} ShareSceneType;

///分享按钮类型
//1-微信好友
//2-微信朋友圈
//3-微博
//4-QQ好友
//5-QQ空间
typedef enum : NSUInteger {
    ShareButtonWechat = 1,
    ShareButtonTimeLine = 2,
    ShareButtonWeibo = 3,
    ShareButtonQQFriend = 4,
    ShareButtonQQZone = 5
} ShareButtonType;

#define IOSAPPID 1001
#define BaiduMapUrl @"baidumap://map/"
#define AMapUrl  @"iosamap://"
#define XIAMMAWEB @"http://www.xiaomadada.com"
#define ADDEFINEWEB @"http://www.xiaomadada.com/apphtml/couponpkg.html?jump=t"

#define kDefTintColor   HEXCOLOR(@"#15ac1f")
#define kDefLineColor   HEXCOLOR(@"#ebebeb")
#define kDarkLineColor  HEXCOLOR(@"#e0e0e0")

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
#define violationStoryboard [UIStoryboard storyboardWithName:@"Violation" bundle:nil]
#define valuationStoryboard [UIStoryboard storyboardWithName:@"Valuation" bundle:nil]
#define gasStoryboard [UIStoryboard storyboardWithName:@"Gas" bundle:nil]

#define LocationFail 7001
#define WechatPayFail 7002

//通知定义
#define kNotifyRefreshMyCarList             @"com.huika.xmdd.RefreshMyCarList"
#define kNotifyRefreshMyCarwashOrders       @"com.huika.xmdd.RefreshMyCarwashOrders"
#define kNotifyRefreshMyBankcardList        @"com.huika.xmdd.RefreshMyBankcardList"
#define kNotifyRefreshMyCouponList          @"com.huika.xmdd.RefreshMyCouponList"



/// 相关网页地址
#define kInsuranceOlineUrl  @"https://www.xiaomadada.com/apphtml/aichebao.html"
#define kServiceLicenseUrl @"https://www.xiaomadada.com/apphtml/license.html"
#define kServiceHelpUrl     @"https://www.xiaomadada.com/apphtml/shiyongbangzhu.html"
#define kAppShareUrl        @"https://www.xiaomadada.com/apphtml/share001.html"
#define kCZBankLicenseUrl  @"https://www.xiaomadada.com/apphtml/license-czb.html"
#define kMeizhouliquanUrl    @"https://www.xiaomadada.com/apphtml/meizhouliquan.html"
#define kGetMoreCouponUrl     @"https://www.xiaomadada.com/apphtml/youhuiquan.html"
#define kAgencyUrl              @"https://www.xiaomadada.com/apphtml/daiban.html"
#define kRescureUrl             @"https://www.xiaomadada.com/apphtml/jiuyuan.html"
#define kAboutCouponPkgUrl      @"https://www.xiaomadada.com/apphtml/guanyulibao.html"
#define kWeeklyCouponUrl    @"https://www.xiaomadada.com/apphtml/weeklycoupon.html"
#define kAddGasNoticeUrl    @"https://xiaomadada.com/apphtml/chongzhishuoming.html"
#define kGasPaymentResultUrl      @"https://www.xiaomadada.com/paaweb/general/appDownload?ch=10002"
#define kGasLicenseUrl          @"https://xiaomadada.com/apphtml/license-youka.html"
#define kInsuranceDirectSellingUrl  @"https://www.xiaomadada.com/apphtml/chexianzhixiao.html"


#endif
