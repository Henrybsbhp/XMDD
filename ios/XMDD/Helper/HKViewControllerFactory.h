//
//  ViewControllerFactory.h
//  XMDD
//
//  Created by jiangjunchen on 16/7/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKViewControllerFactory : NSObject

///关于页面
+ (__kindof UIViewController *)aboutUsVC;

///小马互助
+ (__kindof UIViewController *)mutualInsVCWithChannel:(NSString *)channel;

@end
