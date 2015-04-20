//
//  Contants.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#ifndef XiaoMa_Contants_h
#define XiaoMa_Contants_h

<<<<<<< HEAD
//颜色定义
=======
/// 服务类型
typedef enum : NSUInteger {
    ShopServiceCarWash = 1,
    ShopServiceRescue,
    ShopServiceAgency,
} ShopServiceType;

/// 支付渠道
typedef enum : NSUInteger {
    PaymentChannelInstallments,
    PaymentChannelAlipay,
    PaymentChannelWechat,
    PaymentChannelABCCarWashAmount,
    PaymentChannelABCIntegral,
    PaymentChannelCoupon
} PaymentChannelType;

>>>>>>> 1d764f58f03a8f1935e7764c56bf5fb6816b0a56
#define kDefTintColor   HEXCOLOR(@"#15ac1f")
#define kDefLineColor   HEXCOLOR(@"#e0e0e0")

//字符串定义
#define kRspPrefix      @"█ ▇ ▆ ▅ ▄ ▃ ▂"
#define kReqPrefix      @"▂ ▃ ▄ ▅ ▆ ▇ █"
#define kErrPrefix      @"〓〓〓〓〓"

//单例别名
#define gAppMgr     [AppManager sharedManager]
#define  gAppDelegate       ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define gNetworkMgr [NetworkManager sharedManager]
<<<<<<< HEAD
#define gToast      [HKToast sharedTosast]
=======
#define gAlipayHelper       ([AlipayHelper sharedHelper])
#define gMapHelper ([MapHelper sharedHelper])

#define mainStoryboard [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define carWashStoryboard [UIStoryboard storyboardWithName:@"Carwash" bundle:nil]
#define commonStoryboard [UIStoryboard storyboardWithName:@"Common" bundle:nil]
>>>>>>> 1d764f58f03a8f1935e7764c56bf5fb6816b0a56

#endif
