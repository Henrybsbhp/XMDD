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
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) UIWindow *nextWindow;
@end
@implementation LaunchVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    gAppDelegate.window.windowLevel = UIWindowLevelStatusBar;
    self.imageView.image = self.image;
    if (self.info.fullscreen) {
        self.bottomView.hidden = YES;
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
    }
    [self swithToRootViewAfterDelay:self.info.staytime > 0 ? self.info.staytime : 2];
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
        self.nextWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.nextWindow.backgroundColor = [UIColor whiteColor];
        UIViewController *vc = [UIStoryboard vcWithId:@"MainTabBarVC" inStoryboard:@"Main"];
        self.nextWindow.rootViewController = vc;
        [self.nextWindow makeKeyAndVisible];
        
        [UIView animateWithDuration:0.35 animations:^{
            gAppDelegate.window.alpha = 0;
        } completion:^(BOOL finished) {
            gAppDelegate.window = self.nextWindow;
        }];
    });
}

@end
