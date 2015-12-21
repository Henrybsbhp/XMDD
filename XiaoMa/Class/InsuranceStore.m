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
    @weakify(self);
    return [self inlineEvent:[[[[GetInsCarListOp operation] rac_postRequest] map:^id(GetInsCarListOp *op) {
        @strongify(self);
        JTQueue *cars = [[JTQueue alloc] init];
        for (InsSimpleCar *car in op.rsp_carinfolist) {
            [cars addObject:car forKey:car.licenseno];
        }
        self.simpleCars = cars;
        self.xmddHelpTip = op.rsp_xmddhelptip;
        return op.rsp_carinfolist;
    }] eventWithName:kEvtInsSimpleCars]];
}

- (CKEvent *)getInsProvinces
{
    @weakify(self);
    return [self inlineEvent:[[[[GetInsProvinceListOp operation] rac_postRequest] map:^id(GetInsProvinceListOp *op) {
        @strongify(self);
        JTQueue *areas = [[JTQueue alloc] init];
        for (Area *a in op.rsp_provinces) {
            [areas addObject:a forKey:a.aid];
        }
        self.insProvinces = areas;
        [self updateTimetagForKey:kEvtInsProvinces];
        return op.rsp_provinces;
    }] eventWithName:kEvtInsProvinces]];
}

- (CKEvent *)reloadInsSimpleCarsAndProvinces
{
    NSMutableArray *sigs = [NSMutableArray arrayWithObject:[[self getInsSimpleCars] signal]];
    if ([self needUpdateTimetagForKey:@"insProvinces"]) {
        [sigs addObject:[[self getInsProvinces] signal]];
    }
    return [self inlineEvent:[[RACSignal combineLatest:sigs] eventWithName:kEvtInsSimpleCarsAndProvinces]];
}

- (CKEvent *)updateSimpleCarRefid:(NSNumber *)refid byLicenseno:(NSString *)licenseno
{
    InsSimpleCar *car = [self.simpleCars objectForKey:licenseno];
    car.refid = refid;
    return [self inlineEvent:[CKEvent eventWithName:kEvtUpdateInsSimpleCar signal:[RACSignal return:car]]];
}


@end
