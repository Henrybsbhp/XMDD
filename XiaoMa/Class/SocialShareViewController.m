//
//  SocialShareViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SocialShareViewController.h"

#import <TencentOpenAPI.framework/Headers/QQApiInterface.h>
#import <TencentOpenAPI.framework/Headers/QQApiInterfaceObject.h>

typedef void(^FinishBlock)(void);

@interface SocialShareViewController ()

@property (nonatomic,weak)FinishBlock block;

@end

@implementation SocialShareViewController

- (instancetype)init
{
    self  = [super init];
    if (self)
    {
        _rac_dismissSignal = [RACSubject subject];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[_wechatBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self shareWechat];
        if (self.finishAction)
        {
            self.finishAction();
        }
    }];
    
    [[_timelineBrn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self shareTimeline];
        if (self.finishAction)
        {
            self.finishAction();
        }
    }];
    
    [[_weiboBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self shareWeibo];
        if (self.finishAction)
        {
            self.finishAction();
        }
    }];
    
    [[_qqBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self shareQQ];
        if (self.finishAction)
        {
            self.finishAction();
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"SocialShareViewController dealloc ~~~");
}


- (void)shareWechat
{
    [self shareToWeChat:WXSceneSession withTitle:self.tt
         andDescription:self.subtitle andImage:self.image andUrl:self.urlStr];
}

- (void)shareTimeline
{
    [self shareToWeChat:WXSceneTimeline withTitle:self.tt
         andDescription:self.subtitle andImage:self.image andUrl:self.urlStr];
}

- (void)shareWeibo
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImagePNGRepresentation(self.webimage ? self.webimage : self.image);
    message.imageObject = image;
    message.text = [NSString stringWithFormat:@"%@ \n %@ \n %@ ",self.tt,self.subtitle,self.urlStr];
    
    WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

- (void)shareQQ
{
    QQApiNewsObject *newsObj;
    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.urlStr] title:self.tt description:self.subtitle previewImageData:UIImageJPEGRepresentation(self.image, 1.0)];

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
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

#pragma mark - WeChat Delegate
- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    NSString * msg = @"";
    [_rac_dismissSignal sendNext:@"dismiss"];
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
            // 用户取消
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



#pragma mark - QQ
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手机QQ" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"分享失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}


@end
