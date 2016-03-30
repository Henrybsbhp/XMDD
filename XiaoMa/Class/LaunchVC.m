//
//  LaunchVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LaunchVC.h"
#import "MainTabBarVC.h"

@interface LaunchVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) UIWindow *nextWindow;

///是否点击切换到其他页面
@property (nonatomic)BOOL isClickSwitchToOtherView;
@end
@implementation LaunchVC

- (void)dealloc
{
    DebugLog(@"LaunchVC dealloc");
}

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
    
    if (self.info.url.length)
    {
        [self setupClickAction];
        
        ///如果是有广告，并且没有点击，时间停留多一秒
        [self swithToRootViewAfterDelay:self.info.staytime > 0 ? self.info.staytime : 3];
    }
    else
    {
        [self swithToRootViewAfterDelay:self.info.staytime > 0 ? self.info.staytime : 2];
    }
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
- (void)setupClickAction
{
    UITapGestureRecognizer * gesture = self.imageView.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [self.imageView addGestureRecognizer:ge];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.customObject = ge;
    }
    gesture = self.imageView.customObject;
    
    [[gesture rac_gestureSignal] subscribeNext:^(id x) {
        
        self.isClickSwitchToOtherView = YES;
        [self swithToRootViewAfterDelay:0.1 url:self.info.url];
    }];
}

- (void)swithToRootViewAfterDelay:(NSTimeInterval)delay
{
    CKAfter(delay, ^{
        
        if (self.isClickSwitchToOtherView)
            return ;
        
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

- (void)swithToRootViewAfterDelay:(NSTimeInterval)delay url:(NSString *) url
{
    CKAfter(delay, ^{
        self.nextWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.nextWindow.backgroundColor = [UIColor whiteColor];
        UIViewController *vc = [UIStoryboard vcWithId:@"MainTabBarVC" inStoryboard:@"Main"];
        self.nextWindow.rootViewController = vc;
        [self.nextWindow makeKeyAndVisible];
        
        if (gAppMgr.navModel.curNavCtrl && url.length)
        {
            NSDictionary * dict = @{@"url":url};
            [gAppDelegate.openUrlQueue addObject:dict forKey:nil];
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            gAppDelegate.window.alpha = 0;
        } completion:^(BOOL finished) {
            gAppDelegate.window = self.nextWindow;
        }];
    });
}

@end
