//
//  HKLocationPicker.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKLocationDataModel : NSObject

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

@interface HKAreaInfoModel : NSObject <NSCoding>

@property (nonatomic) NSInteger infoId;
@property (nonatomic, copy) NSString *infoName;
@property (nonatomic, copy) NSString *infoCode;
@property (nonatomic, copy) NSString *flag;

+ (instancetype)areaWithJSONResponse:(NSDictionary *)rsp;

@end
