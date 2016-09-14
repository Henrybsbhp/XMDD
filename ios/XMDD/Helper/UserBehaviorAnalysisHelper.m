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
                             @"MutualInsVC":@{@"pagetag":@"page_huzhushouye",@"firsttag":@"huzhushouyefirsttime",@"pageduration":@"page_huzhushouye_duration"},//互助首页
                             @"MutualInsStoryAdPicVC":@{@"pagetag":@"page_huzhugushi",@"firsttag":@"huzhugushifirsttime",@"pageduration":@"page_huzhugushi_duration"},//小故事
                             @"MutInsCalculateVC":@{@"pagetag":@"page_feiyongshisuan",@"firsttag":@"feiyongshisuanfirsttime",@"pageduration":@"page_feiyongshisuan_duration"},//费用试算
                             @"MutInsCalculateResultVC":@{@"pagetag":@"page_shisuanjieguo",@"firsttag":@"shisuanjieguofirsttime",@"pageduration":@"page_shisuanjieguo_duration"},//试算结果
                             
                             @"MutInsSystemGroupListVC":@{@"pagetag":@"page_huzhutuan",@"firsttag":@"huzhutuanfirsttime",@"pageduration":@"page_huzhutuan_duration"},//互助团
                             @"GroupIntroductionVC":@{@"pagetag":@"page_rutuanyaoqiu",@"firsttag":@"rutuanyaoqiufirsttime",@"pageduration":@"page_rutuanyaoqiu_duration"},//入团要求
                             @"MutualInsPicUpdateVC":@{@"pagetag":@"page_wanshanziliao",@"firsttag":@"wanshanziliaofirsttime",@"pageduration":@"page_wanshanziliao_duration"},//完善资料
                             @"MutualInsPicUpdateResultVC":@{@"pagetag":@"page_tijiaochenggong",@"firsttag":@"tijiaochenggongfirsttime",@"pageduration":@"page_tijiaochenggong_duration"},//提交成功
                             @"MutualInsGroupDetailVC":@{@"pagetag":@"page_tuanxiangqing",@"firsttag":@"tuanxiangqingfirsttime",@"pageduration":@"page_tuanxiangqing_duration"},//团详情
                             };
    });
    return g_pagesUMLogInfo;
}



@end
