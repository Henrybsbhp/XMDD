//
//  HKTokenPool.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKTokenPool.h"

@interface HKTokenPool ()
@property (nonatomic, strong) NSMutableDictionary *pool;
@end
@implementation HKTokenPool

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pool = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)removeToken:(NSString *)token forAccount:(NSString *)account
{
    if (account) {
        [self.pool removeObjectForKey:account];
    }
}

- (void)setToken:(NSString *)token forAccount:(NSString *)account
{
    if (token) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info safetySetObject:token forKey:@"token"];
        [info safetySetObject:[NSDate date] forKey:@"date"];
        [self.pool safetySetObject:info forKey:account];
    }
}

- (NSString *)tokenForAccount:(NSString *)account
{
    NSDictionary *info = [self.pool objectForKey:account];
    return [info objectForKey:@"token"];
}

- (BOOL)isTokenAvailableForAccount:(NSString *)account
{
    NSDictionary *info = [self.pool objectForKey:account];
    NSDate *date = info[@"date"];
    if (!date || [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970] > 24*60*60) {
        return NO;
    }
    return YES;
}

@end
