//
//  NewbieGuideManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "GetNewbieInfoOp.h"

#define kEvtCheckNewbieGuide  @"guide.newbie.check"
#define kDomainNewbiewGuide   @"newbieGuide"

@interface GuideStore : UserStore

///新手指引信息
@property (nonatomic, strong) GetNewbieInfoOp *newbieInfo;
///是否显示新手引导的小圆点
@property (nonatomic, assign) BOOL shouldShowNewbieGuideDot;
///是否显示新手引导的弹框
@property (nonatomic, assign) BOOL shouldShowNewbieGuideAlert;

- (CKEvent *)checkNewbieGuide;
- (void)setNewbieGuideAlertAppeared;
- (void)setNewbieGuideAppeared;
- (CGSize)newbieGuideAlertImageSize;

@end
