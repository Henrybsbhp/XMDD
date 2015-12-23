//
//  InsuranceStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsuranceStore.h"
#import "GetInsCarListOp.h"
#import "GetInsProvinceListOp.h"

#define kEvtInsSimpleCars                           @"ins.simpleCars"
#define kEvtUpdateInsSimpleCar                      @"ins.simpleCar.update"
#define kEvtInsProvinces                            @"ins.provinces"

@implementation InsuranceStore

- (void)reloadForUserChanged
{
    self.simpleCars = nil;
}

- (void)dealloc
{
    
}
#pragma mark - Action
- (CKEvent *)getInsSimpleCars
{
    //获取保险支持的省份
    RACSignal *provSig = [[self getInsProvinces:NO] send];
    //获取保险车辆信息
    @weakify(self);
    RACSignal *carSig = [[[GetInsCarListOp operation] rac_postRequest] map:^id(GetInsCarListOp *op) {
        @strongify(self);
        JTQueue *cars = [[JTQueue alloc] init];
        for (InsSimpleCar *car in op.rsp_carinfolist) {
            [cars addObject:car forKey:car.licenseno];
        }
        self.simpleCars = cars;
        self.xmddHelpTip = op.rsp_xmddhelptip;
        return op.rsp_carinfolist;
    }];
    CKEvent *event = [[RACSignal combineLatest:@[provSig, carSig]] eventWithName:kEvtInsSimpleCars];
    return [self inlineEvent:event forDomain:@"simpleCars"];
}

- (CKEvent *)getInsProvinces:(BOOL)force
{
    if (!force && ![self needUpdateTimetagForKey:kEvtInsProvinces]) {
        return [[RACSignal return:self.insProvinces] eventWithName:kEvtInsProvinces];
    }
    @weakify(self);
    CKEvent *event = [[[[GetInsProvinceListOp operation] rac_postRequest] map:^id(GetInsProvinceListOp *op) {
        @strongify(self);
        JTQueue *areas = [[JTQueue alloc] init];
        for (Area *a in op.rsp_provinces) {
            [areas addObject:a forKey:a.aid];
        }
        self.insProvinces = areas;
        [self updateTimetagForKey:kEvtInsProvinces];
        return op.rsp_provinces;
    }] eventWithName:kEvtInsProvinces];
    return [self inlineEvent:event forDomain:@"insProvinces"];
}

- (CKEvent *)updateSimpleCarRefid:(NSNumber *)refid status:(int)status byLicenseno:(NSString *)licenseno
{
    InsSimpleCar *car = [self.simpleCars objectForKey:licenseno];
    car.refid = refid;
    car.status = status;
    return [self inlineEvent:[CKEvent eventWithName:kEvtUpdateInsSimpleCar signal:[RACSignal return:car]]];
}


@end
