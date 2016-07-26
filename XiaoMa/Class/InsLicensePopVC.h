//
//  InsLicensePopVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    InsLicensePopVCTypeNormal,
    InsLicensePopVCTypeXMIns
} InsLicensePopVCType;

@interface InsLicensePopVC : UIViewController

@property (nonatomic)InsLicensePopVCType licensePopVCType;

///弹出服务协议视图（如果同意服务协议，将sendNext:@YES,否则就触发completed)
+ (RACSignal *)rac_showInView:(UIView *)view withLicenseUrl:(NSString *)url title:(NSString *)title  andLicensePopVCType:(InsLicensePopVCType)type;

@end
