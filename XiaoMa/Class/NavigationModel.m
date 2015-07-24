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

@implementation NavigationModel

- (BOOL)pushToViewControllerByUrl:(NSString *)url
{
    BOOL flag = NO;
    //是内部跳转链接(以xmdd://开头)
    if ([url hasPrefix:@"xmdd://"]) {
        NSDictionary *params = [self getActionParamsFromUrl:url];
        NSString *name = params[@"t"];
        NSString *value = params[@"id"];
        //优惠券
        if ([@"cp" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyCouponVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
        //订单详情
        else if ([@"o" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            NSNumber *orderid = @([value integerValue]);
            CarwashOrderDetailVC *vc = (CarwashOrderDetailVC *)[self viewControllerByIdentify:@"CarwashOrderDetailVC"];
            if (vc && ([orderid isEqualToNumber:vc.order.orderid] || [orderid isEqualToNumber:vc.orderID])) {
                [self.curNavCtrl popToViewController:vc animated:YES];
            }
            else {
                vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
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
        //商店详情
        else if ([@"sd" equalByCaseInsensitive:name]) {

        }
        //爱车列表
        else if ([@"cl" equalByCaseInsensitive:name] && gAppMgr.myUser) {
            if (![self popToViewControllerIfNeededByIdentify:@"MyCarListVC"]) {
                UIViewController *vc = [UIStoryboard vcWithId:@"MyCarListVC" inStoryboard:@"Mine"];
                [self.curNavCtrl pushViewController:vc animated:YES];
            }
            flag = YES;
        }
    }
    else if ([url hasPrefix:@"http://"]) {
        WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
        vc.url = url;
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

- (BOOL)popToViewControllerIfNeededByIdentify:(NSString *)identify
{
    UIViewController *vc = [self viewControllerByIdentify:identify];
    if (vc) {
        [self.curNavCtrl popToViewController:vc animated:YES];
        return YES;
    }
    return NO;
}

- (UIViewController *)viewControllerByIdentify:(NSString *)identify
{
    UIViewController *vc = [self.curNavCtrl.viewControllers firstObjectByFilteringOperator:^BOOL(NSObject *obj) {
        if ([obj isKindOfClass:[UIViewController class]]) {
            return [[(UIViewController *)obj className] equalByCaseInsensitive:identify];
        }
        return NO;
    }];
    return vc;
}
@end
