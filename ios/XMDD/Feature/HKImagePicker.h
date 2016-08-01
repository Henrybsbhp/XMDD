//
//  HKImagePicker.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKImagePickerConfig;
@interface HKImagePicker : NSObject
///(Default is YES)
@property (nonatomic, assign) BOOL shouldShowBigImage;
///(Default is NO)
@property (nonatomic, assign) BOOL allowsEditing;
///(Default is YES)
@property (nonatomic, assign) BOOL shouldCompress;
///(Default is 1024*1024)
@property (nonatomic, assign) CGSize compressedSize;

+ (instancetype)imagePicker;
- (RACSignal *)rac_pickImageInTargetVC:(UIViewController *)targetVC inView:(UIView *)view;
- (RACSignal *)rac_pickPhotoTargetVC:(UIViewController *)targetVC inView:(UIView *)view;
@end

@interface HKImageShowingViewController : HKViewController
@property (nonatomic, strong) UIImage *image;
- (id)initWithSubject:(RACSubject *)subject;
@end
