//
//  LaunchVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LaunchVC.h"

@interface LaunchVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
@implementation LaunchVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
    [self swithToRootViewAfterDelay:1];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (![image isEqual:self.imageView.image]) {
        CKAsyncMainQueue(^{
            self.imageView.image = image;
        });
    }
}

- (void)swithToRootViewAfterDelay:(NSTimeInterval)delay
{
    CKAfter(delay, ^{
        
        UIViewController *vc = [UIStoryboard vcWithId:@"MainTabBarVC" inStoryboard:@"Main"];
        [gAppDelegate resetRootViewController:vc];
    });
}

@end
