//
//  UploadInsuranceInfoVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadInsuranceInfoVC : UIViewController

///(next:(YES--上传成功; NO--跳过)
@property (nonatomic, copy) UIViewController *(^getNextVCBlock)(BOOL skip);

@end
