//
//  ShareResponeManager.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "WeiboSDK.h"
#import <TencentOpenAPI.framework/Headers/TencentOAuth.h>
#import <TencentOpenAPI.framework/Headers/QQApiInterface.h>
#import "WXApi.h"

@interface ShareResponeManager : NSObject<WXApiDelegate, WeiboSDKDelegate>

+ (instancetype)init;

@property (strong, nonatomic)void(^finishAction)(NSInteger resultCode);

@end

//微信和QQ回调函数onResp函数名相同，所以区分响应
@interface ShareResponeManagerForQQ : NSObject<QQApiInterfaceDelegate>

+ (instancetype)init;

@property (strong, nonatomic)void(^finishAction)(NSString * resultStr);

@end
