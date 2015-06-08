//
//  GetUserBaseInfoOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/5.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserBaseInfoOp.h"
#import "XiaoMa.h"

@interface GetUserBaseInfoOp ()
@property (nonatomic, strong) NSString *userID;
@end
@implementation GetUserBaseInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/basicinfo/get";
    self.userID = gAppMgr.myUser.userID;
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (id)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_vcc = [dict integerParamForName:@"vcc"];
    self.rsp_freewashes = [dict integerParamForName:@"freewashes"];
    self.rsp_bankcredit = [dict integerParamForName:@"bankcredit"];
    self.rsp_nickName = [dict stringParamForName:@"nickname"];
    self.rsp_phone = [dict stringParamForName:@"phone"];
    self.rsp_avatar = [dict stringParamForName:@"avatar"];
    self.rsp_sex = [dict integerParamForName:@"sex"];
    self.rsp_birthday = [NSDate dateWithD8Text:[dict stringParamForName:@"birthday"]];
    
    return self;
}

+ (RACSignal *)rac_fetchUserBaseInfo
{
    GetUserBaseInfoOp *op = [[GetUserBaseInfoOp allCurrentClassOpsInClient:gNetworkMgr.apiManager]
     firstObjectByFilteringOperator:^BOOL(GetUserBaseInfoOp *op) {
         return [op.userID equalByCaseInsensitive:gAppMgr.myUser.userID];
    }];
    RACSignal *sig = op.rac_curSignal;
    if (!sig) {
        op = [GetUserBaseInfoOp new];
        sig = [op rac_postRequest];
    }
    sig = [sig doNext:^(GetUserBaseInfoOp *op) {
        gAppMgr.myUser.userName = op.rsp_nickName;
        gAppMgr.myUser.phoneNumber = op.rsp_phone;
        gAppMgr.myUser.avatarUrl = op.rsp_avatar;
//        gAppMgr.myUser.validCarwashArray = op.rsp_vcc;
        gAppMgr.myUser.abcCarwashesCount = op.rsp_freewashes;
        gAppMgr.myUser.abcIntegral = op.rsp_bankcredit;
        gAppMgr.myUser.sex = op.rsp_sex;
        gAppMgr.myUser.birthday = op.rsp_birthday;
    }];
    return sig;
}


@end
