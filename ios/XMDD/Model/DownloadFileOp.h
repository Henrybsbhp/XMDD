//
//  DownloadFileOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface DownloadFileOp : BaseOp

@property (nonatomic, strong) NSString *req_url;
@property (nonatomic, strong) NSString *req_savePath;
@property (nonatomic, assign) BOOL req_appendData;

@end
