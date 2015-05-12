//
//  MultiMediaManager.m
//  HappyTrain
//
//  Created by jt on 14-11-25.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "MultiMediaManager.h"
#import "DownloadOp.h"

#define kPicCacheName    @"MultiMediaManager_PicCache"

@interface MultiMediaManager()


@end

@implementation MultiMediaManager

static MultiMediaManager *g_mediaManager;

- (instancetype)initWithPicCache:(TMCache *)cache
{
    self = [super init];
    if (self) {
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
    
    if (cacheKey.length == 0)
    {
        return [RACSignal return:[UIImage imageNamed:picName]];
    }
    
    //
    RACScheduler *sch = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    RACSignal *signal = [[RACSignal startEagerlyWithScheduler:sch block:^(id<RACSubscriber> subscriber) {
        

        UIImage *img = [self.picCache imageForKey:cacheKey];
        [subscriber sendNext:img];
        [subscriber sendCompleted];
    }] replay];

    signal = [signal flattenMap:^RACStream *(UIImage *img) {
    
        RACSignal * defaultSignal ;
        
        if (img)
        {
            return [RACSignal return:img];
        }
        else
        {
            /// @fq 
            UIImage * image = [UIImage imageNamed:picName];
            defaultSignal = [RACSignal return:image];
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
            return defaultSignal;
        }
        
        return [defaultSignal merge:downloadOpSig];
    }];
    
    return [signal deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
