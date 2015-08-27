//
//  CouponModel.m
//  XiaoMa
//
//  Created by jt on 15/8/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CouponModel.h"
#import "GetUserResourcesV2Op.h"

@implementation CouponModel

- (RACSignal *)rac_getVaildResource
{
    RACSignal * signal;
    
    GetUserResourcesV2Op * op = [GetUserResourcesV2Op operation];
    signal = [[op rac_postRequest] flattenMap:^RACStream *(GetUserResourcesV2Op * rOp) {
        
        self.abcCarwashesCount = rOp.rsp_freewashes;
        self.abcIntegral = rOp.rsp_bankIntegral;
        self.validCZBankCreditCard = rOp.rsp_czBankCreditCard;
        
        // 过滤洗车券可用的
        NSArray * carwashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCarWash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        
        // 过滤浙商银行卡洗车券可用的
        NSArray * czBankcarwashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCZBankCarWash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        
        // 合并洗车券 = 普通洗车券 + 浙商
        NSMutableArray * carwashArray = [NSMutableArray arrayWithArray:czBankcarwashfilterArray];
        [carwashArray addObjectsFromArray:carwashfilterArray];
        self.validCarwashCouponArray = [NSArray arrayWithArray:carwashArray];
        
        // 过滤代金券可用的,然后按金额排序
        NSArray * cashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        self.validCashCouponArray = [cashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.couponAmount > obj2.couponAmount;
        }];
        self.validCashCouponArray = cashfilterArray;
        
        return [RACSignal return:rOp];
    }];
    
    return signal;
}

@end
