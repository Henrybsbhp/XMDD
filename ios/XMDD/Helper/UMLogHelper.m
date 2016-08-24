//
//  UMLogHelper.m
//  XiaoMa
//
//  Created by jt on 16/1/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UMLogHelper.h"

@class HomePageVC;
@class CarWashTableVC;

@implementation UMLogHelper

+ (NSDictionary *)getPagesUMLogInfo
{
    static dispatch_once_t onceToken;
    static NSDictionary *g_pagesUMLogInfo;
    dispatch_once(&onceToken, ^{
        g_pagesUMLogInfo = @{@"VcodeLoginVC":@{@"pagetag":@"rp002"},//短信验证码登录
                             
                             //洗车
                             @"HomePageVC":@{@"pagetag":@"rp101"},//首页
                             @"CarwashShopListVC":@{@"pagetag":@"rp102"},//一键洗车
                             @"SearchShopListVC":@{@"pagetag":@"rp103"},//一键洗车搜索
                             @"CarWashNavigationViewController":@{@"pagetag":@"rp104"},//店铺导航
                             @"NearbyShopsViewController":@{@"pagetag":@"rp104"},//附近店铺
                             @"ShopDetailVC":@{@"pagetag":@"rp105"},// 商户详情
                             @"PayForWashCarVC":@{@"pagetag":@"rp1018"},// 洗车支付
                             @"ChooseCarwashTicketVC":@{@"pagetag":@"rp109"},//优惠劵选择
                             @"PaymentSuccessVC":@{@"pagetag":@"rp110"},//支付成功
                             
                             //保险
                             @"InsuranceVC":@{@"pagetag":@"rp1000"},//保险服务
                             @"InsInputInfoVC":@{@"pagetag":@"rp1001"},//填写资料
                             @"InsuranceInfoSubmitingVC":@{@"pagetag":@"rp1002"},//达达帮忙
                             @"InsCoverageSelectVC":@{@"pagetag":@"rp1003"},//选择车险
                             @"InsCheckFailVC":@{@"pagetag":@"rp1004"},//核保结果-失败
                             @"InsCheckResultsVC":@{@"pagetag":@"rp1004"},//核保结果-成功
                             @"InsBuyVC":@{@"pagetag":@"rp1005"},//保险在线购买
                             @"PayForInsuranceVC":@{@"pagetag":@"rp1006"},//保单支付
                             @"InsPayResultVC":@{@"pagetag":@"rp1007"},//保单支付成功
                             @"InsSubmitResultVC":@{@"pagetag":@"rp1009"},//提交结果
                             @"InsAppointmentVC":@{@"pagetag":@"rp1010"},//保险预约购买
                             @"InsAppointmentSuccessVC":@{@"pagetag":@"rp1011"},//保险预约结果
                             @"InsuranceOrderVC":@{@"pagetag":@"rp1012"},//保单详情
                             @"InsInputDateVC":@{@"pagetag":@"rp1013"},//保险选择起保日期
                             
                             //发现
                             @"ListWebVC":@{@"pagetag":@"rp202"},//发现列表
                             @"DetailWebVC":@{@"pagetag":@"rp203"},//发现详情
                             
                             //我的
                             @"MineVC":@{@"pagetag":@"rp301"},//我的
                             @"MyInfoViewController":@{@"pagetag":@"rp302"},//我的资料
                             @"MyCouponVC":@{@"pagetag":@"rp304"},//我的优惠劵
                             @"EditMyInfoViewController":@{@"pagetag":@"rp305"},//我的资料编辑
                             @"CarsListVC":@{@"pagetag":@"rp309"},//我的爱车
                             @"EditCarVC":@{@"pagetag":@"rp312"},//编辑我的爱车
                             @"MyBankVC":@{@"pagetag":@"rp314"},//我的银行卡
                             @"BindBankCardVC":@{@"pagetag":@"rp313"},//绑定银行卡
                             @"CardDetailVC":@{@"pagetag":@"rp315"},//银行卡详情
                             @"MyCollectionListVC":@{@"pagetag":@"rp316"},//我的收藏
                             @"MyOrderListVC":@{@"pagetag":@"rp318"},//我的订单列表
                             @"CarwashOrderDetailVC":@{@"pagetag":@"rp320"},//洗车订单
                             @"AboutViewController":@{@"pagetag":@"rp322"},//关于我们
                             @"FeedbackVC":@{@"pagetag":@"rp323"},//意见反馈
                             @"MessageListVC":@{@"pagetag":@"rp324"},//消息列表
                             @"UnbundlingVC":@{@"pagetag":@"rp329"},//解绑（银行卡）
                             @"JoinUsViewController":@{@"pagetag":@"rp333"},//加盟热线
                             @"JoinResultViewController":@{@"pagetag":@"rp101"},//加盟结果
                             
                             // 每周礼券
                             @"NewGainAwardVC":@{@"pagetag":@"rp402"},//每周礼券
                             
                             //加油
                             @"GasVC":@{@"pagetag":@"rp501"},//加油首页
                             @"GasAddCardVC":@{@"pagetag":@"rp504"},//油卡添加
                             @"GasCardListVC":@{@"pagetag":@"rp505"},//油卡列表
                             @"GasPaymentResultVC":@{@"pagetag":@"rp506"},//油卡充值支付结果
                             @"GasPayForCZBVC":@{@"pagetag":@"rp507"},//浙商支付
                             @"PayForGasViewController":@{@"pagetag":@"rp508"},//油卡充值支付
                             
                             // 估值
                             @"ValuationHomeVC":@{@"pagetag":@"rp601"},//二手车估值
                             @"ValuationResultVC":@{@"pagetag":@"rp602"},//二手车估值结果
                             @"HistoryCollectionVC":@{@"pagetag":@"rp603"},//历史估值列表
                             @"SecondCarValuationVC":@{@"pagetag":@"rp604"},//估值车提交平台
                             @"CommitSuccessVC":@{@"pagetag":@"rp605"},//提交平台成功
                             
                             //救援
                             @"RescueHomeViewController":@{@"pagetag":@"rp701"},//救援首页
                             @"RescueDetailsVC":@{@"pagetag":@"rp702"},//救援详情
                             @"RescueCommentsVC":@{@"pagetag":@"rp706"},//救援评价
                             @"RescueCouponViewController":@{@"pagetag":@"rp708"},//救援优惠劵
                             
                             // 协办
                             @"CommissionOrderVC":@{@"pagetag":@"rp801"},//代办首页
                             @"CommissionConfirmVC":@{@"pagetag":@"rp802"},//代办确认
                             @"CommissionSuccessVC":@{@"pagetag":@"rp803"},//代办预约成功
                             
                             //违章查询
                             @"ViolationItemViewController":@{@"pagetag":@"rp901"},//违章查询
                             
                             //小马互助
                             @"MutualInsVC":@{@"pagetag":@"huzhushouye"},//互助首页
                             @"MutInsCalculateVC":@{@"pagetag":@"feiyongshisuan"},//费用试算
                             @"MutInsCalculateResultVC":@{@"pagetag":@"shisuanjieguo"},//试算结果
                             @"MutInsSystemGroupListVC":@{@"pagetag":@"huzhutuan"},//互助团
                             @"GroupIntroductionVC":@{@"pagetag":@"rutuanyaoqiu"},//入团要求
                             @"MutualInsPickCarVC":@{@"pagetag":@"xuanzecheliang"},//选择车辆
                             @"MutualInsPicUpdateVC":@{@"pagetag":@"wanshanziliao"},//完善资料
                             @"MutualInsPicUpdateResultVC":@{@"pagetag":@"tijiaochenggong"},//提交成功
                             @"MutualInsGroupDetailVC":@{@"pagetag":@"tuanxiangqing"},//团详情
                             @"MutualInsPicListVC":@{@"pagetag":@"woyaobuchang"},//我要补偿
                             
                             
                             };
    });
    return g_pagesUMLogInfo;
}

@end
