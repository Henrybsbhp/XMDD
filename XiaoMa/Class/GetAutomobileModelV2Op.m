//
//  GetAutomobileModelV2Op.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetAutomobileModelV2Op.h"
#import "AutoSeriesModel.h"

@implementation GetAutomobileModelV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/model/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_seriesid forName:@"sid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * models = (NSArray *)rspObj[@"models"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in models)
        {
            AutoDetailModel * model = [AutoDetailModel setModelWithJSONResponse:dict];
            [tArray addObject:model];
        }
        self.rsp_modelList = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
