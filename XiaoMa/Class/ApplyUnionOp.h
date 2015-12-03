//
//  ApplyUnionOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplyUnionOp : BaseOp

@property (nonatomic, copy)NSString * req_phone;
@property (nonatomic, copy)NSString * req_name;
@property (nonatomic, copy)NSString * req_province;
@property (nonatomic, copy)NSString * req_city;
@property (nonatomic, copy)NSString * req_district;

@property (nonatomic, copy)NSString * rsp_tip;

@end
