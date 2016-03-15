//
//  ScencePageVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ScencePageVC.h"
#import "ScencePhotoVC.h"
#import "PhotoBrowserVC.h"
#import "HKProgressView.h"
#import "ScencePhotoVM.h"
#import "GetCooperationMyCarOp.h"
#import "ApplyCooperationClaimOp.h"


#define kOneBtnWidth self.view.bounds.size.width - 30
#define kTwoBtnWidth (self.view.bounds.size.width - 45) / 2


@interface ScencePageVC ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (strong, nonatomic) IBOutlet UIView *pageView;
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet UIButton *lastStepBtn;
@property (strong, nonatomic) IBOutlet HKProgressView *progressView;
@property (strong, nonatomic) ScencePhotoVM *scencePhotoVM;

@property (nonatomic,strong) UIPageViewController *pageVC;
@property (nonatomic,strong) NSArray *viewArr;

@property (nonatomic, strong) NSNumber *licensenumber;
@property (nonatomic, strong) NSString *scene;
@property (nonatomic, strong) NSString *cardamage;
@property (nonatomic, strong) NSString *carinfo;
@property (nonatomic, strong) NSString *idinfo;

@end

@implementation ScencePageVC

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
    [self getCarData];
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
    self.nextStepBtn.layer.cornerRadius = 5;
    self.nextStepBtn.layer.masksToBounds = YES;
    self.lastStepBtn.layer.cornerRadius = 5;
    self.lastStepBtn.layer.masksToBounds = YES;
    self.lastStepBtn.layer.borderColor = [[UIColor colorWithHex:@"#18D06A" alpha:1]CGColor];
    self.lastStepBtn.borderWidth = 1;
    
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

-(void)getCarData
{
    GetCooperationMyCarOp *op = [[GetCooperationMyCarOp alloc]init];
    [[[op rac_postRequest]initially:^{
        [self.view startActivityAnimationWithType:MONActivityIndicatorType];
    }]subscribeNext:^(GetCooperationMyCarOp *op) {
        if (op.rsp_licensenumbers.count == 1)
        {
            self.licensenumber = op.rsp_licensenumbers.firstObject;
        }
        else if (op.rsp_licensenumbers.count > 1)
        {
//            @叶志成 添加选车页面
        }
        else
        {
            [gToast showMistake:@"获取您的爱车失败"];
        }
        [self.view stopActivityAnimation];
    }error:^(NSError *error) {
        [self.view stopActivityAnimation];
    }];
}

#pragma mark Action

-(void)back
{
    ScencePhotoVC *scencePhotoVC = self.viewArr.firstObject;
    if ([scencePhotoVC canPush])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请确认是否返回?" message:@"并放弃当前所拍摄的照片" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [[alertView rac_buttonClickedSignal]subscribeNext:^(NSNumber *x) {
            if (x.integerValue == 1)
            {
                [[ScencePhotoVM sharedManager]deleteAllInfo];
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
    ScencePhotoVC *scencePhotoVC = self.pageVC.viewControllers.firstObject;
    NSInteger index = [self.viewArr indexOfObject:scencePhotoVC];
    [self.pageVC setViewControllers:@[[self.viewArr safetyObjectAtIndex:index - 1] ] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self setSelectedIndex];
}

- (IBAction)nextStepAction:(id)sender {
    
    ScencePhotoVC *scencePhotoVC = self.pageVC.viewControllers.firstObject;
    NSInteger index = [self.viewArr indexOfObject:scencePhotoVC];
    if ([scencePhotoVC canPush] && index != self.viewArr.count - 1)
    {
        [self.pageVC setViewControllers:@[[self.viewArr safetyObjectAtIndex:index + 1] ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self setSelectedIndex];
    }
    else if(![scencePhotoVC canPush])
    {
        [gToast showMistake:@"请先拍照"];
    }
    else
    {
        self.scene = [[self.scencePhotoVM urlArrForIndex:0]componentsJoinedByString:@","];
        self.cardamage = [[self.scencePhotoVM urlArrForIndex:1]componentsJoinedByString:@","];
        self.carinfo = [[self.scencePhotoVM urlArrForIndex:2]componentsJoinedByString:@","];
        self.idinfo = [[self.scencePhotoVM urlArrForIndex:3]componentsJoinedByString:@","];
        ApplyCooperationClaimOp *op = [[ApplyCooperationClaimOp alloc]init];
        op.req_licensenumber = self.licensenumber.stringValue;
        op.req_scene = self.scene;
        op.req_cardamage = self.cardamage;
        op.req_carinfo = self.carinfo;
        op.req_idinfo = self.idinfo;
        [[[op rac_postRequest]initially:^{
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }]subscribeNext:^(id x) {
            [self.view stopActivityAnimation];
            [gToast showSuccess:@"提交成功"];
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
        ScencePhotoVC *contactVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        contactVC.index = 0;
        ScencePhotoVC *carLoseVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        carLoseVC.index = 1;
        ScencePhotoVC *carInfoVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        carInfoVC.index = 2;
        ScencePhotoVC *licenceVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ScencePhotoVC"];
        licenceVC.index = 3;
        _viewArr = @[contactVC,carLoseVC,carInfoVC,licenceVC];
    }
    return _viewArr;
}

-(ScencePhotoVM *)scencePhotoVM
{
    if (!_scencePhotoVM)
    {
        _scencePhotoVM = [ScencePhotoVM sharedManager];
    }
    return _scencePhotoVM;
}

@end
