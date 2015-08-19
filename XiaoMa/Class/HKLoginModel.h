//
//  HKLoginModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;

@interface HKLoginModel : NSObject
//@property (nonatomic, strong) NSMutableDictionary *tokenPool;

///密码登录(sendNext:(ValidateToken *))
- (RACSignal *)rac_loginWithAccount:(NSString *)account password:(NSString *)password;
///短信验证码登录(sendNext:(ValidateToken *))
- (RACSignal *)rac_loginWithAccount:(NSString *)account validCode:(NSString *)vCode;
///自动登录(成功：发送登录的用户账号，失败：
- (RACSignal *)rac_autoLoginWithoutNetworking;
///重登(setNext:ValidateToken *)
- (RACSignal *)rac_retryLoginFastWithOldToken:(NSString *)token;
- (RACSignal *)rac_retryLogin;

+ (void)logout;
+ (void)logoutWithoutNetworking;
+ (void)cleanPwdForAccount:(NSString *)account;

@end
