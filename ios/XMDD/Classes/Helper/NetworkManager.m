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
    dispatch_once(&onceToken, ^ {\
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
        _apiServer = (!gAppMgr.isSwitchToFormalSurrounding ) ? ApiBaseUrl : ApiFormalUrl;
        NSURL * url = [NSURL URLWithString:_apiServer];
        _apiManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        _baseManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:XmddBaseUrl]];
        _baseManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        _longtimeManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _longtimeManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _longtimeManager.requestSerializer.timeoutInterval = 3*60;
        
        /// https设置
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = NO;
        
#if XMDDEnvironment==0
#else
        _apiManager.securityPolicy = securityPolicy;
        _longtimeManager.securityPolicy = securityPolicy;
        _baseManager.securityPolicy = securityPolicy;
#endif

        _reactManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _mediaClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        
        NSURL * logUrl = [NSURL URLWithString:LogUploadUrl];
        _logClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:logUrl];
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
