//
//  AFHTTPRequestOperationManager+ReactiveCocoa.h
//  XiaoMa
//
//  Created by jt on 15-4-10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "XiaoMa.h"

@interface AFHTTPRequestOperationManager (ReactiveCocoa)


- (RACSignal *)rac_invokeMethod:(NSString *)method parameters:(id)parameters
                      requestId:(id)requestId operation:(AFHTTPRequestOperation **)operation;

@end
