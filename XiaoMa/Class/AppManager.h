//
//  AppManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTUser.h"

@interface AppManager : NSObject
@property (nonatomic, strong) JTUser *myUser;
+ (AppManager *)sharedManager;
- (void)resetWithAccount:(NSString *)account;

@end
