//
//  AutoSeriesModel.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "AutoSeriesModel.h"

@implementation AutoSeriesModel

+ (instancetype)setSeriesWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    AutoSeriesModel * series= [[AutoSeriesModel alloc] init];
    series.seriesid = rsp[@"sid"];
    series.seriesname = rsp[@"name"];
    return series;
}

@end

@implementation AutoDetailModel

+ (instancetype)setModelWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    AutoDetailModel * model= [[AutoDetailModel alloc] init];
    model.modelid = rsp[@"mid"];
    model.modelname = rsp[@"name"];
    model.price = [rsp floatParamForName:@"price"];
    return model;
}

@end

@implementation AutoBrandModel

@end
