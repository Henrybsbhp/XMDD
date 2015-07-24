//
//  HKLoginModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKLoginModel.h"
#import "AuthByPwdOp.h"
#import "AuthByVcodeOp.h"
#import "GetTokenOp.h"
#import "LogoutOp.h"
#import <SFHFKeychainUtils.h>
#import "NSString+MD5.h"

#define kNealyLoginInfoKey @"loginModel.nearlyLoginInfo"
#if XMDDENT
#define kKeychainServiceName    @"com.huika.xmdd.ent.skey"
#else
#define kKeychainServiceName    @"com.huika.xmdd.skey"
#endif
typedef enum : NSInteger {
    LoginTypePassowrd = 0,
    LoginTypeVCode
}LoginType;

@implementation HKLoginModel

- (RACSignal *)rac_loginWithAccount:(NSString *)account password:(NSString *)password
{
    AuthByPwdOp *op = [AuthByPwdOp new];
    op.skey = [self skeyFromPassword:password];
    op.req_deviceID = gAppMgr.deviceInfo.deviceID;
    return [[self rac_commonValidateTokenOp:op account:account token:nil] doNext:^(id x) {
        [gAppMgr resetWithAccount:account];
    }];
}

- (RACSignal *)rac_loginWithAccount:(NSString *)account validCode:(NSString *)vCode
{
    AuthByVcodeOp *op = [AuthByVcodeOp new];
    op.skey = [self skeyFromPassword:vCode];
    op.req_deviceID = gAppMgr.deviceInfo.deviceID;
    NSString *token = [gAppMgr.tokenPool tokenForAccount:account];
    return [[self rac_commonValidateTokenOp:op account:account token:token] doNext:^(id x) {
        [gAppMgr resetWithAccount:account];
    }];
}

+ (NSDictionary *)nearlyLoginInfo
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kNealyLoginInfoKey];
}

+ (NSString *)nearlyLoginAccount
{
    NSDictionary *dict = [self nearlyLoginInfo];
    return dict[@"account"];
}

+ (void)saveNearlyLoginInfoWithAccount:(NSString *)account type:(LoginType)type token:(NSString *)token
{
    if (!account) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNealyLoginInfoKey];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict safetySetObject:account forKey:@"account"];
    [dict safetySetObject:@(type) forKey:@"type"];
    [dict safetySetObject:token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kNealyLoginInfoKey];
}

+ (BOOL)hasPasswordForAccount:(NSString *)account
{
    if (!account)
    {
        return NO;
    }
    return [SFHFKeychainUtils getPasswordForUsername:account andServiceName:kKeychainServiceName error:nil].length > 0;
}

- (RACSignal *)rac_autoLoginWithoutNetworking
{
    NSDictionary *loginInfo = [HKLoginModel nearlyLoginInfo];
    NSString *ad = loginInfo[@"account"];
    LoginType type = [loginInfo[@"type"] integerValue];
    NSString *token = loginInfo[@"token"];
    if (ad)
    {
        RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
        return [[[RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
            
            NSString *skey = [HKLoginModel getSkeyForAccount:ad loginType:LoginTypePassowrd];
            if (!skey && type != LoginTypePassowrd) {
                skey = [HKLoginModel getSkeyForAccount:ad loginType:type];
            }
            [subscriber sendNext:skey];
        }] flattenMap:^RACStream *(NSString *skey) {
            
            if (skey.length > 0) {
                gNetworkMgr.skey = skey;
                gNetworkMgr.token = token;
                return [RACSignal return:ad];
            }
            return [RACSignal error:[NSError errorWithDomain:@"自动登录失败，用户密码缺失" code:0 userInfo:0]];
        }] deliverOn:[RACScheduler mainThreadScheduler]];
    }
    return [RACSignal error:[NSError errorWithDomain:@"自动登录失败，无用户信息" code:0 userInfo:0]];
}

+ (RACReplaySubject *)globalRetrySignal
{
    static RACReplaySubject *g_retrySignal;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_retrySignal = [RACReplaySubject replaySubjectWithCapacity:1];
        [g_retrySignal sendNext:[RACSignal return:nil]];
    });
    return g_retrySignal;
}

- (RACSignal *)rac_retryLoginFastWithOldToken:(NSString *)oldToken
{
    return [[[[[[HKLoginModel globalRetrySignal] take:1] doNext:^(id x) {
        DebugLog(@"globalRetrySignal sendNext:%@", x);
    }] flatten] catch:^RACSignal *(NSError *error) {
        //重登失败，获取新的token
        DebugLog(@"Existing token not valid. Get New One!");
        return [self rac_retryLogin];
    }]  flattenMap:^RACStream *(BaseOp *validOp) {
        //没有token，或者新旧token一致，都重新刷token。
        if (validOp.token.length == 0 || [validOp.token equalByCaseInsensitive:oldToken])
        {
            DebugLog(@"Token not valid. Get New One!");
            DebugLog(@"Old Token: [%@]",oldToken);
            DebugLog(@"Valid Token: [%@]",validOp.token);
            DebugLog(@"ValidOp is: [%@]",validOp);
            
            return [self rac_retryLogin];
        }
        
        return [RACSignal return:validOp];
    }];
}

