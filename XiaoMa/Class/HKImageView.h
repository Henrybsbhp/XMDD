//
//  HKImageView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadFileOp.h"
#import "UIImageView+WebImage.h"

@interface HKImageView : UIImageView
@property (nonatomic, strong) UIButton *reuploadButton;
@property (nonatomic, strong) UIButton *pickImageButton;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGesture;

- (RACSignal *)rac_setUploadingImage:(UIImage *)img withImageType:(UploadFileType)type;
- (void)setImageByUrl:(NSString *)url withType:(ImageURLType)type defImageObj:(UIImage *)defimg errorImageObj:(UIImage *)errimg;
- (void)setImage:(UIImage *)image;
- (void)hideMaskView;
- (void)showMaskView;

- (void)removeTagGesture;

@end
