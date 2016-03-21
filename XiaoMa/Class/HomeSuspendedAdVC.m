//
//  HomeSuspendedAdVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/2/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HomeSuspendedAdVC.h"
#import "UIView+Genie.h"
#import "SuspendedAdVC.h"

@interface HomeSuspendedAdVC () <SuspendedAdClickDelegate>

@property (nonatomic, weak) UIViewController *targetVC;

@property (nonatomic, strong) MZFormSheetController * sheet;

@property (nonatomic, strong) SuspendedAdVC * adCtrl;
@property (nonatomic, strong) UIImageView * closeView;

@property (nonatomic, strong) NSArray * adListArr;

@end

@implementation HomeSuspendedAdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:containerView];
    
    self.adCtrl = [SuspendedAdVC adVCWithBoundsWidth:self.targetVC.view.frame.size.width * 0.84 targetVC:self.targetVC mobBaseEvent:@"rp101_17"];
    self.adCtrl.clickDelegate = self;
    
    self.adCtrl.adList = self.adListArr;
    [self.adCtrl.adView reloadDataRemovingCurrentPage:YES];
    self.adCtrl.adView.currentPageIndex = 0;
    self.adCtrl.adView.pageControl.hidden = self.adCtrl.adList.count <= 1;
    
    [containerView addSubview:self.adCtrl.adView];
    
    UIImageView *closeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    closeView.image = [UIImage imageNamed:@"hp_guide_close"];
    self.closeView = closeView;
    [containerView addSubview:closeView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    CGFloat width = ceil(self.targetVC.view.frame.size.width * 0.84);
    CGFloat topSpace = ceil((self.targetVC.view.frame.size.height - width * 800.0 / 600) / 2);
    
    UIView *view = self.view;
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(topSpace + 10, 10, topSpace + 10, 10));
    }];
    
    [self.adCtrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(containerView);
        make.left.equalTo(containerView);
        make.right.equalTo(containerView);
        make.height.equalTo(self.adCtrl.adView.mas_width).multipliedBy(800.0/600);
    }];
    
    [closeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(27, 48));
        make.right.equalTo(containerView);
        make.bottom.equalTo(self.adCtrl.adView.mas_top);
    }];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerX.equalTo(closeView.mas_centerX);
        make.top.equalTo(closeView.mas_top).offset(-7);
    }];
    
    @weakify(self);
    [[[RACObserve(gAppDelegate.errorModel, alertView) distinctUntilChanged] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        if (!x) {
            [self actionClose:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)adClick {
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

- (void)actionClose:(id)sender
{
    [MobClick event:@"rp101_17_x"];
    self.closeView.hidden = YES;
    int space;
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        space = 40;
    }
    else {
        space = 0;
    }
    CGRect endRect = CGRectMake(self.targetVC.view.frame.size.width * 0.84 / 2 - 4, self.targetVC.view.frame.size.height + space, 8, 8);
    
    [self.adCtrl.adView genieInTransitionWithDuration:0.4 destinationRect:endRect destinationEdge:BCRectEdgeTop completion:
     ^{
         //若设置为NO，快速点击两次会出现黑色蒙版不消失的bug
         [self.formSheetController dismissAnimated:YES completionHandler:nil];
         //设置动画后，4s和5s等设备会有弹跳
         self.formSheetController.view.hidden = YES;
     }];
}

+ (instancetype)presentInTargetVC:(UIViewController *)targetVC withAdList:(NSArray *)adArr
{
    HomeSuspendedAdVC *vc = [[HomeSuspendedAdVC alloc] init];
    vc.targetVC = targetVC;
    vc.adListArr = adArr;
    
    CGFloat width = ceil(targetVC.view.frame.size.width * 0.84);
    CGFloat height = ceil(targetVC.view.frame.size.height);
    CGSize size = CGSizeMake(width+20, height + 48 + 20);
    
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    MZFormSheetWindow * sheetWindow = [[MZFormSheetWindow alloc] init];
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    sheet.shouldCenterVertically = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    
    vc.sheet = sheet;
    
    [sheet presentAnimated:YES completionHandler:nil];
    
    return vc;
}

-(void)dealloc
{
    DebugLog(@"HomeSuspendedAdVC dealloc~~~");
}

@end
