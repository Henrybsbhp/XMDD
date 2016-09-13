//
//  UserBehaviorAnalysisHelper.m
//  XMDD
//
//  Created by fuqi on 16/9/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserBehaviorAnalysisHelper.h"

@implementation UserBehaviorAnalysisHelper

+ (NSDictionary *)getPagesUserBehaviorInfo
{
    static dispatch_once_t onceToken;
    static NSDictionary *g_pagesUMLogInfo;
    dispatch_once(&onceToken, ^{
        g_pagesUMLogInfo = @{
                             //小马互助
                             @"MutualInsVC":@{@"pagetag":@"page_huzhushouye",@"firsttag":@"huzhushouyefirsttime"},//互助首页
                             @"MutualInsStoryAdPicVC":@{@"pagetag":@"page_huzhugushi",@"firsttag":@"huzhugushifirsttime"},//小故事
                             @"MutInsCalculateVC":@{@"pagetag":@"page_feiyongshisuan",@"firsttag":@"feiyongshisuanfirsttime"},//费用试算
                             @"MutInsCalculateResultVC":@{@"pagetag":@"page_shisuanjieguo",@"firsttag":@"shisuanjieguofirsttime"},//试算结果
                             
                             @"MutInsSystemGroupListVC":@{@"pagetag":@"page_huzhutuan",@"firsttag":@"huzhutuanfirsttime"},//互助团
                             @"GroupIntroductionVC":@{@"pagetag":@"page_rutuanyaoqiu",@"firsttag":@"rutuanyaoqiufirsttime"},//入团要求
                             @"MutualInsPicUpdateVC":@{@"pagetag":@"page_wanshanziliao",@"firsttag":@"wanshanziliaofirsttime"},//完善资料
                             @"MutualInsPicUpdateResultVC":@{@"pagetag":@"page_tijiaochenggong",@"firsttag":@"tijiaochenggongfirsttime"},//提交成功
                             @"MutualInsGroupDetailVC":@{@"pagetag":@"page_tuanxiangqing",@"firsttag":@"tuanxiangqingfirsttime"},//团详情
                             };
    });
    return g_pagesUMLogInfo;
}



@end
