//
//  GetPicHistoryOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetPicHistoryOp.h"

@implementation GetPicHistoryOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/pichis/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.req_picType) forName:@"type"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSArray *array = dict[@"urls"];
    NSMutableArray *recordList = [NSMutableArray array];
    for (NSDictionary *recordInfo in array) {
        PictureRecord *record = [PictureRecord pictureRecordWithJSONResponse:recordInfo];
        [recordList addObject:record];
    }
    self.rsp_records = recordList;
    return self;
}

@end
