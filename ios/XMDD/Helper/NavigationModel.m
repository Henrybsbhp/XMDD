//
//  NavigationModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NavigationModel.h"
#import "CarwashOrderDetailVC.h"
#import "InsuranceOrderVC.h"
#import "MyCouponVC.h"
#import "InsuranceStore.h"
#import "GasVC.h"
#import "DetailWebVC.h"
#import "CarsListVC.h"
#import "GasVC.h"
#import "PaymentCenterViewController.h"
#import "ViolationViewController.h"
#import "InsuranceVC.h"
#import "InsSimpleCar.h"
#import "InsCheckResultsVC.h"
#import "MyCollectionListVC.h"
#import "ValuationHomeVC.h"
#import "MutualInsOrderInfoVC.h"
#import "MutualInsAskForCompensationVC.h"
#import "MoreSubmodulesVC.h"
#import "ParkingShopGasInfoVC.h"
#import "MutualInsVC.h"
#import "MutualInsHomeAdVC.h"
#import "MutualInsGroupDetailVC.h"
#import "HKViewControllerFactory.h"
#import "CarwashShopListVC.h"
#import "ViolationMissionHistoryVC.h"
#import "ViolationCommissionStateVC.h"
#import "ShopListVC.h"
#import "AppDelegate.h"
#import "MyBindedCardVC.h"
#import "MutInsCalculatePageVC.h"
#import "CommissionPaymentStatusVC.h"
#import "RescuePaymentStatusVC.h"

@interface NavigationModel()

@end

@implementation NavigationModel

