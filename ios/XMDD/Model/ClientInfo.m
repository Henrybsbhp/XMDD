//
//  ClientInfo.m
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "ClientInfo.h"
#import <TMCache.h>

@interface ClientInfo ()
@property (nonatomic, strong) TMCache *mCache;
@end

@implementation ClientInfo

- (instancetype)init
{
    self = [super init];
    [self _inits];
    
    return self;
}

- (void)_inits
{
    //开启内部持久化缓存
    _mCache = [[TMCache alloc] initWithName:@"ClientInfo"];
    
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    _clientVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)lastClientVersion
{
    NSString *verson = [_mCache objectForKey:@"lastClientVersion"];
    return verson ? verson : @"";
}

- (void)setLastClientVersion:(NSString *)lastClientVersion
{
    [_mCache setObject:lastClientVersion forKey:@"lastClientVersion"];
}

@end
