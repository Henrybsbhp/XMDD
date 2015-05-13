//
//  JTCaptureScreen.h
//  XiaoNiuShared
//
//  Created by jt on 14-8-6.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTCaptureScreen : NSObject

/// 截图，返回UIImage
+ (UIImage *)captureScreen;

/// 保存到相册
+ (void)saveScreenshotToPhotosAlbum:(UIImage *)image;

//Get the screenshot of a view.
+ (UIImage *)screenshotOfView:(UIView *)view;

//Get the screenshot, image rotate to status bar's current interface orientation. With status bar.
+ (UIImage *)screenshot;

//Get the screenshot, image rotate to status bar's current interface orientation.
+ (UIImage *)screenshotWithStatusBar:(BOOL)withStatusBar;

//Get the screenshot with rect, image rotate to status bar's current interface orientation.
+ (UIImage *)screenshotWithStatusBar:(BOOL)withStatusBar rect:(CGRect)rect;

//Get the screenshot with rect, you can specific a interface orientation.
+ (UIImage *)screenshotWithStatusBar:(BOOL)withStatusBar rect:(CGRect)rect orientation:(UIInterfaceOrientation)o;

@end
