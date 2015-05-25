//
//  EditPictureViewController.m
//  EasyPay
//
//  Created by jiangjunchen on 15/5/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EditPictureViewController.h"

@interface EditPictureViewController ()
@end

@implementation EditPictureViewController

- (void)viewDidLoad
{
    self.toolbarHidden = YES;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

+ (UIImage *)generateImageByAddingWatermarkWith:(UIImage *)croppedImage
{
    UIImage *image = [croppedImage compressImageWithPixelSize:CGSizeMake(1024, 1024)];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    //Draw image
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    //Draw watermark
    UIImage *watermark = [UIImage imageNamed:@"cm_watermark"];
    CGFloat yoffset = ceil((image.size.height/image.size.width - watermark.size.height/watermark.size.width)*image.size.width/2.0);
    [watermark drawInRect:CGRectMake(0, yoffset, image.size.width, image.size.height - 2*yoffset)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
