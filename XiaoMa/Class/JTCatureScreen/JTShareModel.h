//
//  JTShareModel.h
//  XiaoNiuShared
//
//  Created by jt on 14-7-30.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"


#import "WeiboSDK.h"


#define shareContent @"test"
#define shareImage  @"AppIcon"
#define shareThumbImage @"AppIcon"


@interface JTShareModel : NSObject<WXApiDelegate,WeiboSDKDelegate>

+ (BOOL)isWeiboAppInstalled;

+ (BOOL)isWXAppInstalled;

- (NSString *)WXAppUrlStr;

- (void)shareToWeiboWithTitle:(NSString *)title
               andDescription:(NSString *)desc
                     andImage:(UIImage *)img
                       andUrl:(NSString *)url;

- (void)shareToWeChatSessionWithTitle:(NSString *)title
                       andDescription:(NSString *)des
                             andImage:(UIImage *)img
                               andUrl:(NSString *)url;

- (void)shareToWeChatTimelineWithTitle:(NSString *)title
                        andDescription:(NSString *)desc
                              andImage:(UIImage *)img
                                andUrl:(NSString *)url;


//- (RACSignal *)rac_shareToWeibo;
//
//- (RACSignal *)rac_shareToWeChatSession;
//
//- (RACSignal *)rac_shareToWeChatTimeline;

@end
