//
//  AutoSeriesModel.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoSeriesModel : NSObject

@property (nonatomic, strong) NSNumber * seriesid;
@property (nonatomic, strong) NSString * seriesname;

+ (instancetype)setSeriesWithJSONResponse:(NSDictionary *)rsp;

@end

@interface AutoDetailModel : NSObject

@property (nonatomic, strong) NSNumber * modelid;
@property (nonatomic, strong) NSString * modelname;

+ (instancetype)setModelWithJSONResponse:(NSDictionary *)rsp;

@end

@interface AutoBrandModel : NSObject

@property (nonatomic, strong) NSNumber * brandid;
@property (nonatomic, strong) NSString * brandname;

@end