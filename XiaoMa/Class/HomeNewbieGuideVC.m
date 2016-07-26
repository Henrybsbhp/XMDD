//
//  HomeNewbieGuideVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HomeNewbieGuideVC.h"
#import "GuideStore.h"
#import "DetailWebVC.h"

@interface HomeNewbieGuideVC ()
@property (nonatomic, strong) GetNewbieInfoOp *newbieInfo;
@property (nonatomic, weak) UIViewController *targetVC;
@end

@implementation HomeNewbieGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:containerView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    [imageView setImageByUrl:self.newbieInfo.rsp_pic withType:ImageURLTypeOrigin defImage:nil errorImage:nil];
    [containerView addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionJump:)];
    [imageView addGestureRecognizer:tap];
    
    UIImageView *closeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    closeView.image = [UIImage imageNamed:@"hp_guide_close"];
    [containerView addSubview:closeView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    UIView *view = self.view;
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];

    @weakify(imageView);
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(imageView);
        make.bottom.equalTo(containerView);
        make.left.equalTo(containerView);
        make.right.equalTo(containerView);
        make.height.equalTo(imageView.mas_width).multipliedBy(800.0/600);
    }];
    
    [closeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(27, 48));
        make.right.equalTo(containerView);
        make.bottom.equalTo(imageView.mas_top);
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
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

- (void)actionJump:(UITapGestureRecognizer *)tap
{
    [MobClick event:@"rp101_16"];
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
    
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = self.newbieInfo.rsp_url ? self.newbieInfo.rsp_url : kNewbieGuideUrl;
    [self.targetVC.navigationController pushViewController:vc animated:YES];
    [[GuideStore fetchOrCreateStore] setNewbieGuideAppeared];
}

+ (instancetype)presentInTargetVC:(UIViewController *)targetVC
{
    HomeNewbieGuideVC *vc = [[HomeNewbieGuideVC alloc] init];
    vc.targetVC = targetVC;
    
    GuideStore *store = [GuideStore fetchOrCreateStore];
    vc.newbieInfo = store.newbieInfo;
    
    CGFloat width = ceil(targetVC.view.frame.size.width * 0.84);
    CGFloat height = ceil(width * 800.0 / 600);
    CGSize size = CGSizeMake(width+20, height+48+20);
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    sheet.shouldCenterVertically = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [store setNewbieGuideAlertAppeared];
    
    return vc;
}

@end
