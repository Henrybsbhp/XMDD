//
//  UpdateCooperationIdlicenseInfoV2Op.h
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface UpdateCooperationIdlicenseInfoV2Op : BaseOp

///身份证地址
@property (nonatomic,strong) NSString* req_idurl;
///行驶证地址
@property (nonatomic,strong) NSString* req_licenseurl;
///最近一次保险公司名字
@property (nonatomic,strong) NSString* req_firstinscomp;
///再上一次保险公司名字
@property (nonatomic,strong) NSString* req_secinscomp;
///团员记录ID
@property (nonatomic,strong) NSNumber* req_memberid;
///是否代买交强险
@property (nonatomic) BOOL req_isbuyfroceins;
///车牌号
@property (nonatomic,strong) NSString* req_licensenumber;
///车id
@property (nonatomic,strong) NSNumber* req_carid;
///团id
@property (nonatomic,strong) NSNumber* req_groupid;

@property (nonatomic,strong)NSDictionary * couponDict;

@end
