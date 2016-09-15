//
//  CouponModel.m
//  XiaoMa
//
//  Created by jt on 15/8/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CouponModel.h"
#import "GetUserResourcesV2Op.h"
#import "GetInscouponOp.h"

@implementation CouponModel

- (RACSignal *)rac_getVaildResource:(ShopServiceType)type andShopId:(NSNumber *)shopid
{
    RACSignal * signal;
    
    GetUserResourcesV2Op * op = [GetUserResourcesV2Op operation];
    op.shopServiceType = type;
    op.shopID = shopid;
    signal = [[op rac_postRequest] flattenMap:^RACStream *(GetUserResourcesV2Op * rOp) {
        
        self.abcCarwashesCount = rOp.rsp_freewashes;
        self.abcIntegral = rOp.rsp_bankIntegral;
        // 过滤洗车券可用的
        rOp.validCarwashCouponArray = [rOp.rsp_coupons arrayByFilteringOperator:^BOOL (HKCoupon *c) {
            if (c.conponType == CouponTypeCarWash) {
                return c.valid;
            }
            return NO;
        }];
        
        // 过滤代金券可用的,然后按金额排序
        NSArray * cashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCash ||
                c.conponType == CouponTypeBeauty ||
                c.conponType == CouponTypeMaintenance)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        rOp.validCashCouponArray = [cashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.couponAmount < obj2.couponAmount;
        }];
        
        return [RACSignal return:rOp];
    }];
    
    return signal;
}

- (RACSignal *)rac_getVaildInsuranceCoupon:(NSNumber *)orderid
{
    RACSignal * signal;
    
    GetInscouponOp * op = [GetInscouponOp operation];
    op.orderid = orderid;
    signal = [[op rac_postRequest] flattenMap:^RACStream *(GetInscouponOp * rOp) {
        
        self.validInsuranceCouponArray = rOp.rsp_inscouponsArray;
        
        return [RACSignal return:rOp];
    }];
    
    return signal;
}

@end
