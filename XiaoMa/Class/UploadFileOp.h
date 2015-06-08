//
//  UploadFileOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface UploadFileOp : BaseOp
@property (nonatomic, strong) NSArray *req_fileDataArray;
@property (nonatomic, strong) NSString *req_fileType;
@property (nonatomic, strong) NSArray *rsp_urlArray;

- (void)setFileArray:(NSArray *)files withGetDataBlock:(NSData*(^)(id))block;

@end
