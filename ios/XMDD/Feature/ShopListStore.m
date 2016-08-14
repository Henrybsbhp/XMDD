//
//  ShopListStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopListStore.h"
#import "ShopDetailStore.h"
#import "NSNumber+Format.h"
#import <MAMapKit/MAMapKit.h>

@interface ShopListStore ()
@property (nonatomic, strong) GetShopByDistanceV2Op *currentShopOp;
@property (nonatomic, strong) GetShopByNameV2Op *currentShopOpByName;
@end
@implementation ShopListStore

- (instancetype)initWithServiceType:(ShopServiceType)type {
    self = [super init];
    if (self) {
        _serviceType = type;
    }
    return self;
}

- (RACSignal *)fetchShopListByDistanceWithLocationErrorHandler:(void(^)(NSError *))handler {
    @weakify(self);
    return [[[[gMapHelper rac_getUserLocationWithAccuracy:kCLLocationAccuracyHundredMeters]
             catch:^RACSignal *(NSError *error) {
        
        if (handler) {
            handler(error);
        }
        return [RACSignal empty];
    }] flattenMap:^RACStream *(CLLocation *userLocation) {
        
        @strongify(self);
        _coordinate = userLocation.coordinate;
        GetShopByDistanceV2Op *op = [GetShopByDistanceV2Op operation];
        op.longitude = userLocation.coordinate.longitude;
        op.latitude = userLocation.coordinate.latitude;
        op.pageno = 1;
        op.serviceType =  self.serviceType;
        return [op rac_postRequest];
    }] doNext:^(GetShopByDistanceV2Op *op) {
        
        @strongify(self);
        self.currentShopOp = op;
        _shopList = [CKList listWithArray:op.rsp_shopArray];
    }];
}

- (RACSignal *)fetchMoreShopListByDistance {
    NSInteger oldPageno = self.currentShopOp.pageno;
    self.currentShopOp.pageno += 1;
    
    @weakify(self);
    return [[[self.currentShopOp rac_postRequest] doNext:^(GetShopByDistanceV2Op *op) {
        
        @strongify(self);
        [_shopList addObjectsFromArray:op.rsp_shopArray];
        self.currentShopOp = op;
    }] doError:^(NSError *error) {
        
        @strongify(self);
        self.currentShopOp.pageno = oldPageno;
    }];
}

+ (NSString *)descForShopServiceWithService:(JTShopService *)service andShop:(JTShop *)shop {
    switch (service.shopServiceType) {
        case ShopServiceCarBeauty:
            return @"打蜡、抛光、封釉";
        case ShopServiceCarMaintenance:
            return [NSString stringWithFormat:@"共%ld种保养套餐", shop.maintenanceServiceArray.count];
        default:
            return service.serviceName;
    }
}

+ (NSString *)markupForShopServicePrice:(JTShopService *)service {
    switch (service.shopServiceType) {
        case ShopServiceCarWash: case ShopServiceCarwashWithHeart: {
            return [ShopDetailStore markupStringWithOldPrice:service.oldOriginPrice curPrices:service.origprice];
        }
        default:
            return [NSString stringWithFormat:@"<font size='16' color='#ff7428'> ￥%@<font size='12'>起</font></font>",
                    [@(service.origprice) priceString]];
    }
    return nil;
}

- (RACSignal *)fetchShopListByName:(NSString *)name {
    if (!CLLocationCoordinate2DIsValid(self.coordinate)) {
        _coordinate = gMapHelper.coordinate;
    }
    GetShopByNameV2Op * op = [GetShopByNameV2Op operation];
    op.shopName = name;
    op.longitude = self.coordinate.longitude;
    op.latitude = self.coordinate.latitude;
    op.pageno = 1;
    op.orderby = 1;
    
    @weakify(self);
    return [[op rac_postRequest] doNext:^(GetShopByNameV2Op *op) {
        @strongify(self);
        self.currentShopOpByName = op;
    }];

}

- (RACSignal *)fetchMoreShopListByName {
    NSInteger oldPageno = self.currentShopOpByName.pageno;
    self.currentShopOpByName.pageno += 1;
    @weakify(self);
    return [[[self.currentShopOpByName rac_postRequest] doNext:^(GetShopByNameV2Op *op) {
        @strongify(self);
        self.currentShopOpByName = op;
    }] doError:^(NSError *error) {
        
        @strongify(self);
        self.currentShopOpByName.pageno = oldPageno;
    }];
}


@end
