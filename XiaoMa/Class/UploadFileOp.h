//
//  UploadFileOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

typedef enum : NSInteger
{
    UploadFileTypeDrivingLicenseAndOther = 0,
    UploadFileTypeDaDaHelp = 1,// 达达帮忙
}UploadFileType;

@interface UploadFileOp : BaseOp
@property (nonatomic, assign) UploadFileType req_fileType;
@property (nonatomic, strong) NSString *req_fileExtType;
@property (nonatomic, strong) NSString *req_uploadUrl;
@property (nonatomic, strong) NSArray *req_fileDataArray;
@property (nonatomic, strong) NSArray *rsp_urlArray;
@property (nonatomic, strong) NSArray *rsp_idArray;

- (void)setProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block;
- (void)setFileArray:(NSArray *)files withGetDataBlock:(NSData*(^)(id))block;

@end
