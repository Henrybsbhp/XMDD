//
//  WelcomeViewController.m
//  XiaoMa
//
//  Created by jt on 15-6-18.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SYPaginatorView.h"
#import "SYPageView.h"
#import "MainTabBarVC.h"

@interface WelcomeViewController ()<SYPaginatorViewDataSource, SYPaginatorViewDelegate>

@property (weak, nonatomic) IBOutlet SYPaginatorView *sypaginatorView;
@property (nonatomic,strong)NSArray * imageArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger deviceWidth = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    NSInteger deviceHeight = (NSInteger)[[UIScreen mainScreen] bounds].size.height;
    NSString * imageName1 = [NSString stringWithFormat:@"welcome1_%ld_%ld",(long)deviceWidth,(long)deviceHeight];
    NSString * imageName2 = [NSString stringWithFormat:@"welcome2_%ld_%ld",(long)deviceWidth,(long)deviceHeight];
    NSString * imageName3 = [NSString stringWithFormat:@"welcome3_%ld_%ld",(long)deviceWidth,(long)deviceHeight];
    NSString * imageName4 = [NSString stringWithFormat:@"welcome4_%ld_%ld",(long)deviceWidth,(long)deviceHeight];
    self.imageArray = @[imageName1,imageName2,imageName3,imageName4];
    
    self.sypaginatorView.delegate = self;
    self.sypaginatorView.dataSource = self;
    self.sypaginatorView.currentPageIndex = 0;
}

- (void)dealloc
{
    DebugLog(@"WelcomeViewController dealloc");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    NSInteger ii = self.imageArray.count;
    return ii ;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    if (!pageView) {
        pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        imgV.tag = 1001;
        [pageView addSubview:imgV];
    }
    NSString * imageName = [self.imageArray safetyObjectAtIndex:pageIndex];
    UIImage * image = [UIImage imageNamed:imageName];
    UIImageView *imgV = (UIImageView *)[pageView viewWithTag:1001];
    imgV.image = image;
    
    UITapGestureRecognizer * gesture = imgV.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [imgV addGestureRecognizer:ge];
        imgV.userInteractionEnabled = YES;
        imgV.customObject = ge;
    }
    gesture = imgV.customObject;
    
    @weakify(self)
    [[[gesture rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        @strongify(self)
        if (pageIndex == self.imageArray.count - 1)
        {
            self.sypaginatorView.alpha = 1.0f;
            MainTabBarVC * mainTabVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabBarVC"];
            [gAppDelegate resetRootViewController:mainTabVC];
            if (self.finishAction)
            {
                self.finishAction();
            }
            
            gAppMgr.clientInfo.lastClientVersion = gAppMgr.clientInfo.clientVersion;
            
//            CKAsyncMainQueue(^{
//            
//                UIViewAnimationOptions option = UIViewAnimationOptionTransitionFlipFromLeft;
//                NSTimeInterval duration = 0.5;
//                [UIView transitionWithView:self.sypaginatorView duration:duration options:option animations:^{
//                    
//                } completion:^(BOOL finished) {
//                    
//                }];
//
//            });
            
            
//            [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//                
//                self.finishAction();
//            } completion:^(BOOL finished) {
//                
//                
//            }];
            
            

            [UIView animateWithDuration:0.5 animations:^{
                
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }];

    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}



@end