- (RACSignal *)rac_retryLogin
{
    NSDictionary *dict = [HKLoginModel nearlyLoginInfo];
    NSString *ad = dict[@"account"];
    LoginType type = [dict[@"type"] integerValue];
    RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    RACSignal *sig = [[[RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
        
        LoginType curType = LoginTypePassowrd;
        NSString *skey = [HKLoginModel getSkeyForAccount:ad loginType:curType];
        if (!skey && type != LoginTypePassowrd) {
            skey = [HKLoginModel getSkeyForAccount:ad loginType:type];
            curType = type;
        }
        [subscriber sendNext:RACTuplePack(@(curType), skey)];
    }] flattenMap:^RACStream *(RACTuple *tuple) {
        
        LoginType type = [tuple.first integerValue];
        NSString *skey = tuple.second;
        if (!skey) {
            return [RACSignal error:[NSError errorWithDomain:@"无效的密码" code:0 userInfo:nil]];
        }
        BaseOp *op = (BaseOp *)(type == LoginTypePassowrd ? [AuthByPwdOp new] : [AuthByVcodeOp new]);
        op.skey = skey;
        return [self rac_commonValidateTokenOp:op account:ad token:nil];
    }] replay];
    [[HKLoginModel globalRetrySignal] sendNext:sig];
    return sig;
}

#pragma mark - Keychain
+ (RACSignal *)rac_getSkeyForAccount:(NSString *)ad loginType:(LoginType)type
{
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    return [RACSignal startEagerlyWithScheduler:scheduler block:^(id<RACSubscriber> subscriber) {
        
        NSString *key = [NSString stringWithFormat:@"%@_%@", kKeychainServiceName, @(type)];
        NSString *skey = [SFHFKeychainUtils getPasswordForUsername:ad andServiceName:key error:nil];
        [subscriber sendNext:skey];
        [subscriber sendCompleted];
    }];
}

+ (NSString *)getSkeyForAccount:(NSString *)ad loginType:(LoginType)type
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kKeychainServiceName, @(type)];
    return [SFHFKeychainUtils getPasswordForUsername:ad andServiceName:key error:nil];
}

+ (RACSignal *)rac_saveSkey:(NSString *)skey forAccount:(NSString *)ad loginType:(LoginType)type
{
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    return [[RACSignal startEagerlyWithScheduler:scheduler block:^(id<RACSubscriber> subscriber) {
        
        [HKLoginModel saveSkey:skey forAccount:ad loginType:type];
        [[self globalRetrySignal] sendNext:[RACSignal return:nil]];
        [subscriber sendNext:@(YES)];
        [subscriber sendCompleted];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (void)saveSkey:(NSString *)skey forAccount:(NSString *)ad loginType:(LoginType)type
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kKeychainServiceName, @(type)];
    if (!skey)
    {
        NSError *error;
        [SFHFKeychainUtils deleteItemForUsername:ad andServiceName:key error:&error];
    }
    else
    {
        [SFHFKeychainUtils storeUsername:ad andPassword:skey forServiceName:key updateExisting:YES error:nil];
    }
    [self saveNearlyLoginInfoWithAccount:ad type:type token:gNetworkMgr.token];
}

#pragma mark - Private
- (NSString *)skeyFromPassword:(NSString *)pwd
{
    return [[pwd md5] substringToIndex:10];
}

///获取token
- (RACSignal *)rac_getTokenWithAccount:(NSString *)account
{
    GetTokenOp *op = [GetTokenOp new];
    op.req_phone = account;
//    @weakify(self);
    return [[op rac_postRequest] map:^(GetTokenOp *rspOp) {
//        @strongify(self);
//        [self.tokenPool safetySetObject:rspOp.rsp_token forKey:account];
        return rspOp.rsp_token;
    }];
}

- (RACSignal *)rac_commonValidateTokenOp:(BaseOp *)validOp account:(NSString *)account token:(NSString *)token
{
    //获取token
    RACSignal *signal;
    if (token.length > 0)
    {
        signal = [RACSignal return:token];
    }
    else
    {
        signal = [self rac_getTokenWithAccount:account];
    }
    
    //验证token
    signal = [[signal flattenMap:^RACStream *(NSString *token) {
        
        validOp.token = token;
        return [validOp rac_postRequest];
    }] map:^(BaseOp *rstOp) {
        
        gNetworkMgr.token = rstOp.token;
        gNetworkMgr.skey = rstOp.skey;
        gNetworkMgr.bindingMobile = account;
        LoginType type = [rstOp isKindOfClass:[AuthByPwdOp class]] ? LoginTypePassowrd : LoginTypeVCode;
        [HKLoginModel saveSkey:rstOp.skey forAccount:account loginType:type];
        return rstOp;
     }];
    
//    @weakify(self);
//    signal = [signal doError:^(NSError *error) {
//        
//        @strongify(self);
//        //验证失败的时候需要从token池中移除掉当前token
//        [self.tokenPool removeObjectForKey:account];
//    }];
    
    return [signal deliverOn:[RACScheduler mainThreadScheduler]];

}


+ (void)logout
{
    LogoutOp *op = [LogoutOp operation];
    [[op rac_postRequest] subscribeNext:^(id x) {
        DebugLog(@"Logout success!");
    }];
    gNetworkMgr.token = nil;
    gNetworkMgr.skey = nil;
    [gAppMgr resetWithAccount:nil];
//    gApplicationInfo.loginFlag = LoginStatusNone;
    [HKLoginModel cleanPwdForAccount:gNetworkMgr.bindingMobile];
}

+ (void)cleanPwdForAccount:(NSString *)ad
{
    NSDictionary *loginInfo = [HKLoginModel nearlyLoginInfo];
    NSString *account = loginInfo[@"account"];
    LoginType type = [loginInfo[@"type"] integerValue];
    
    NSString *serverId = [NSString stringWithFormat:@"%@_%@", kKeychainServiceName, @(type)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        NSError * error;
        [SFHFKeychainUtils deleteItemForUsername:account andServiceName:serverId error:&error];
    });
}

@end
