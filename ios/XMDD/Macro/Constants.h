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
    /// 全部洗车服务
    ShopServiceAllCarWash = 0,
    /// 普洗
    ShopServiceCarWash = 1,
    /// 精洗，用心洗
    ShopServiceCarwashWithHeart = 2,
    /// 汽车保养
    ShopServiceCarMaintenance = 3,
    /// 汽车美容
    ShopServiceCarBeauty = 4,
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
    PaymentChannelCZBCreditCard,// (废弃)
    PaymentChannelUPpay = 82 ,
    PaymentChannelApplePay = 81
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
//13-首页悬浮广告
//14-首页第二栏广告
//17-互助首页广告
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
    AdvertisementAlert = 13,
    AdvertisementHomePageBottom = 14,
    AdvertisementMutualIns = 15,
    AdvertisementMutualInsTop = 16,
    AdvertisementMutualInsHome = 17,
    AdvertisementTypeActivities = 20,
    AdvertisementTypeLeaunch = 30,
    AdvertisementCarwashSuccess = 50,
    AdvertisementGasSuccess = 51,
    AdvertisementMutualInsSuccess = 52,
    AdvertisementInsSuccess = 53,
    AdvertisementMaintenanceSuccess = 54,
    AdvertisementBeautySuccess = 55,
} AdvertisementType;

///分享页面类型
//2-洗车完成分享
//3-每周礼券红包分享
//4-保险支付完成分享
//5-油卡充值完成分享
//6-优惠券分享（转赠）
//7-爱车估值结果分享
//8-提交卖车app分享
//9-app分享
//10: 在互助团里的APP分享
//11:小马互助晒单炫耀
//100-其他分享（jsbridge中的分享）

typedef enum : NSUInteger {
    ShareSceneCarwash = 2,
    ShareSceneGain = 3,
    ShareSceneInsurance = 4,
    ShareSceneGas = 5,
    ShareSceneCoupon = 6,
    ShareSceneValuation = 7,
    ShareSceneAppCarSell = 8,
    ShareSceneAppAbout = 9,
    ShareSceneCipher = 10,
    ShareSceneShowXmddIns = 11,
    ShareSceneLocalShare = 100
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

#define kUPayVerifyKey          @"http://backtomerchant.com/?"
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

#define XMINSPrefix @"#小马互助"

#define SensorAnalyticsInstance [SensorsAnalyticsSDK sharedInstance]

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
//单例别名
#define gAppDelegate       ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define gAppMgr     [AppManager sharedManager]
#define gNetworkMgr [NetworkManager sharedManager]
#define gToast      [HKToast sharedTosast]
#define gMapHelper ([MapHelper sharedHelper])
#define gMediaMgr  ([[AppManager sharedManager] mediaMgr])
#define gPhoneHelper  ([PhoneHelper sharedHelper])
#define gAdMgr [AdvertisementManager sharedManager]
#define gSupportFileMgr [SupportFileManager sharedManager]
#define gAssistiveMgr [AssistiveManager sharedManager]
#define gStoreMgr   [GlobalStoreManager sharedManager]

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
#define mutualInsPayStoryboard [UIStoryboard storyboardWithName:@"MutualInsPay" bundle:nil]
#define mutInsGrouponStoryboard [UIStoryboard storyboardWithName:@"MutualInsGroupon" bundle:nil]
#define mutualInsJoinStoryboard [UIStoryboard storyboardWithName:@"MutualInsJoin" bundle:nil]
#define aboutStoryboard [UIStoryboard storyboardWithName:@"About" bundle:nil]


#define LocationFail 7001

//通知定义
#define kNotifyRefreshMyBankcardList        @"com.huika.xmdd.RefreshMyBankcardList"
#define kNotifyRefreshMyCouponList          @"com.huika.xmdd.RefreshMyCouponList"
#define kNotifyViolationPaySuccess          @"com.huika.xmdd.ViolationPaySuccess"
#define kNotifyCardBindingSuccess           @"com.huika.xmdd.CardBindingSuccess"
///通知MutualInsAskForCompensationVC进行fetchAllData操作
#define kNotifyUpdateClaimList              @"k.notification.MutualInsAskForCompensationVC.fetchAllData"
/// 违章放弃代办通知
#define kNotifyCommissionAbandoned          @"com.huika.xmdd.commissionAbandoned"

// 需要更新救援列表
#define kNotifyRescueRecordVC               @"com.huika.xmdd.rescueRecordVC"
// 需要更新协办列表
#define kNotifyCommissionRecordVC           @"com.huika.xmdd.commissionRecordVC"

//key定义
#define kOriginVC       @"originVC"
#define kNextVC         @"nextVC"
#define kOriginRoute    @"kOriginRoute"


/// 相关网页地址

#define LogUploadUrl @"http://dev01.xiaomadada.com/log/upload"

#define kWechatPublicAccountUrl [UrlPrefix append:@"/apphtml/wechatyindao.html"] // 微信公众号
#define kWeeklyCouponHelpUrl    [UrlPrefix append:@"/apphtml/meizhouliquan-v"] //每周礼券
#define kAboutViewServiceHelpUrl     [UrlPrefix append:@"/apphtml/shiyongbangzhu-v"] // 使用帮助
#define kMutualInsGroupDetailHelpUrl [UrlPrefix append:@"/apphtml/tuan-help.html"] //小马互助团详情使用帮助
#define kInsuranceIntroUrl  [UrlPrefix append:@"/apphtml/baoxianfuwu.html"]  //保险服务首页介绍
#define kOrderDetailsUrl [UrlPrefix append:@"/paaweb/general/order/detail/by-id"]//订单详情 测试地址
#define kPayCenterNotifyUrl [UrlPrefix append:@"/paaweb/general/order/paynotify"] //支付通知地址
#define kDiscoverUrl [UrlPrefix append:@"/paaweb/general/discoveryload"] //发现地址
#define kGasOrderPaidUrl [UrlPrefix append:@"/paaweb/general/order/paynotify"] //分期加油支付后的通知地址
#define kServiceLicenseUrl [UrlPrefix append:@"/apphtml/license.html"]
#define kAppShareUrl        [UrlPrefix append:@"/apphtml/share001.html"]
#define kGetMoreCouponUrl     [UrlPrefix append:@"/apphtml/youhuiquan.html"]
#define kAgencyUrl              [UrlPrefix append:@"/apphtml/daiban.html"]
#define kRescureUrl             [UrlPrefix append:@"/apphtml/jiuyuan.html"]
#define kAboutCouponPkgUrl       [UrlPrefix append:@"/apphtml/guanyulibao.html"]
#define kAddGasNoticeUrl     [UrlPrefix append:@"/apphtml/chongzhishuoming.html"]
#define kInstalmentGasNoticeUrl  [UrlPrefix append:@"/apphtml/fenqijiayou.html"]
#define kGasPaymentResultUrl       [UrlPrefix append:@"/paaweb/general/appDownload?ch=10002"]
#define kGasLicenseUrl           [UrlPrefix append:@"/apphtml/license-youka.html"]
#define kInsuranceDirectSellingUrl   [UrlPrefix append:@"/apphtml/chexianzhixiao.html"]
#define kMoneySavingStrategiesUrl   [UrlPrefix append:@"/apphtml/view/shengqian/index.html?jump=t"]
#define kInsuranceLicenseUrl     [UrlPrefix append:@"/apphtml/xmdd-ins-licenese.html"]
#define kNewbieGuideUrl  [UrlPrefix append:@"/apphtml/lingyuanxiche.html"] //新手引导

#endif
