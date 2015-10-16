//
//  DrivingLicenseRecord.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PictureRecord.h"
#import "NSDate+DateForText.h"

@implementation PictureRecord

- (BOOL)isEqual:(id)object
{
    PictureRecord *another = object;
    return [self.picID isEqual:another.picID];
}

+ (instancetype)pictureRecordWithJSONResponse:(NSDictionary *)rsp
{
    PictureRecord *record = [[self alloc] init];
    record.picID = rsp[@"lid"];
    record.url = rsp[@"url"];
    record.timetag = [[NSDate dateWithUTS:rsp[@"uploadtime"]] timeIntervalSince1970];
    record.plateNumber = rsp[@"licensenum"];
    return record;
}

- (BOOL)deleteable
{
    return self.plateNumber.length == 0;
}

@end
