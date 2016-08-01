//
//  AutoBrand+Extension.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AutoBrand+Extension.h"

@implementation AutoBrand (Extension)

+ (AutoBrand *)fetchAutoBrandByID:(NSNumber *)bid
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"AutoBrand"];
    req.predicate = [NSPredicate predicateWithFormat:@"brandid = %@", bid];
    return [gAppMgr.defDataMgr fetchFirstObjectWithFetchRequest:req];
}

- (void)resetWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return;
    }
    self.brandid = rsp[@"bid"];
    self.name = rsp[@"name"];
    self.tag = rsp[@"tag"];
    self.logo = rsp[@"logo"];
    self.timetag = rsp[@"timetag"];
}

@end
