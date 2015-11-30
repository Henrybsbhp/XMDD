//
//  ShareResponeManager.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ShareResponeManager.h"

@implementation ShareResponeManager

+ (instancetype)init
{
    static ShareResponeManager * _shareManager = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _shareManager = [[ShareResponeManager alloc] init];
    });
    return _shareManager;
}

#pragma mark - WeiXin Delegate

- (void)onResp:(BaseResp *)resp
{
    if(self.finishAction) {
        self.finishAction(resp.errCode);
    }
    NSString * msg = @"";
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess)
        {
            msg = @"分享成功";
            [gToast showSuccess:msg];
        }
        else if(resp.errCode == WXErrCodeCommon)
        {
            msg = @"分享失败，请重试";
            [gToast showSuccess:msg];
        }
        else if(resp.errCode == WXErrCodeUserCancel)
        {
            msg = @"您取消了分享";
            [gToast showError:msg];
            return;
        }
        else if(resp.errCode == WXErrCodeSentFail)
        {
            msg = @"分享失败，请重试";
            [gToast showError:msg];
        }
        else if(resp.errCode == WXErrCodeAuthDeny)
        {
            msg = @"授权失败，请重试";
            [gToast showError:msg];
        }
        else if(resp.errCode == WXErrCodeUnsupport)
        {
            msg = @"内容微信不支持";
            [gToast showError:msg];
        }
    }
}

#pragma mark - Weibo Delegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if(self.finishAction) {
        self.finishAction(response.statusCode);
    }
    NSString * msg = @"";
    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
    {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess)
        {
            msg = @"分享成功";
            [gToast showSuccess:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel)
        {
            msg = @"支持一下，请不要取消";
            [gToast showError:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeSentFail)
        {
            msg = @"分享失败，请重试";
            [gToast showError:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeAuthDeny)
        {
            msg = @"授权失败，请重试";
            [gToast showError:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall)
        {
            //            msg = @"支持一下，不要取消";
            //            [gToast showError:msg duration:1.0f];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUnsupport)
        {
            msg = @"内容微博不支持";
            [gToast showError:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUnknown)
        {
            msg = @"分享失败，请重试";
            [gToast showError:msg];
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    //    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    //    {
    //        NSString *title = @"发送结果";
    //        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
    //                                                        message:message
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"确定"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }
    //    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    //    {
    //        NSString *title = @"认证结果";
    //        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
    //                                                        message:message
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"确定"
    //                                              otherButtonTitles:nil];
    //
    //        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
    //
    //        [alert show];
    //    }
}

@end


@implementation ShareResponeManagerForQQ

+ (instancetype)init
{
    static ShareResponeManagerForQQ * _shareManager = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _shareManager = [[ShareResponeManagerForQQ alloc] init];
    });
    return _shareManager;
}

- (void)onReq:(QQBaseReq *)req
{
    
}

- (void)onResp:(QQBaseResp *)resp
{
    if(self.finishAction) {
        self.finishAction(resp.result);
    }
    NSString * msg = @"";
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if ([resp.result isEqualToString:@"-4"]) {
            msg = @"用户取消";
            [gToast showError:msg];
        }
        else if ([resp.result isEqualToString:@"0"]) {
            msg = @"分享成功";
            [gToast showSuccess:msg];
        }
        else {
            msg = @"分享失败";
            [gToast showError:msg];
        }
    }
}

-(void)isOnlineResponse:(NSDictionary *)response
{
    
}

@end
