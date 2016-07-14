//
//  XiaoMaConstants.h
//  XiaoMa
//
//  Created by jt on 15-6-1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#ifndef XiaoMa_XiaoMaConstants_h
#define XiaoMa_XiaoMaConstants_h
#endif


#if XMDDENT
    #define WECHAT_APP_ID          @"wx5ac14355ce361cb5"
    ///微博相关
    #define WEIBO_APP              @"com.sina.weibo"
    #define WEIBO_APP_ID           @"968145001"   //com.huika.xmdd.ent

    ///QQ相关
    #define QQ_APP                 @"com.tencent.mqq"
    #define QQ_API_ID              @"1104657316" //com.huika.xmdd.ent

    ///高德地图相关
    #define AMAP_API_ID            @"228479061fac2d7ff1b0b62531dc4841" //com.huika.xmdd.ent

    ///友盟相关
    #define UMeng_API_ID           @"556ea0c867e58e5156001bee" //com.huika.xmdd.ent

#else
    #define WECHAT_APP_ID          @"wxf346d7a6113bbbf9"
    ///微博相关
    #define WEIBO_APP              @"com.sina.weibo"
    #define WEIBO_APP_ID           @"2789804503"    //com.huika.xmdd

    ///QQ相关
    #define QQ_APP                 @"com.tencent.mqq"
    #define QQ_API_ID              @"1104617282"   //com.huika.xmdd

    ///高德地图相关
    #define AMAP_API_ID            @"8b0b664d2df333201514aacb8e1551bc"   //com.huika.xmdd

    ///友盟相关
    #define UMeng_API_ID           @"551caa7ffd98c58318000347" //com.huika.xmdd

#endif


#if XMDDEnvironment==0
//开发环境
    #define kInsuranceIntroUrl  @"http://dev.xiaomadada.com/apphtml/baoxianfuwu.html"  //保险服务首页介绍
    #define XmddBaseUrl @"http://dev01.xiaomadada.com"
    #define ApiBaseUrl @"http://dev01.xiaomadada.com/paa/rest/api"
    #define RCTServerBaseUrl    @"http://dev01.xiaomadada.com/rct/server"
    #define ApiFormalUrl @"https://www.xiaomadada.com/paa/rest/api" //正式
    #define DiscoverUrl @"http://dev01.xiaomadada.com/paaweb/general/discoveryload"//发现地址
    #define PayCenterNotifyUrl @"http://dev01.xiaomadada.com/paaweb/general/order/paynotify"
    #define OrderDetailsUrl @"http://dev01.xiaomadada.com/paaweb/general/order/detail/by-id"//订单详情 测试地址
    #define LogUploadUrl @"http://dev01.xiaomadada.com/log/upload"
    //小马互助团详情使用帮助
    #define MutualInsGroupDetailHelpUrl @"http://dev01.xiaomadada.com/apphtml/tuanxiangqing-help.html"

#elif XMDDEnvironment==1
//测试环境
    #define kInsuranceIntroUrl  @"http://dev.xiaomadada.com/apphtml/baoxianfuwu.html"  //保险服务首页介绍
    #define XmddBaseUrl @"http://dev01.xiaomadada.com"
    #define ApiBaseUrl @"https://dev.xiaomadada.com/paa/rest/api"
    #define RCTServerBaseUrl    @"http://dev01.xiaomadada.com/rct/server"
    #define ApiFormalUrl @"https://www.xiaomadada.com/paa/rest/api" //正式
    #define DiscoverUrl @"https://dev.xiaomadada.com/paaweb/general/discoveryload"//发现地址
    #define PayCenterNotifyUrl @"https://dev.xiaomadada.com/paaweb/general/order/paynotify"
    #define OrderDetailsUrl @"https://dev.xiaomadada.com/paaweb/general/order/detail/by-id"//订单详情 测试地址
    #define LogUploadUrl @"http://dev01.xiaomadada.com/log/upload"
    //小马互助团详情使用帮助
    #define MutualInsGroupDetailHelpUrl @"http://dev.xiaomadada.com/apphtml/tuanxiangqing-help.html"
#else
//开发环境
    #define kInsuranceIntroUrl  @"http://www.xiaomadada.com/apphtml/baoxianfuwu.html"  //保险服务首页介绍
    #define XmddBaseUrl @"https://www.xiaomadada.com"
    #define ApiBaseUrl @"https://www.xiaomadada.com/paa/rest/api" //正式
    #define RCTServerBaseUrl    @"http://dev01.xiaomadada.com/rct/server"
    #define ApiFormalUrl @"https://www.xiaomadada.com/paa/rest/api" //正式
    #define DiscoverUrl @"https://www.xiaomadada.com/paaweb/general/discoveryload"//发现地址
    #define PayCenterNotifyUrl @"https://www.xiaomadada.com/paaweb/general/order/paynotify"
    #define OrderDetailsUrl @"https://www.xiaomadada.com/paaweb/general/order/detail/by-id"//订单详情 正式地址
    #define LogUploadUrl @"http://dev01.xiaomadada.com/log/upload"
#endif
