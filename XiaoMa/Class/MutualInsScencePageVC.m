//
//  MutualInsScencePageVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsScencePageVC.h"
#import "MutualInsScencePhotoVC.h"
#import "MutualInsPhotoBrowserVC.h"
#import "HKProgressView.h"
#import "MutualInsScencePhotoVM.h"
#import "GetCooperationMyCarOp.h"
#import "ApplyCooperationClaimOp.h"
#import "MutualInsChooseCarVC.h"


#define kOneBtnWidth self.view.bounds.size.width - 30
#define kTwoBtnWidth (self.view.bounds.size.width - 45) / 2


@interface MutualInsScencePageVC ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (strong, nonatomic) IBOutlet UIView *pageView;
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet UIButton *lastStepBtn;
@property (strong, nonatomic) IBOutlet HKProgressView *progressView;
@property (strong, nonatomic) MutualInsScencePhotoVM *scencePhotoVM;

@property (nonatomic,strong) UIPageViewController *pageVC;
@property (nonatomic,strong) NSArray *viewArr;


@property (nonatomic, strong) NSString *scene;
@property (nonatomic, strong) NSString *cardamage;
@property (nonatomic, strong) NSString *carinfo;
@property (nonatomic, strong) NSString *idinfo;

@end

@implementation MutualInsScencePageVC

-(void)dealloc
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.jtnavCtrl setShouldAllowInteractivePopGestureRecognizer:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configPageVC];
    [self setupUI];
    [self setSelectedIndex];
    [self configProgressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPageViewControllerDelegate


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return nil;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return nil;
}


#pragma mark Init

-(void)configPageVC
{
    [self addChildViewController:self.pageVC];
    [self.pageView addSubview:self.pageVC.view];
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

-(void)configProgressView
{
    self.progressView.titleArray = @[@"现场接触",@"车辆损失",@"车辆信息",@"证件照"];
    self.progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    self.progressView.normalColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1];
}

/**
 *  set ButtonUI and BackButtonItem
 */
-(void)setupUI
{
    [self addCorner:self.nextStepBtn];
    [self addCorner:self.lastStepBtn];
    [self addBorder:self.lastStepBtn];

    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cm_nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBtnItem;
}

-(void)setSelectedIndex
{
    NSInteger index = [self.viewArr indexOfObject:self.pageVC.viewControllers.firstObject];
    self.progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index + 1)];
    if (index == 3)
    {
        [self.nextStepBtn setTitle:@"提交" forState:UIControlStateNormal];
    }
    else
    {
        [self.nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    }
    if (index == 0)
    {
        self.lastStepBtn.hidden = YES;
        [self.nextStepBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kOneBtnWidth);
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-10);
        }];
    }
    else
    {
        self.lastStepBtn.hidden = NO;
        [self.lastStepBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kTwoBtnWidth);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.left.mas_equalTo(15);
        }];
        [self.nextStepBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kTwoBtnWidth);
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
        }];
    }
}


#pragma mark Utility
-(void)addCorner:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
}

-(void)addBorder:(UIView *)view
{
    view.layer.borderColor = [[UIColor colorWithHex:@"#18D06A" alpha:1]CGColor];
    view.layer.borderWidth = 1;
}

#pragma mark Action

-(void)back
{
    MutualInsScencePhotoVC *scencePhotoVC = self.viewArr.firstObject;
    if (![[scencePhotoVC canPush] isEqualToString:@"请先拍照"])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您还未保存照片，现在返回将导致照片无法保存，是否现在返回？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [[alertView rac_buttonClickedSignal]subscribeNext:^(NSNumber *x) {
            if (x.integerValue == 1)
            {
                [self.scencePhotoVM deleteAllInfo];
                NSArray *viewControllers = self.navigationController.viewControllers;
                [self.navigationController popToViewController:[viewControllers safetyObjectAtIndex:1] animated:YES];
            }
        }];
    }
    else
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        [self.navigationController popToViewController:[viewControllers safetyObjectAtIndex:1] animated:YES];
    }
}

- (IBAction)lastStepAction:(id)sender {
    MutualInsScencePhotoVC *scencePhotoVC = self.pageVC.viewControllers.firstObject;
    NSInteger index = [self.viewArr indexOfObject:scencePhotoVC];
    [self.pageVC setViewControllers:@[[self.viewArr safetyObjectAtIndex:index - 1] ] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self setSelectedIndex];
}

- (IBAction)nextStepAction:(id)sender {
    
    MutualInsScencePhotoVC *scencePhotoVC = self.pageVC.viewControllers.firstObject;
    NSInteger index = [self.viewArr indexOfObject:scencePhotoVC];
    if ([scencePhotoVC canPush].length == 0 && index != self.viewArr.count - 1)
    {
        [self.pageVC setViewControllers:@[[self.viewArr safetyObjectAtIndex:index + 1] ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self setSelectedIndex];
    }
    else if([scencePhotoVC canPush].length != 0)
    {
        [gToast showMistake:[scencePhotoVC canPush]];
    }
    else
    {
        self.scene = [self.scencePhotoVM URLStringForIndex:0];
        self.cardamage = [self.scencePhotoVM URLStringForIndex:1];
        self.carinfo = [self.scencePhotoVM URLStringForIndex:2];
        self.idinfo = [self.scencePhotoVM URLStringForIndex:3];
        ApplyCooperationClaimOp *op = [[ApplyCooperationClaimOp alloc]init];
        op.req_claimid = self.claimid;
        op.req_scene = self.scene;
        op.req_cardamage = self.cardamage;
        op.req_carinfo = self.carinfo;
        op.req_idinfo = self.idinfo;
        [[[op rac_postRequest]initially:^{
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }]subscribeNext:^(id x) {
            [self.view stopActivityAnimation];
            [gToast showSuccess:@"提交成功"];
            NSArray *viewControllers = self.navigationController.viewControllers;
            [self.navigationController popToViewController:[viewControllers safetyObjectAtIndex:1] animated:YES];
        }error:^(NSError *error) {
            [gToast showMistake:@"提交失败"];
            [self.view stopActivityAnimation];
        }];
        
    }
    
}


#pragma mark LazyLoad

-(UIPageViewController *)pageVC
{
    if (!_pageVC)
    {
        _pageVC = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [_pageVC setViewControllers:@[self.viewArr.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        _pageVC.dataSource = self;
        _pageVC.delegate = self;
    }
    return _pageVC;
}

-(NSArray *)viewArr
{
    if (!_viewArr)
    {
        MutualInsScencePhotoVC *contactVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsScencePhotoVC"];
        contactVC.index = 0;
        contactVC.scencePhotoVM = self.scencePhotoVM;
        MutualInsScencePhotoVC *carLoseVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsScencePhotoVC"];
        carLoseVC.index = 1;
        carLoseVC.scencePhotoVM = self.scencePhotoVM;
        MutualInsScencePhotoVC *carInfoVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsScencePhotoVC"];
        carInfoVC.index = 2;
        carInfoVC.scencePhotoVM = self.scencePhotoVM;
        MutualInsScencePhotoVC *licenceVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsScencePhotoVC"];
        licenceVC.index = 3;
        licenceVC.scencePhotoVM = self.scencePhotoVM;
        _viewArr = @[contactVC,carLoseVC,carInfoVC,licenceVC];
    }
    return _viewArr;
}

-(MutualInsScencePhotoVM *)scencePhotoVM
{
    if (!_scencePhotoVM)
    {
        _scencePhotoVM = [[MutualInsScencePhotoVM alloc]init];
        _scencePhotoVM.noticeArr = self.noticeArr;
    }
    return _scencePhotoVM;
}

@end
