//
//  HomeSuspendedAdVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/2/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HomeSuspendedAdVC.h"
#import "UIView+Genie.h"
#import "ADViewController.h"

@interface HomeSuspendedAdVC ()

@property (nonatomic, weak) UIViewController *targetVC;

@property (nonatomic, strong)ADViewController * adCtrl;
@property (nonatomic, strong)UIImageView * closeView;


@end

@implementation HomeSuspendedAdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:containerView];
    
    self.adCtrl = [ADViewController vcWithADType:AdvertisementAlert boundsWidth:self.targetVC.view.frame.size.width * 0.84 targetVC:self.targetVC mobBaseEvent:@""];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)actionClose:(id)sender
{
    self.closeView.hidden = YES;
    CGRect endRect = CGRectMake(self.targetVC.view.frame.size.width * 0.84 / 2 - 4, self.targetVC.view.frame.size.height - 37, 8, 8);
    
    [self.adCtrl.adView genieInTransitionWithDuration:0.4 destinationRect:endRect destinationEdge:BCRectEdgeTop completion:
     ^{
         [self.formSheetController dismissAnimated:NO completionHandler:nil];
     }];
}

+ (instancetype)presentInTargetVC:(UIViewController *)targetVC
{
    HomeSuspendedAdVC *vc = [[HomeSuspendedAdVC alloc] init];
    vc.targetVC = targetVC;
    
    CGFloat width = ceil(targetVC.view.frame.size.width * 0.84);
    CGFloat height = ceil(targetVC.view.frame.size.height);
    CGSize size = CGSizeMake(width+20, height + 48 + 20);
    
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    sheet.shouldCenterVertically = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    [sheet presentAnimated:YES completionHandler:nil];
    
    return vc;
}

-(void)dealloc
{
    DebugLog(@"HomeSuspendedAdVC dealloc~~~");
}

@end
