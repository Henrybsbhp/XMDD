//
//  AFHTTPRequestOperationManager+ReactiveCocoa.m
//  XiaoMa
//
//  Created by jt on 15-4-10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AFHTTPRequestOperationManager+ReactiveCocoa.h"
#import "NetworkManager.h"

@implementation AFHTTPRequestOperationManager (ReactiveCocoa)

- (RACSignal *)rac_invokeMethod:(NSString *)method parameters:(id)parameters
                      requestId:(id)requestId operation:(AFHTTPRequestOperation **)operation
{
    RACSubject *signal = [RACSubject subject];
    
    NSMutableURLRequest *req = [self requestWithMethod:method parameters:parameters requestId:requestId];
    DebugGreenLog(@"▂ ▃ ▄ ▅ ▆ ▇ █ ▉ Request = %@\ndata =  \n %@ \n", req.URL, parameters);
    
    if (gAppMgr.isShowRequestParamsAlert) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:0
                                                             error:nil];
        NSString *string = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
        NSString *string2 = [[[string stringByReplacingOccurrencesOfString:@"," withString:@"\n"]
                              stringByReplacingOccurrencesOfString:@"{" withString:@""]
                             stringByReplacingOccurrencesOfString:@"}" withString:@""];
        NSString *requestParamsString = [NSString stringWithFormat:@"%@\ndata = %@ \n", req.URL, string2];
        UIAlertView *requestParamsAlertView = [[UIAlertView alloc] initWithTitle:@"【Request】" message:requestParamsString delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil, nil];
        [requestParamsAlertView show];
    }
    
    AFHTTPRequestOperation * op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError * error;
        
        NSDictionary *jsonObject =  [NSJSONSerialization
                                  JSONObjectWithData:responseObject
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];
        
        DebugGreenLog(@"█ ▉ ▇ ▆ ▅ ▄ ▃ ▂ Response = %@\nmethod = %@ (id: %@)\ndata = \n %@ \n", req.URL, method, requestId, jsonObject);
        
        if (!error)
        {
            [signal sendNext:RACTuplePack(operation,jsonObject)];
            [signal sendCompleted];
        }
        else
        {
            [signal sendError:error];
        }
        [signal sendNext:RACTuplePack(operation,jsonObject)];
        [signal sendCompleted];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [signal sendError:error];
    }];
    
    [gNetworkMgr.apiManager.operationQueue addOperation:op];
    
    *operation = op;
    return signal;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                parameters:(id)parameters
                                 requestId:(id)requestId
{
    NSParameterAssert(method);
    
    if (!parameters) {
        parameters = @[];
    }
    
    NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expect NSArray or NSDictionary in JSONRPC parameters");
    
    if (!requestId) {
        requestId = @(1);
    }
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"params"] = parameters;
    payload[@"id"] = [requestId description];
    payload[@"version"] = gAppMgr.deviceInfo.appVersion;
#if XMDDENT
    payload[@"os"] = @(1003);
#else
    payload[@"os"] = @(IOSAPPID);
#endif

    NSString * urlStr = [NSString stringWithFormat:@"%@%@", [self.baseURL absoluteString],method];
    return [self.requestSerializer requestWithMethod:@"POST" URLString:urlStr parameters:payload error:nil];
}

- (RACSignal *)rac_invokeMethod:(NSString *)method parameters:(id)parameters
{
    static int32_t integerID = 0;
    return [self rac_invokeMethod:method parameters:parameters requestId:@(integerID++) operation:nil];
}



- (NSString *)unicodeToChinese:(NSString *)unicode
{
    NSString *tempStr1 = [unicode stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

@end
