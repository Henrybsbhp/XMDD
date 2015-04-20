//
//  MultiMediaManager.m
//  HappyTrain
//
//  Created by jt on 14-11-25.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "MultiMediaManager.h"
#import "DownloadOp.h"
#import "GetChongzhiOp.h"
#import "GetCaptchaOp.h"
#import "LoginModel.h"
#import "GetTokenOp.h"

#define kPicCacheName    @"MultiMediaManager_PicCache"

@interface MultiMediaManager()


@end

@implementation MultiMediaManager

static MultiMediaManager *g_mediaManager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        g_mediaManager = [[MultiMediaManager alloc] init];
    });
    return g_mediaManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        TMCache *cache = [[TMCache alloc] initWithName:kPicCacheName];
        cache.diskCache.byteLimit = 200 * 1024 * 1024; // 200M
        cache.diskCache.ageLimit = 24 * 60 * 60 * 2;// 两天
        _picCache = cache;
    }
    return self;
}

/// 首先去缓存中查找，如果没有找到，就用DefaultPic替代，同时根据URL去网络下载，如果没有下载到，不再返回新的next。
- (RACSignal *)rac_getPictureForUrl:(NSString *)urlKey withDefaultPic:(NSString *)picName;
{
    /// tmcache url长度超过239，导致存取失败
    NSString * cacheKey = urlKey;
    if (cacheKey.length > 239)
    {
        cacheKey = [cacheKey substringFromIndex:urlKey.length - 239];
    }
    
    //
    RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    RACSignal *signal = [RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
        

        UIImage *img = [self.picCache imageForKey:cacheKey];
        [subscriber sendNext:img];
        [subscriber sendCompleted];
    }];
    
    signal = [signal flattenMap:^RACStream *(UIImage *img) {
    
        RACSignal * cacheSignal ;
        
        if (img)
        {
            return [RACSignal return:img];
        }
        else
        {
            cacheSignal = [RACSignal return:[UIImage imageNamed:picName]];
        }
        
        RACSignal * downloadOpSig = [DownloadOp firstDownloadOpInClientForReqURI:urlKey].rac_curSignal;
        if (!downloadOpSig)
        {
            DownloadOp * op = [DownloadOp operation];
            op.req_uri = urlKey;
            downloadOpSig = [op rac_getRequest];
        }
        
        downloadOpSig = [[downloadOpSig map:^id(DownloadOp *op) {
            
            UIImage *img = nil;
            if (op.rsp_data)
            {
                img = [UIImage imageWithData:op.rsp_data];
                [self.picCache setImage:img forKey:cacheKey];
                
            }
            return img;
            
        }] catch:^RACSignal *(NSError *error) {
            
            return [RACSignal empty];
        }];
        
        if (!downloadOpSig)
        {
            return cacheSignal;
        }
        
        return [cacheSignal merge:downloadOpSig];
    }];
    
    return [signal deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)rac_gainCaptchaImage:(NSString *)url
{
    DownloadOp * op = [DownloadOp operation];
    op.req_uri = url;
    RACSignal *signal = [op rac_getRequest];
    signal = [[signal map:^id(DownloadOp * op) {
        
        UIImage *img = nil;
        if (op.rsp_data)
        {
            img = [UIImage imageWithData:op.rsp_data];
            return img;
        }
        else
        {
            return [NSError errorWithDomain:@"下载图片没数据？？？" code:9996 userInfo:nil];
        }
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    return signal;
}

- (RACSignal *)rac_gainCaptcha:(NSString *)account
{
    GetCaptchaOp * getCaptchaOp = [GetCaptchaOp operation];
    
    if (!account.length)
    {
        NSAssert(NO, @"rac_gainCaptcha' account is nil");
    }
        
    
    RACSignal *signal;
    if (gNetworkMgr.token)
    {
        signal = [RACSignal return:gNetworkMgr.token];
    }
    else
    {
        LoginModel * model = [[LoginModel alloc] init];
        signal = [[model rac_getTokenWithAccount:account] map:^id(GetTokenOp *rstOp) {
            
            gNetworkMgr.token = rstOp.token;
            return rstOp.token;
        }];
    }
    
    signal = [[[signal flattenMap:^RACStream *(NSString *token) {
        
        getCaptchaOp.token = token;
        return [getCaptchaOp rac_postRequest];
    }] flattenMap:^RACStream *(GetCaptchaOp * op) {
        
        if (op.rsp_Code == 0 && op.rsp_captchaUrl.length)
        {
            NSString * url = [NSString stringWithFormat:@"%@?uri=%@",kAPIFileServerURLString,op.rsp_captchaUrl];
            return [self rac_gainCaptchaImage:url];
        }
        else
        {
            return [RACSignal error:[NSError errorWithDomain:@"获取验证码接口失败" code:9998 userInfo:nil]];
        }
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    
    return signal;
}



/// 优惠券为了记住captcha Url而写的方法
- (RACSignal *)rac_gainCaptchaImageAndUrl:(NSString *)url
{
    DownloadOp * op = [DownloadOp operation];
    op.req_uri = url;
    RACSignal *signal = [op rac_getRequest];
    signal = [[signal map:^id(DownloadOp * op) {
        
        UIImage *img = nil;
        if (op.rsp_data)
        {
            img = [UIImage imageWithData:op.rsp_data];
            NSDictionary * dict = @{@"url":url,@"captcha":img};
            return dict;
        }
        else
        {
            return [NSError errorWithDomain:@"下载图片没数据？？？" code:9996 userInfo:nil];
        }
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    return signal;
}


- (RACSignal *)rac_gainCaptchaAndUrl:(NSString *)account
{
    GetCaptchaOp * getCaptchaOp = [GetCaptchaOp operation];
    
    if (!account.length)
    {
        NSAssert(NO, @"rac_gainCaptcha' account is nil");
    }
    
    
    RACSignal *signal;
    if (gNetworkMgr.token)
    {
        signal = [RACSignal return:gNetworkMgr.token];
    }
    else
    {
        LoginModel * model = [[LoginModel alloc] init];
        signal = [[model rac_getTokenWithAccount:account] map:^id(GetTokenOp *rstOp) {
            
            gNetworkMgr.token = rstOp.token;
            return rstOp.token;
        }];
    }
    
    signal = [[[signal flattenMap:^RACStream *(NSString *token) {
        
        getCaptchaOp.token = token;
        return [getCaptchaOp rac_postRequest];
    }] flattenMap:^RACStream *(GetCaptchaOp * op) {
        
        if (op.rsp_Code == 0 && op.rsp_captchaUrl.length)
        {
            NSString * url = [NSString stringWithFormat:@"%@?uri=%@",kAPIFileServerURLString,op.rsp_captchaUrl];
            return [self rac_gainCaptchaImageAndUrl:url];
        }
        else
        {
            return [RACSignal error:[NSError errorWithDomain:@"获取验证码接口失败" code:9998 userInfo:nil]];
        }
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    
    return signal;
}



- (RACSignal *)rac_getAreaFile:(NSString *)url
{
    NSString * url1 = [NSString stringWithFormat:@"%@?uri=%@",kAPIFileServerURLString,url];
    DownloadOp * op = [DownloadOp operation];
    op.req_uri = url1;
    RACSignal *signal = [op rac_getRequest];
    signal = [[signal map:^id(DownloadOp * op) {
        
        if (op.rsp_data)
        {
            return op.rsp_data;
        }
        else
        {
            return [NSError errorWithDomain:@"下载文件没数据？？？" code:9996 userInfo:nil];
        }
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    return signal;
}
@end