- (BOOL)pushToViewControllerByUrl:(NSString *)url
{
    //    url = @"xmdd://j?t=cl&id=47898";
    BOOL flag = NO;
    //是内部跳转链接(以xmdd://开头)
    if ([url hasPrefix:@"xmdd://"]) {
        NSDictionary *params = [self getActionParamsFromUrl:url];
        NSString *name = params[@"t"];
        NSString *value = params[@"id"];
        NSString *value2 = params[@"mid"];
        
        UIViewController * topVC = self.curNavCtrl.topViewController;
        
        //登录 (针对根据网页中url跳转登录//口令入团也用到了)
        if ([@"login" equalByCaseInsensitive:name] && !gAppMgr.myUser) {
            VcodeLoginVC *vc = [UIStoryboard vcWithId:@"VcodeLoginVC" inStoryboard:@"Login"];
            HKNavigationController *nav = [[HKNavigationController alloc] initWithRootViewController:vc];
            [self.curNavCtrl presentViewController:nav animated:YES completion:nil];
        }
        //领取礼券
        else if ([@"a" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"NewGainAwardVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"NewGainAwardVC" inStoryboard:@"Award"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //爱车列表
        else if ([@"cl" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            CarsListVC *vc = (CarsListVC *)[self viewControllerByIdentify:@"CarsListVC" withPrecidate:nil];
            if (vc) {
                [self.curNavCtrl popToViewController:vc animated:YES];
                vc.originCarID = @([value integerValue]);
            }
            else {
                vc = [UIStoryboard vcWithId:@"CarsListVC" inStoryboard:@"Car"];
                vc.originCarID = @([value integerValue]);
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //保险
        else if ([@"ins" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"InsuranceVC"]) {
                InsuranceVC *vc = [UIStoryboard vcWithId:@"InsuranceVC" inStoryboard:@"Insurance"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //保险介绍
        else if ([@"insi" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:@"InsIntroVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"InsIntroVC" inStoryboard:@"Insurance"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //普洗商户列表
        else if ([@"sl" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:@"CarwashShopListVC"]) {
                CarwashShopListVC *vc = [[CarwashShopListVC alloc] init];
                vc.serviceType = ShopServiceCarWash;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //精洗商户列表
        else if ([@"whsl" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:@"CarwashShopListVC"]) {
                CarwashShopListVC *vc = [[CarwashShopListVC alloc] init];
                vc.serviceType = ShopServiceCarwashWithHeart;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //保养
        else if ([@"mtsl" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:kCarMaintenanceShopListVCID]) {
                ShopListVC *vc = [[ShopListVC alloc] init];
                vc.router.key = kCarMaintenanceShopListVCID;
                vc.serviceType = ShopServiceCarMaintenance;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        // 美容
        else if ([@"beautysl" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:kCarBeautyShopListVCID]) {
                ShopListVC *vc = [[ShopListVC alloc] init];
                vc.router.key = kCarBeautyShopListVCID;
                vc.serviceType = ShopServiceCarBeauty;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //优惠券
        else if ([@"cp" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeCarWash;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //保险优惠券
        else if ([@"icp" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeInsurance;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //加油优惠券
        else if ([@"gcp" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeGas;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //其他优惠券
        else if ([@"ocp" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeOthers;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //礼包
        else if ([@"cpk" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"CouponPkgViewController"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"CouponPkgViewController" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //银行卡
        else if ([@"bcl" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            if (![self popToViewControllerIfNeededByIdentify:@"MyBindedCardVC"]) {
                MyBindedCardVC *vc = [UIStoryboard vcWithId:@"MyBindedCardVC" inStoryboard:@"Bank"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //订单支付
        else if ([@"paycenter" equalByCaseInsensitive:name])
        {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            NSString * traderNo = params[@"tradeno"];
            NSString * traderType = params[@"tradetype"];
            
            PaymentCenterViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"PaymentCenterViewController"];
            vc.tradeNo = traderNo;
            vc.tradeType = traderType;
            vc.originVc = self.curNavCtrl;
            HKNavigationController *nav = [[HKNavigationController alloc] initWithRootViewController:vc];
            [self.curNavCtrl presentViewController:nav animated:YES completion:nil];
        }
        //加油首页
        else if ([@"g" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:@"GasVC"]) {
                GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        ///违章查询
        else if ([@"vio" equalByCaseInsensitive:name])
        {
            if ([LoginViewModel loginIfNeededForTargetViewController:topVC]) {
                
                ViolationViewController * vc = [violationStoryboard instantiateViewControllerWithIdentifier:@"ViolationViewController"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        ///估值
        else if ([@"val" equalByCaseInsensitive:name])
        {
            ValuationHomeVC * vc = [valuationStoryboard instantiateViewControllerWithIdentifier:@"ValuationHomeVC"];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        ///核保结果 TODO
        else if ([@"icr" equalByCaseInsensitive:name])
        {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            NSNumber *premiumid = value.length > 0 ? @([value integerValue]) : nil;
            if (premiumid) {
                InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
                InsSimpleCar *car = [[InsSimpleCar alloc] init];
                car.carpremiumid = premiumid;
                vc.insModel.simpleCar = car;
                vc.insModel.originVC = self.curNavCtrl.topViewController;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //保险订单
        else if ([@"ino" equalByCaseInsensitive:name]) {
            
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            NSNumber *orderid = value.length > 0 ? @([value integerValue]) : nil;
            //保险订单列表
            if (!orderid && ![self popToViewControllerIfNeededByIdentify:@"MyOrderListVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MyOrderListVC" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            //保险订单详情
            else if (orderid){
                UIViewController *vc = [self viewControllerByIdentify:@"InsuranceOrderVC" withPrecidate:^BOOL(UIViewController *curvc) {
                    InsuranceOrderVC *vc = (InsuranceOrderVC *)curvc;
                    return [orderid isEqualToNumber:vc.order.orderid] || [orderid isEqualToNumber:vc.orderID];
                }];
                if (vc) {
                    [self.curNavCtrl popToViewController:vc animated:YES];
                    [[[InsuranceStore fetchExistsStore] getInsOrderByID:orderid] send];
                }
                else {
                    InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
                    vc.orderID = orderid;
                    [self.curNavCtrl pushViewController:vc animated:YES];
                }
            }
            flag = YES;
        }
        //洗车订单详情
        else if ([@"o" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            NSNumber *orderid = @([value integerValue]);
            if ([self popToViewControllerIfNeededByIdentify:@"CarwashOrderDetailVC" withPrecidate:^BOOL(UIViewController *curvc) {
                CarwashOrderDetailVC *vc = (CarwashOrderDetailVC *)curvc;
                return [orderid isEqualToNumber:vc.order.orderid] || [orderid isEqualToNumber:vc.orderID];
            }]) {
                CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
                vc.orderID = orderid;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //订单列表
        else if ([@"ol" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            if (![self popToViewControllerIfNeededByIdentify:@"MyOrderListVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MyOrderListVC" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //其他订单
        else if ([@"otho" equalByCaseInsensitive:name])
        {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            NSNumber *orderid = value.length > 0 ? @([value integerValue]) : nil;
            NSString *type = params[@"tp"];
            NSString *urlStr = [kOrderDetailsUrl stringByAppendingString:[NSString stringWithFormat:@"?token=%@&oid=%@&tradetype=%@",gNetworkMgr.token ,orderid, type]];
            
            UIViewController *vc = [self viewControllerByIdentify:@"DetailWebVC" withPrecidate:^BOOL(UIViewController *curvc) {
                DetailWebVC *vc = (DetailWebVC *)curvc;
                return [urlStr rangeOfString:vc.url].length;
            }];
            
            if (vc) {
                [self.curNavCtrl popToViewController:vc animated:YES];
            }
            else {
                DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                vc.title = @"订单详情";
                vc.url = urlStr;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //收藏列表
        else if ([@"fl" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            if (![self popToViewControllerIfNeededByIdentify:@"MyCollectionListVC"]) {
                MyCollectionListVC *vc = [[MyCollectionListVC alloc] init];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //消息列表
        else if ([@"msg" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            if (![self popToViewControllerIfNeededByIdentify:@"MessageListVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MessageListVC" inStoryboard:@"Message"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //商店详情
        else if ([@"sd" equalByCaseInsensitive:name]) {
            
        }
        //加油记录
        else if ([@"gl" equalByCaseInsensitive:name]) {
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            if (![self popToViewControllerIfNeededByIdentify:@"GasRecordVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"GasRecordVC" inStoryboard:@"Gas"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //协办
        else if ([@"ast" equalByCaseInsensitive:name]) {
            UIViewController *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionOrderVC"];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        //协办详情
        else if ([@"astorder" equalByCaseInsensitive:name]) {
            
            // 通过有无 value / id 来判断进入协办详情 / 协办列表的页面
            if (value.length > 0) {
                CommissionPaymentStatusVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionPaymentStatusVC"];
                vc.vcType = 1;
                vc.isEnterFromHomePage = YES;
                vc.applyID = @(value.integerValue);
                [self.curNavCtrl pushViewController:vc animated:YES];
            } else {
                UIViewController *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionRecordVC"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }

        //救援
        else if ([@"rescue" equalByCaseInsensitive:name]) {
            UIViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueHomeV2VC"];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        //救援详情
        else if ([@"rescueorder" equalByCaseInsensitive:name]) {
            
            // 通过有无 value / id 来判断进入救援详情 / 救援列表的页面
            if (value.length > 0) {
                RescuePaymentStatusVC *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescuePaymentStatusVC"];
                vc.vcType = 1;
                vc.isEnterFromHomePage = YES;
                vc.applyID = @(value.integerValue);
                [self.curNavCtrl pushViewController:vc animated:YES];
            } else {
                UIViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueRecordVC"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
        }
        //加入小马互助长条广告
        else if ([@"coinsad" equalByCaseInsensitive:name]) {
            
            MutualInsHomeAdVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsHomeAdVC"];
            NSString * channel = params[@"channel"];
            vc.sensorChannel = channel;
            [self.curNavCtrl pushViewController:vc animated:YES];
            return YES;
        }
        //加入小马互助团
        else if ([@"coins" equalByCaseInsensitive:name]) {
            
            NSString * channel = params[@"channel"];
            UIViewController *vc = [HKViewControllerFactory mutualInsVCWithChannel:channel];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        //加入小马费用试算
        else if ([@"coinscalc" equalByCaseInsensitive:name]) {
            
            NSString * channel = params[@"channel"];
            MutInsCalculatePageVC *vc = [UIStoryboard vcWithId:@"MutInsCalculatePageVC" inStoryboard:@"MutualInsJoin"];
            vc.sensorChannel = channel;
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        //加入小马互助团系统团
        else if ([@"cosys" equalByCaseInsensitive:name]) {
            
            UIViewController *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutInsSystemGroupListVC"];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        /// 小马互助订单详情
        else if ([@"coinso" equalByCaseInsensitive:name]) {
            
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            MutualInsOrderInfoVC *vc = [UIStoryboard vcWithId:@"MutualInsOrderInfoVC" inStoryboard:@"MutualInsPay"];
            vc.contractId = @([value integerValue]);
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        /// 小马互助团详情
        else if ([@"coinsdtl" equalByCaseInsensitive:name]) {
            
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            MutualInsGroupDetailVC *vc = [[MutualInsGroupDetailVC alloc] init];
            vc.router.userInfo = [[CKDict alloc] init];
            vc.router.userInfo[kMutInsGroupID] = @([value integerValue]);
            vc.router.userInfo[kMutInsMemberID] = @([value2 integerValue]);
            [(HKNavigationController *)self.curNavCtrl pushViewController:vc animated:YES];
        }
        ///补偿详情
        else if ([@"coincldtlo" equalByCaseInsensitive:name]) {
            
            if (![LoginViewModel loginIfNeededForTargetViewController:topVC])
                return YES;
            
            MutualInsAskForCompensationVC *vc =  [UIStoryboard vcWithId:@"MutualInsAskForCompensationVC" inStoryboard:@"MutualInsClaims"];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        ///首页更多模块
        else if ([@"moresubmodule" equalByCaseInsensitive:name]) {
            
            MoreSubmodulesVC *vc =  [[MoreSubmodulesVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        ///附近服务
        else if ([@"nearbyservice" equalByCaseInsensitive:name]) {
            
            NSString *type = params[@"type"];
            ParkingShopGasInfoVC * vc = [UIStoryboard vcWithId:@"ParkingShopGasInfoVC" inStoryboard:@"Common"];
            vc.searchType = @([type integerValue]);
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        ///我的违章代办列表
        else if ([@"violist" equalByCaseInsensitive:name]) {
            
            ViolationMissionHistoryVC *vc = [UIStoryboard vcWithId:@"ViolationMissionHistoryVC" inStoryboard:@"Violation"];
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
        ///我的违章代办详情
        else if ([@"viodetail" equalByCaseInsensitive:name]) {
            
            ViolationCommissionStateVC *vc = [UIStoryboard vcWithId:@"ViolationCommissionStateVC" inStoryboard:@"Violation"];
            vc.recordID = @([value integerValue]);
            [self.curNavCtrl pushViewController:vc animated:YES];
        }
    }
    else if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        NSString * urlStr = [self httpUrlStringFrom:url];
        vc.url = [NavigationModel appendStaticParam:urlStr];
        [self.curNavCtrl pushViewController:vc animated:YES];
        flag = YES;
    }
    return flag;
}

- (void)handleForgroundNotification:(NSDictionary *)info
{
    NSString * alertStr = info[@"alert"];
    NSString * urlStr = info[@"url"];
    
    if (!alertStr || ![alertStr isKindOfClass:[NSString class]])
        return;
    
    NSData *alertData = [alertStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError * parseError;
    NSDictionary * alertDict = [NSJSONSerialization JSONObjectWithData:alertData options:0 error:&parseError];
    
    if (parseError || !alertDict)
    {
        return;
    }
    
    NSString * message = alertDict[@"info"];
    NSString * cancelStr = alertDict[@"cancel"];
    NSString * sureStr = alertDict[@"sure"];
    
    
    if (message.length)
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:cancelStr color:kGrayTextColor clickBlock:^(id alertVC) {
            
            [MobClick event:@"tuisongtanchuang" attributes:@{@"tuisongtanchuang":@"quxiao"}];
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:sureStr color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            
            [MobClick event:@"tuisongtanchuang" attributes:@{@"tuisongtanchuang":@"quzhifu"}];
            [self pushToViewControllerByUrl:urlStr];
        }];
        
        NSMutableArray * itemArray = [NSMutableArray array];
        if (cancelStr.length)
        {
            [itemArray safetyAddObject:cancel];
        }
        if (sureStr.length)
        {
            [itemArray safetyAddObject:confirm];
        }
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:message ActionItems:itemArray];
        [alert show];
    }
}

#pragma mark - Utility
- (NSDictionary *)getActionParamsFromUrl:(NSString *)url
{
    //用正则过滤出参数列表（如：@"name=jiang&code=4&age=25"）
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(?<=j\\?).*" options:0 error:nil];
    NSTextCheckingResult *rst = [regexp firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
    NSString *paramsString = [url substringWithRange:rst.range];
    NSArray *paramsArray = paramsString.length > 0 ? [paramsString componentsSeparatedByString:@"&"] : nil;
    
    //将参数列表转换成字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *str in paramsArray) {
        NSArray *pair = [str componentsSeparatedByString:@"="];
        [dict safetySetObject:[pair safetyObjectAtIndex:1] forKey:[pair safetyObjectAtIndex:0]];
    }
    return dict;
}

- (NSString *)httpUrlStringFrom:(NSString *)url
{
    if (url.length == 0) {
        return url;
    }
    NSMutableString *mutstr = [NSMutableString string];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(?<=\\().*?(?=\\))" options:0 error:nil];
    NSArray *matches = [regexp matchesInString:url options:0 range:NSMakeRange(0, url.length)];
    NSInteger index = 0;
    for (NSTextCheckingResult *rst in matches) {
        [mutstr appendString:[url substringFromIndex:index toIndex:rst.range.location-1]];
        [mutstr appendString:[self parseParamKey:[url substringWithRange:rst.range]]];
        index = rst.range.location+rst.range.length+1;
    }
    [mutstr appendString:[url substringFromIndex:index length:url.length-index]];
    return mutstr;
}

- (NSString *)parseParamKey:(NSString *)key
{
    NSString *value;
    if ([@"phone" equalByCaseInsensitive:key]) {
        value = gAppMgr.myUser.userID;
    }
    else if ([@"token" equalByCaseInsensitive:key]) {
        value = gNetworkMgr.token;
    }
    return value.length > 0 ? value : @"null";
}

+ (NSString *)appendParams:(NSDictionary *)params forUrl:(NSString *)url
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict setObject:gAppMgr.deviceInfo.appVersion forKey:@"version"];
    NSArray *kvs = [[dict allKeys] arrayByMappingOperator:^id(NSString *key) {
        NSString *value = dict[key];
        return [NSString stringWithFormat:@"%@=%@", key, value];
    }];
    
    NSString *strParams = [kvs componentsJoinedByString:@"&"];
    NSString *linkSymbol = [url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
    url = [NSString stringWithFormat:@"%@%@%@", url, linkSymbol, strParams];
    
    return url;
}

+ (NSString *)appendStaticParam:(NSString *)url
{
    NSString * rUrlStr = url;
    NSDictionary * dict = @{@"version":gAppMgr.clientInfo.clientVersion};
    NSMutableArray * tArray = [NSMutableArray array];
    for (NSString * key in [dict allKeys])
    {
        NSString * value = [dict objectForKey:key];
        NSString * item = [NSString stringWithFormat:@"%@=%@",key,value];
        [tArray addObject:item];
    }
    NSString * params = [tArray componentsJoinedByString:@"&"];
    
    if ([url rangeOfString:@"?"].length)
    {
        rUrlStr  = [NSString stringWithFormat:@"%@&%@",url,params];
    }
    else
    {
        rUrlStr  = [NSString stringWithFormat:@"%@?%@",url,params];
    }
    return rUrlStr;
}

- (BOOL)popToViewControllerIfNeededByIdentify:(id)identify
{
    return [self popToViewControllerIfNeededByIdentify:identify withPrecidate:nil];
}

- (BOOL)popToViewControllerIfNeededByIdentify:(id)identify withPrecidate:(BOOL(^)(UIViewController *))precidate
{
    UIViewController *vc = [self viewControllerByIdentify:identify withPrecidate:precidate];
    if (vc) {
        [self.curNavCtrl popToViewController:vc animated:YES];
    }
    return (BOOL)vc;
}

- (UIViewController *)viewControllerByIdentify:(id)identify withPrecidate:(BOOL(^)(UIViewController *))precidate
{
    HKNavigationController *navCtrl = (HKNavigationController *)self.curNavCtrl;
    CKRouter *router = navCtrl.routerList[identify];
    if (router && precidate && precidate(router.targetViewController)) {
        return router.targetViewController;
    }
    return nil;
}

@end
