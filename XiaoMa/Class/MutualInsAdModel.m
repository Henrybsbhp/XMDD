//
//  MutualInsAdModel.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsAdModel.h"
#import "GetSystemPromotionOp.h"
#import "HKAdvertisement.h"
#import "CKMethods.h"

@interface MutualInsAdModel()

@property (strong, nonatomic) SDWebImageManager *mgr;

@end


@implementation MutualInsAdModel

-(void)dealloc
{
    
}

- (void)getSystemPromotion
{
    @weakify(self)
    GetSystemPromotionOp *op = [GetSystemPromotionOp operation];
    
    op.type = AdvertisementMutualInsHome;
    
    [[op rac_postRequest]subscribeNext:^(GetSystemPromotionOp *op) {
        
        @strongify(self)
        
        self.haveRetry = NO;
        
        self.imgCount = op.rsp_advertisementArray.count;
        
        HKAdvertisement *adModel = op.rsp_advertisementArray.lastObject;
        self.adLink = adModel.adLink;
        
        [self getImgArrByURLArr:op.rsp_advertisementArray andIndex:0];
        
    }error:^(NSError *error) {
        
        @strongify(self)
        
        if (self.haveRetry)
        {
            self.imgArr = nil;
            self.imgCount = 0;
        }
        else
        {
            self.haveRetry = YES;
            
            [self getSystemPromotion];
        }
        
    }];
}

-(void)getImgArrByURLArr:(NSArray *)advertisementArray andIndex:(NSInteger)index
{
    @weakify(self)
    
    __block NSInteger i = index + 1;
    
    if (index == advertisementArray.count)
    {
        return;
    }
    else
    {
        HKAdvertisement *adModel = [advertisementArray safetyObjectAtIndex:index];
        
        [[self rac_getImageByUrl:adModel.adPic withType:ImageURLTypeOrigin]subscribeNext:^(UIImage *img) {
            
            @strongify(self)
            
            if (img)
            {
                img.customTag = index;
                [self.imgArr addObject:img];
                self.imgStr = [self.imgArr componentsJoinedByString:@","];
                
                
                [self getImgArrByURLArr:advertisementArray andIndex:i];
            }
            
        } error:^(NSError *error) {
            
            @strongify(self)
            
            @weakify(self)
            [self retryFailByUrlStr:adModel.adPic completionHandler:^(UIImage *image) {
                
                @strongify(self)
                
                UIImage *img = image ? image : [UIImage imageNamed:@"cm_defpic_fail"];
                
                img.customTag = index;
                [self.imgArr addObject:img];
                self.imgStr = [self.imgArr componentsJoinedByString:@","];
            }];
            
        }];
    }
}

- (RACSignal *)rac_getImageByUrl:(NSString *)strurl withType:(ImageURLType)type
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *realStrUrl = [gMediaMgr urlWith:strurl imageType:type];
        NSURL *url = strurl ? [NSURL URLWithString:realStrUrl] : nil;
        [self.mgr downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                [subscriber sendNext:image];
            }
            else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

-(void)retryFailByUrlStr:(NSString *)urlStr completionHandler:(void (^) (UIImage *image))completion
{
    [self.mgr downloadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        completion(image);
        
    }];
}


#pragma mark - LazyLoad

-(SDWebImageManager *)mgr
{
    if (!_mgr)
    {
        _mgr = [SDWebImageManager sharedManager];
    }
    return _mgr;
}

-(NSMutableArray *)imgArr
{
    if (!_imgArr)
    {
        _imgArr = [[NSMutableArray alloc]init];
    }
    return _imgArr;
}

@end
