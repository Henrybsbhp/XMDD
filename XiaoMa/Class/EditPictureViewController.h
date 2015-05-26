//
//  EditPictureViewController.h
//  EasyPay
//
//  Created by jiangjunchen on 15/5/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropViewController.h"

@interface EditPictureViewController : PECropViewController

+ (UIImage *)generateImageByAddingWatermarkWith:(UIImage *)image;

@end
