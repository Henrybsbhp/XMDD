//
//  JTLogModel.h
//  XiaoNiuShared
//
//  Created by jt on 14-8-21.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTCaptureScreen.h"
#import "LogAlertView.h"

@interface JTLogModel : NSObject

@property (nonatomic)BOOL islogViewAppear;
@property (nonatomic,copy)NSString * appname;
@property (nonatomic,copy)NSString * userid;


- (void)addToScreen;


@end
