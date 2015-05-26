//
//  MyCarListVModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCarListVModel : NSObject

///根据行驶证的审核状态，设置相应的上传按钮和描述标签
- (void)setupUploadBtn:(UIButton *)btn andDescLabel:(UILabel *)label forStatus:(NSInteger)status;
- (RACSignal *)rac_uploadDrivingLicenseWithTargetVC:(UIViewController *)targetVC initially:(void(^)(void))block;

@end
