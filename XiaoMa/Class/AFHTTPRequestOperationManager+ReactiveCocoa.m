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
    
    NSString *str = [[NSString alloc] initWithData:req.HTTPBody encoding:NSUTF8StringEncoding];
    DebugGreenLog(@"▂ ▃ ▄ ▅ ▆ ▇ █ ▉ Request = %@\ndata = %@ \n", req.URL, str);
    
    AFHTTPRequestOperation * op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
//    op.responseSerializer = [AFJSONRequestSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError * error;
        
        NSString *unicodeObj = [NSString stringWithUTF8Data:responseObject];
        NSString *chineseObj = [self unicodeToChinese:unicodeObj];
        DebugGreenLog(@"█ ▉ ▇ ▆ ▅ ▄ ▃ ▂ Response = %@\nmethod = %@ (id: %@)\ndata = %@ \n", req.URL, method, requestId, chineseObj);
        
        NSDictionary *jsonObject =  [NSJSONSerialization
                                  JSONObjectWithData:responseObject
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];
        
        if (!error)
        {
//            NSLog(@"█ ▉ ▇ ▆ ▅ ▄ ▃ ▂ Response Json : \n %@ \n",jsonObject);
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
