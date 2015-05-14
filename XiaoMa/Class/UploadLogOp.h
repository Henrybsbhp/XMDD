//
//  UploadLogOp.h
//  XiaoMa
//
//  Created by jt on 15-5-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface UploadLogOp : BaseOp

@property (nonatomic, strong) NSArray *req_fileDataArray;
@property (nonatomic, strong) NSString *req_fileName;
@property (nonatomic, strong) NSString *req_fileType;
@property (nonatomic, strong) NSArray *rsp_urlArray;

- (void)setFileArray:(NSArray *)files withGetDataBlock:(NSData*(^)(id))block;

@end
