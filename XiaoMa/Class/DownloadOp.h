//
//  DownloadOp.h
//  HappyTrain
//
//  Created by jt on 14-11-18.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "BaseOp.h"

@interface DownloadOp : BaseOp

@property (nonatomic, strong) NSString *req_uri;

@property (nonatomic, strong) NSData *rsp_data;
@property (nonatomic, strong) NSString *rsp_url;

+ (instancetype)firstDownloadOpInClientForReqURI:(NSString *)req_uri;

@end
