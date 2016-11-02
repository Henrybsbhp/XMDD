//
//  ImagePickerVC.h
//  XMDD
//
//  Created by jiangjunchen on 16/10/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerVC : NSObject

@property (nonatomic, strong) UIImage *exampleImage;
@property (nonatomic, strong) NSString *exampleTitle;
/// (default is YES)
@property (nonatomic, assign) BOOL shouldShowExample;
/// (default is YES)
@property (nonatomic, assign) BOOL shouldCompressImage;
@property (nonatomic, weak) UIViewController *targetVC;
@property (nonatomic, copy) void (^completedBlock)(id result);

- (void)show;

@end
