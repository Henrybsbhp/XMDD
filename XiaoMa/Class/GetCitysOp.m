//
//  GetCitysOp.m
//  XiaoMa
//
//  Created by jt on 15/12/1.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetCitysOp.h"

@implementation GetCitysOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/citys/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.timetag forName:@"timetag"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}



@end
