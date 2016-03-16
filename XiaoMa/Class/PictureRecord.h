//
//  DrivingLicenseRecord.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureRecord : NSObject
///url
@property (nonatomic, strong) NSString *url;
//id
@property (nonatomic, strong) NSNumber *picID;
///车牌
@property (nonatomic, strong) NSString *plateNumber;
///时间戳
@property (nonatomic, assign) NSTimeInterval timetag;
///是否可删除
@property (nonatomic, assign) BOOL deleteable;
///当前行驶证的图片
@property (nonatomic, strong) UIImage *image;
///
@property (nonatomic)BOOL isUploading;

+ (instancetype)pictureRecordWithJSONResponse:(NSDictionary *)rsp;
@end
