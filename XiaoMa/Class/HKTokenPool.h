//
//  HKTokenPool.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTokenPool : NSObject

- (void)removeToken:(NSString *)token forAccount:(NSString *)account;
- (void)setToken:(NSString *)token forAccount:(NSString *)account;
- (NSString *)tokenForAccount:(NSString *)account;
//保守估计token是否有效(24小时)
- (BOOL)isTokenAvailableForAccount:(NSString *)account;

@end
