//
//  IllegalModel.m
//  XiaoMa
//
//  Created by jt on 15/11/24.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ViolationModel.h"
#import "UserViolationQueryOp.h"
#import "GetCityInfoByLicenseNumberOp.h"

@implementation ViolationModel

- (RACSignal *)rac_getCityInfoByLincenseNumber
{
    GetCityInfoByLicenseNumberOp * op = [[GetCityInfoByLicenseNumberOp alloc] init];
    op.req_lisenceNumber = self.licencenumber;
    return  [[op rac_postRequest] flattenMap:^RACStream *(GetCityInfoByLicenseNumberOp * rop) {
        
        self.cityInfo = op.rsp_violationCityInfo;
        /// 如果有车架号没有才取服务器接口
        self.classno = self.classno.length ? self.classno : op.rsp_carframenumber;
        self.engineno = self.engineno.length ? self.engineno : op.rsp_enginenumber;
        return [RACSignal return:rop];
    }];
}

- (RACSignal *)rac_requestUserViolation
{
    UserViolationQueryOp * op = [[UserViolationQueryOp alloc] init];
    op.licencenumber = self.licencenumber;
    op.engineno = self.engineno;
    op.classno = self.classno;
    op.cid = self.cid;
    op.city = self.cityInfo.cityCode;
    
    return [[op rac_postRequest] flattenMap:^RACStream *(UserViolationQueryOp * rop) {
        
        self.violationCount = rop.rsp_violationCount;
        self.violationTotalfen = rop.rsp_violationTotalfen;
        self.violationTotalmoney = rop.rsp_violationTotalmoney;
        self.violationArray = rop.rsp_violationArray;
        self.violationAvailableTip = rop.rsp_violationAvailableTip;
        self.queryDate = [NSDate date];
        
        /// 异步本地存一次
        CKAsyncHighQueue(^{
            
            NSString * violationKey = [NSString stringWithFormat:@"violation_%@",self.licencenumber];
            [gAppMgr.dataCache setObject:self forKey:violationKey];
        });
        
        return [RACSignal return:rop];
    }];
}

- (RACSignal *)rac_getLocalUserViolation
{
    RACSubject *signal = [RACSubject subject];
    
    CKAsyncHighQueue(^{
       
        NSString * violationKey = [NSString stringWithFormat:@"violation_%@",self.licencenumber];
        
        ViolationModel *model = [gAppMgr.dataCache objectForKey:violationKey];
        self.engineno = model.engineno;
        self.classno = model.classno;
        self.violationCount = model.violationCount;
        self.violationTotalfen = model.violationTotalfen;
        self.violationTotalmoney = model.violationTotalmoney;
        self.violationArray = model.violationArray;
        self.violationAvailableTip = model.violationAvailableTip;
        self.queryDate = model.queryDate;
        
        CKAsyncMainQueue(^{
            
            [signal sendNext:RACTuplePack(model)];
            [signal sendCompleted];
        });
    });
    
    return signal;
}




- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init])
    {
        self.licencenumber = [aDecoder decodeObjectForKey:@"licencenumber"];
        self.engineno = [aDecoder decodeObjectForKey:@"engineno"];
        self.classno = [aDecoder decodeObjectForKey:@"classno"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        self.violationCount = [aDecoder decodeIntegerForKey:@"violationCount"];
        self.violationTotalfen = [aDecoder decodeIntegerForKey:@"violationTotalfen"];
        self.violationTotalmoney = [aDecoder decodeIntegerForKey:@"violationTotalmoney"];
        self.violationArray = [aDecoder decodeObjectForKey:@"violationArray"];
        self.queryDate = [aDecoder decodeObjectForKey:@"queryDate"];
        self.violationAvailableTip = [aDecoder decodeObjectForKey:@"violationAvailableTip"];
    }
    
    return  self;
}
//编码
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    
    [aCoder encodeObject:self.licencenumber forKey:@"licencenumber"];
    [aCoder encodeObject:self.engineno forKey:@"engineno"];
    [aCoder encodeObject:self.classno forKey:@"classno"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeInteger:self.violationCount forKey:@"violationCount"];
    [aCoder encodeInteger:self.violationTotalfen forKey:@"violationTotalfen"];
    [aCoder encodeInteger:self.violationTotalmoney forKey:@"violationTotalmoney"];
    [aCoder encodeObject:self.violationArray forKey:@"violationArray"];
    [aCoder encodeObject:self.queryDate forKey:@"queryDate"];
    [aCoder encodeObject:self.violationAvailableTip forKey:@"violationAvailableTip"];
}



@end
