//
//  IllegalModel.m
//  XiaoMa
//
//  Created by jt on 15/11/24.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ViolationModel.h"
#import "UserViolationQueryOp.h"

@implementation ViolationModel

- (RACSignal *)rac_requestUserViolation
{
    UserViolationQueryOp * op = [[UserViolationQueryOp alloc] init];
    op.city = self.cityInfo.cityCode;
    op.licencenumber = self.licencenumber;
    op.engineno = self.engineno;
    op.classno = self.classno;
    op.cid = self.cid;
    
    return [[op rac_postRequest] flattenMap:^RACStream *(UserViolationQueryOp * rop) {
        
        self.violationCount = rop.rsp_violationCount;
        self.violationTotalfen = rop.rsp_violationTotalfen;
        self.violationTotalmoney = rop.rsp_violationTotalmoney;
        self.violationArray = rop.rsp_violationArray;
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
        self.engineno = model.engineno ? model.engineno : self.engineno;
        self.classno = model.classno ? model.classno : self.classno;
        self.violationCount = model.violationCount;
        self.violationTotalfen = model.violationTotalfen;
        self.violationTotalmoney = model.violationTotalmoney;
        self.violationArray = model.violationArray;
        self.cityInfo = model.cityInfo;
        self.queryDate = model.queryDate;
        
        CKAsyncMainQueue(^{
            
            [signal sendNext:RACTuplePack(model)];
            [signal sendCompleted];
        });
    });
    
    return signal;
}




-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init])
    {
        self.licencenumber = [aDecoder decodeObjectForKey:@"title"];
        self.engineno = [aDecoder decodeObjectForKey:@"engineno"];
        self.classno = [aDecoder decodeObjectForKey:@"classno"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        
        self.violationCount = [aDecoder decodeIntegerForKey:@"violationCount"];
        self.violationTotalfen = [aDecoder decodeIntegerForKey:@"violationTotalfen"];
        self.violationTotalmoney = [aDecoder decodeIntegerForKey:@"violationTotalmoney"];
        self.violationArray = [aDecoder decodeObjectForKey:@"violationArray"];
        self.cityInfo = [aDecoder decodeObjectForKey:@"cityInfo"];
        self.queryDate = [aDecoder decodeObjectForKey:@"queryDate"];
    }
    
    return  self;
}
//编码
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.licencenumber forKey:@"licencenumber"];
    [aCoder encodeObject:self.engineno forKey:@"engineno"];
    [aCoder encodeObject:self.classno forKey:@"classno"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeInteger:self.violationCount forKey:@"violationCount"];
    [aCoder encodeInteger:self.violationTotalfen forKey:@"violationTotalfen"];
    [aCoder encodeInteger:self.violationTotalmoney forKey:@"violationTotalmoney"];
    [aCoder encodeObject:self.violationArray forKey:@"violationArray"];
    [aCoder encodeObject:self.cityInfo forKey:@"cityInfo"];
    [aCoder encodeObject:self.queryDate forKey:@"queryDate"];
}



@end
