//
//  NewbieGuideManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GuideStore.h"
#import "GetNewbieInfoOp.h"

@interface GuideStore ()

@end

@implementation GuideStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.newbieInfo = nil;
    self.shouldShowNewbieGuideAlert = NO;
    self.shouldShowNewbieGuideDot = NO;
    
    if (user) {
        self.shouldDisablePopupAd = YES;
        //重新检测新手引导
        [[self checkNewbieGuide] send];
    }
    else {
        self.shouldDisablePopupAd = NO;
        //触发新手引导发生改变
        [self triggerEvent:[[RACSignal return:nil] eventWithName:kDomainNewbiewGuide]];
    }
}

- (CKEvent *)checkNewbieGuide
{
    RACSignal *signal;
    //如果以前该用户显示过新手引导，直接跳过
    NSString *key = [NSString stringWithFormat:@"NewbiewGuide_%@", gAppMgr.myUser.userID];
    if (!gAppMgr.myUser || [gAppMgr.deviceInfo checkIfAppearedAfterVersion:@"2.6" forKey:key]) {
        self.shouldShowNewbieGuideAlert = NO;
        self.shouldShowNewbieGuideDot = NO;
        self.shouldDisablePopupAd = NO;
        signal = [RACSignal return:nil];
    }
    else {
        @weakify(self);
        signal = [[[[[gMapHelper rac_getUserLocationAndInvertGeoInfoWithAccuracy:kCLLocationAccuracyKilometer] ignoreError] then:^RACSignal *{
            
            GetNewbieInfoOp *op = [GetNewbieInfoOp operation];
            op.req_province = gMapHelper.addrComponent.province;
            op.req_city = gMapHelper.addrComponent.city;
            return [op rac_postRequest];
        }] doNext:^(GetNewbieInfoOp *op) {
            
            @strongify(self);
            self.newbieInfo = op;
            //如果以前没有点过弹框，则需要显示弹框
            if (![self isNewbieGuideAlertAppeared]) {
                //禁用弹出广告功能
                self.shouldDisablePopupAd = op.rsp_jumpwinflag == 1;
                self.shouldShowNewbieGuideDot = op.rsp_jumpwinflag == 1;
                //下载弹框图片
                [self downloadNewbieGuidePicIfNeeded:op];
            }
            //如果已经看过引导了
            else if ([gAppMgr.deviceInfo checkIfAppearedAfterVersion:@"2.6" forKey:key]) {
                self.shouldShowNewbieGuideAlert = NO;
                self.shouldShowNewbieGuideDot = NO;
                //允许首页弹出广告功能
                self.shouldDisablePopupAd = NO;
            }
            else {
                self.shouldShowNewbieGuideDot = op.rsp_washcarflag == 1;
                self.shouldShowNewbieGuideAlert = NO;
                //允许首页弹出广告功能
                self.shouldDisablePopupAd = NO;
            }
        }] replayLast];
    }
    
    CKEvent *event = [signal eventWithName:kEvtCheckNewbieGuide];
    return [self inlineEvent:event forDomain:kDomainNewbiewGuide];
}

- (CGSize)newbieGuideAlertImageSize
{
    CGFloat width = ceil([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale * 0.84);
    CGFloat height = ceil(width * 4 / 3);
    return CGSizeMake(width, height);
}

- (void)setNewbieGuideAlertAppeared
{
    NSString *key = [NSString stringWithFormat:@"NewbiewGuide_%@.Alert", gAppMgr.myUser.userID];
    [gAppMgr.deviceInfo firstAppearAfterVersion:@"2.6" forKey:key];
    self.shouldShowNewbieGuideAlert = NO;
    [self triggerEvent:[[RACSignal return:nil] eventWithName:kDomainNewbiewGuide]];
}

- (void)setNewbieGuideAppeared
{
    [self setNewbieGuideAlertAppeared];
    NSString *key = [NSString stringWithFormat:@"NewbiewGuide_%@", gAppMgr.myUser.userID];
    [gAppMgr.deviceInfo firstAppearAfterVersion:@"2.6" forKey:key];
    self.shouldShowNewbieGuideDot = NO;
    [self triggerEvent:[[RACSignal return:nil] eventWithName:kDomainNewbiewGuide]];
}


#pragma mark - Utility
- (BOOL)isNewbieGuideAlertAppeared
{
    NSString *alertKey = [NSString stringWithFormat:@"NewbiewGuide_%@.Alert", gAppMgr.myUser.userID];
    return [gAppMgr.deviceInfo checkIfAppearedAfterVersion:@"2.6" forKey:alertKey];
}

- (void)downloadNewbieGuidePicIfNeeded:(GetNewbieInfoOp *)op
{
    NSString *url = op.rsp_pic;
    if ([gAppMgr.mediaMgr cachedImageExistsForUrl:url]) {
        self.shouldShowNewbieGuideAlert = YES;
        return;
    }
    
    @weakify(self);
    [[gAppMgr.mediaMgr rac_getImageByUrl:url withType:ImageURLTypeOrigin defaultPic:nil errorPic:nil]
     subscribeNext:^(id x) {
         
         @strongify(self);
         //只有当图片下载成功的时候才应该显示弹框
         self.shouldShowNewbieGuideAlert = YES;
         [self triggerEvent:[[RACSignal return:op] eventWithName:kEvtCheckNewbieGuide] forDomain:kDomainNewbiewGuide];
     }];
}
@end
