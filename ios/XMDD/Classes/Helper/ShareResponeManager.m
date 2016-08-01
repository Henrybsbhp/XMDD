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

#pragma mark - WeiXin And QQ Delegate

- (void)onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if(self.finishAction) {
            self.finishAction(resp.errCode, ShareResponseWechat);
            self.finishAction = nil;
        }
        
        //微信分享的回调结果
//        NSString * msg = @"";
//        if (resp.errCode == WXSuccess)
//        {
//            msg = @"分享成功";
//            [gToast showSuccess:msg];
//        }
    }
    
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        QQBaseResp * qqResp = (QQBaseResp *)resp;
        
        if(self.finishAction) {
            self.finishAction([qqResp.result integerValue], ShareResponseQQ);
            self.finishAction = nil;
        }
        
        //QQ分享的回调结果
//        NSString * msg = @"";
//        if ([qqResp.result isEqualToString:@"0"]) {
//            msg = @"分享成功";
//            [gToast showSuccess:msg];
//        }
    }
}

- (void)onReq:(QQBaseReq *)req
{
    
}

-(void)isOnlineResponse:(NSDictionary *)response
{
    
}

#pragma mark - Weibo Delegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if(self.finishAction) {
        self.finishAction(response.statusCode, ShareResponseWeibo);
        self.finishAction = nil;
    }
    //微博分享的回调结果
//    NSString * msg = @"";
//    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
//    {
//        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess)
//        {
//            msg = @"分享成功";
//            [gToast showSuccess:msg];
//        }
//    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

@end
