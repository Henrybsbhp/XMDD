//
//  JTShareModel.m
//  XiaoNiuShared
//
//  Created by jt on 14-7-30.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTShareModel.h"
#import "NotifyShareAppOp.h"
#import <RACSignal.h>

@implementation JTShareModel

+ (BOOL)isWeiboAppInstalled
{
    return [WeiboSDK isWeiboAppInstalled];
}

+ (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

- (NSString *)WXAppUrlStr
{
    return [WXApi getWXAppInstallUrl];
}

- (void)shareToWeChatSessionWithTitle:(NSString *)title
                       andDescription:(NSString *)desc
                             andImage:(UIImage *)img
                               andUrl:(NSString *)url
{
    
    [self shareToWeChat:WXSceneSession withTitle:title
         andDescription:desc andImage:img andUrl:url];
}

- (void)shareToWeChatTimelineWithTitle:(NSString *)title
                        andDescription:(NSString *)desc
                              andImage:(UIImage *)img
                                andUrl:(NSString *)url
{
    [self shareToWeChat:WXSceneTimeline withTitle:title
         andDescription:desc andImage:img andUrl:url];
}

- (void)shareToWeiboWithTitle:(NSString *)title
               andDescription:(NSString *)desc
                     andImage:(UIImage *)img
                       andUrl:(NSString *)url
{
    [self shareWeiboWithTitle:title andDescription:desc
                     andImage:img andUrl:url];
}


- (void)shareToWeChat:(NSInteger)scene
            withTitle:(NSString *)title
       andDescription:(NSString *)desc
             andImage:(UIImage *)img
               andUrl:(NSString *)url
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:img];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = (int)scene;
    
    [WXApi sendReq:req];
}

- (void)shareWeiboWithTitle:(NSString *)title andDescription:(NSString *)desc
                   andImage:(UIImage *)img andUrl:(NSString *)url
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImagePNGRepresentation(img);
    message.imageObject = image;
    message.text = [NSString stringWithFormat:@"%@ %@",@"随叫随到，好东西，只和你分享! ",url];
//    WBWebpageObject *webpage = [WBWebpageObject object];
//    webpage.objectID = @"jiao_weibo_share";
//    webpage.title = title;
//    webpage.description = desc;
//    webpage.thumbnailData = UIImagePNGRepresentation(img);
//    webpage.webpageUrl = @"http://t.cn/RPMcJCg";
//    message.mediaObject = webpage;
    
    WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}


#pragma mark - WeChat Delegate
- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    NSString * msg = @"";
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess)
        {
            msg = @"分享成功";
            [self notifyFenxiangyy];
            [SVProgressHUD showSuccessWithStatus:msg];
        }
        else if(resp.errCode == WXErrCodeCommon)
        {
            msg = @"分享失败，请重试";
            [SVProgressHUD showSuccessWithStatus:msg];
        }
        else if(resp.errCode == WXErrCodeUserCancel)
        {
            // 用户取消
            return;
        }
        else if(resp.errCode == WXErrCodeSentFail)
        {
            msg = @"分享失败，请重试";
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else if(resp.errCode == WXErrCodeAuthDeny)
        {
            msg = @"授权失败，请重试";
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else if(resp.errCode == WXErrCodeUnsupport)
        {
            msg = @"内容微信不支持";
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }
}

#pragma mark - Weibo Delegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSString * msg = @"";
    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
    {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess)
        {
            msg = @"分享成功";
            [self notifyFenxiangyy];
            [SVProgressHUD showSuccessWithStatus:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel)
        {
            msg = @"支持一下，请不要取消";
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeSentFail)
        {
            msg = @"分享失败，请重试";
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeAuthDeny)
        {
            msg = @"授权失败，请重试";
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall)
        {
//            msg = @"支持一下，不要取消";
//            [SVProgressHUD showErrorWithStatus:msg duration:1.0f];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUnsupport)
        {
            msg = @"内容微博不支持";
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUnknown)
        {
            msg = @"分享失败，请重试";
            [SVProgressHUD showErrorWithStatus:msg];
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

/// 分享应用通知服务器
- (void)notifyFenxiangyy
{
    if (gNetworkMgr.skey.length > 0)
    {
        NotifyShareAppOp * op = [[NotifyShareAppOp alloc] init];
        [[op rac_postRequest] subscribeNext:^(id x) {
         
            DebugLog(@"notifyFenxiangyy success");
        }];
    }
}
@end
