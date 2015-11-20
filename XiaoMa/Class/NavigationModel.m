//
//  NavigationModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NavigationModel.h"
#import "WebVC.h"
#import "CarwashOrderDetailVC.h"
#import "InsuranceOrderVC.h"
#import "MyCouponVC.h"
#import "InsOrderStore.h"
#import "LoginVC.h"
#import "GasVC.h"
#import "DetailWebVC.h"
#import "CarListVC.h"
#import "GasVC.h"
#import "PaymentCenterViewController.h"

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
        //领取礼包
        if ([@"a" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"CheckAwardViewController"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"CheckAwardViewController" inStoryboard:@"Award"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //登录 (针对根据网页中url跳转登录)
        else if ([@"login" equalByCaseInsensitive:name] && !gAppMgr.myUser) {
                VcodeLoginVC *vc = [UIStoryboard vcWithId:@"VcodeLoginVC" inStoryboard:@"Login"];
                JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
                [self.curNavCtrl presentViewController:nav animated:YES completion:nil];
        }
        //优惠券
        else if ([@"cp" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeCarWash;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //保险优惠券
        else if ([@"icp" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeInsurance;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //其他优惠券
        else if ([@"ocp" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                [self postCustomNotificationName:kNotifyRefreshMyCouponList object:nil];
                MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                vc.jumpType = CouponNewTypeOthers;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //订单详情
        else if ([@"o" equalByCaseInsensitive:name] && gAppMgr.myUser) {
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
        else if ([@"ol" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyOrderListVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MyOrderListVC" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //保险订单
        else if ([@"ino" equalByCaseInsensitive:name] && gAppMgr.myUser) {
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
                    InsOrderStore *store = [InsOrderStore fetchExistsStore];
                    [store sendEvent:[store getInsOrderByID:orderid]];
                }
                else {
                    InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
                    vc.orderID = orderid;
                    [self.curNavCtrl pushViewController:vc animated:YES];
                }
            }
            flag = YES;
        }
        else if ([@"otho" equalByCaseInsensitive:name] && gAppMgr.myUser)
        {
            NSNumber *orderid = value.length > 0 ? @([value integerValue]) : nil;
            NSString * type = params[@"tp"];
            NSString * url = [OrderDetailsUrl stringByAppendingString:[NSString stringWithFormat:@"?token=%@&oid=%@&tradetype=%@",gNetworkMgr.token ,orderid, type]];
            
            UIViewController *vc = [self viewControllerByIdentify:@"DetailWebVC" withPrecidate:^BOOL(UIViewController *curvc) {
                DetailWebVC *vc = (DetailWebVC *)curvc;
                return [url rangeOfString:vc.url].length;
            }];
            if (vc) {
                [self.curNavCtrl popToViewController:vc animated:YES];
            }
            else {
                DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                vc.title = @"订单详情";
                vc.url = url;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //礼包
        else if ([@"cpk" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"CouponPkgViewController"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"CouponPkgViewController" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //收藏列表
        else if ([@"fl" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyCollectionViewController"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MyCollectionViewController" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //消息列表
        else if ([@"msg" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MessageListVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MessageListVC" inStoryboard:@"Message"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //商店详情
        else if ([@"sd" equalByCaseInsensitive:name]) {

        }
        //爱车列表
        else if ([@"cl" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            CarListVC *vc = (CarListVC *)[self viewControllerByIdentify:@"CarListVC" withPrecidate:nil];
            if (vc) {
                [self.curNavCtrl popToViewController:vc animated:YES];
                vc.originCarID = @([value integerValue]);
            }
            else {
                vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
                vc.originCarID = @([value integerValue]);
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //加油记录
        else if ([@"gl" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"GasRecordVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"GasRecordVC" inStoryboard:@"Gas"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //浙商加油
        else if ([@"czbgl" equalByCaseInsensitive:name]) {
            GasVC *vc = (GasVC *)[self viewControllerByIdentify:@"GasVC" withPrecidate:nil];
            if (vc) {
                [self.curNavCtrl popToViewController:vc animated:YES];
                vc.tabViewSelectedIndex = 1;
            }
            else {
                GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
                vc.tabViewSelectedIndex = 1;
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //加油首页
        else if ([@"g" equalByCaseInsensitive:name]) {
            if (![self popToViewControllerIfNeededByIdentify:@"GasVC"]) {
                GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        ///支付中心
        else if ([@"paycenter" equalByCaseInsensitive:name])
        {
            NSString * traderNo = params[@"tradeno"];
            NSString * traderType = params[@"tradetype"];

            PaymentCenterViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"PaymentCenterViewController"];
            vc.tradeNo = traderNo;
            vc.tradeType = traderType;
            vc.originVc = self.curNavCtrl;
            JTNavigationController *nav = [[JTNavigationController alloc] initWithRootViewController:vc];
            [self.curNavCtrl presentViewController:nav animated:YES completion:nil];
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

- (BOOL)popToViewControllerIfNeededByIdentify:(NSString *)identify
{
    return [self popToViewControllerIfNeededByIdentify:identify withPrecidate:nil];
}

- (BOOL)popToViewControllerIfNeededByIdentify:(NSString *)identify withPrecidate:(BOOL(^)(UIViewController *))precidate
{
    UIViewController *vc = [self viewControllerByIdentify:identify withPrecidate:precidate];
    if (vc) {
        [self.curNavCtrl popToViewController:vc animated:YES];
    }
    return (BOOL)vc;
}

- (UIViewController *)viewControllerByIdentify:(NSString *)identify withPrecidate:(BOOL(^)(UIViewController *))precidate
{
    UIViewController *vc;
    for (UIViewController *curvc in self.curNavCtrl.viewControllers) {
        if ([[curvc className] isEqualToString:identify]) {
            if (precidate && precidate(curvc)) {
                vc = curvc;
            }
            else if (!precidate) {
                vc = curvc;
            }
        }
    }
    return vc;
}

@end
