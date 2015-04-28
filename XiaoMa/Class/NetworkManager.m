//
//  NetworkManager.m
//  XiaoMa
//
//  Created by jt on 15-4-10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

static NetworkManager *g_networkManager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        g_networkManager = [[NetworkManager alloc] init];
    });
    return g_networkManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.simulateResponse = NO;
        self.simulateResponseDelay = 0.2;
        _apiServer = ApiBaseUrl;
        NSURL * url = [NSURL URLWithString:_apiServer];
        _apiManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _mediaClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

#pragma mark - Public

- (void)handleError:(NSError *)error forOp:(BaseOp *)op
{
    if (self.catchErrorHandler)
    {
        self.catchErrorHandler(op, error);
    }
}

@end
