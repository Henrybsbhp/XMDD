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

typedef NS_ENUM(NSInteger, ShareResponseType) {
    ShareResponseWechat,
    ShareResponseWeibo,
    ShareResponseQQ
};

@interface ShareResponeManager : NSObject<WXApiDelegate, WeiboSDKDelegate, QQApiInterfaceDelegate>

+ (instancetype)init;

@property (strong, nonatomic)void(^finishAction)(NSInteger resultCode, ShareResponseType responseType);

@end

//微信和QQ回调函数onResp函数名相同，所以区分响应  已解决：在onResp方法中判断resp的类型即可
//@interface ShareResponeManagerForQQ : NSObject<QQApiInterfaceDelegate>
//
//+ (instancetype)init;
//
//@property (strong, nonatomic)void(^finishAction)(NSString * resultStr, ShareResponseType responseType);
//
//@end
