//
//  GetAutomobileSeriesV2Op.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetAutomobileSeriesV2Op.h"
#import "AutoSeriesModel.h"

@implementation GetAutomobileSeriesV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/series/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_brandid forName:@"bid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * series = (NSArray *)rspObj[@"series"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in series)
        {
            AutoSeriesModel * series = [AutoSeriesModel setSeriesWithJSONResponse:dict];
            [tArray addObject:series];
        }
        self.rsp_seriesList = tArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
