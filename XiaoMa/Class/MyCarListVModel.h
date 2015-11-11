//
//  MyCarListVModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKMyCar.h"

@interface MyCarListVModel : NSObject
@property (nonatomic, strong) HKMyCar *selectedCar;
@property (nonatomic, strong) HKMyCar *currentCar;
@property (nonatomic, assign) BOOL disableEditingCar;
@property (nonatomic, assign) BOOL allowAutoChangeSelectedCar;
@property (nonatomic, copy) void(^finishBlock)(HKMyCar *curSelectedCar);
@property (nonatomic, weak) UIViewController *originVC;

///根据行驶证的审核状态，设置相应的上传按钮和描述标签
- (void)setupUploadBtn:(UIButton *)btn andDescLabel:(UILabel *)label forCar:(HKMyCar *)car;
- (RACSignal *)rac_uploadDrivingLicenseWithTargetVC:(UIViewController *)targetVC initially:(void(^)(void))block;
- (NSString *)descForCarStatus:(HKMyCar *)car;

@end
