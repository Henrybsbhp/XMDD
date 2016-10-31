//
//  ViewControllerFactory.h
//  XMDD
//
//  Created by jiangjunchen on 16/7/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupIntroductionVC.h"

@interface HKViewControllerFactory : NSObject

///关于页面
+ (__kindof UIViewController *)aboutUsVC;
///小马互助
+ (__kindof UIViewController *)mutualInsVCWithChannel:(NSString *)channel;
///小马互助介绍页
+ (__kindof UIViewController *)mutualInsGroupIntroVCWithGroupType:(MutualGroupType)type;

@end
