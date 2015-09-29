//
//  CarListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarListVC.h"
#import <JT3DScrollView.h>
#import "XiaoMa.h"
#import "HKLoadingModel.h"
#import "EditMyCarVC.h"
#import "CarListSubView.h"

@interface CarListVC ()<HKLoadingModelDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet JT3DScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *bottomTitlelabel;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@end

@implementation CarListVC

- (void)awakeFromNib
{
    _model = [[MyCarListVModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupScrollView];
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.view delegate:self];
    CKAsyncMainQueue(^{
        [self.loadingModel loadDataForTheFirstTime];
        [self setupCarModel];
        [self setupBottomView];
    });
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp309"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [(JTNavigationController *)self.navigationController setShouldAllowInteractivePopGestureRecognizer:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp309"];
    [(JTNavigationController *)self.navigationController setShouldAllowInteractivePopGestureRecognizer:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupScrollView
{
    self.scrollView.effect = JT3DScrollViewEffectDepth;
    self.scrollView.angleRatio = 0.3;
    self.scrollView.translateX = 0.03;
    self.scrollView.translateY = 0.05;
    self.scrollView.delegate = self;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat top;
    CGFloat bottom;
    if (height < 568) {
        top = 16;
        bottom = -90;
    }
    else if (height < 667) {
        top = 40;
        bottom = -120;
    }
    else if (height < 736) {
        top = 40;
        bottom = -150;
    }
    else {
        top = 40;
        bottom = -170;
    }

    @weakify(self);
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view).offset(top);
        make.bottom.equalTo(self.view).offset(bottom);
    }];
}

- (void)setupCarModel
{
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) flattenMap:^RACStream *(JTUser *user) {
        
        return [user.carModel rac_observeDataWithDoRequest:nil];
    }] subscribeNext:^(JTQueue *queue) {
        
        @strongify(self);
        [self.loadingModel reloadDataWithDatasource:[queue allObjects]];
    }];
}

- (void)setupBottomView
{
    @weakify(self);
    [[RACObserve(self.model, selectedCar) distinctUntilChanged] subscribeNext:^(HKMyCar *car) {
        
        @strongify(self);
        self.bottomView.hidden = !car;

        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
        
        NSString *str = self.model.allowAutoChangeSelectedCar ? @"您已选择的爱车：" : @"默认车辆：";
        NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                               NSForegroundColorAttributeName:HEXCOLOR(@"#555555")};
        NSAttributedString *prefix = [[NSAttributedString alloc] initWithString:str attributes:attr];
        [attrStr appendAttributedString:prefix];

        if (car.licencenumber.length > 0) {
            NSMutableDictionary *attr2 = [NSMutableDictionary dictionary];
            [attr2 safetySetObject:[UIFont systemFontOfSize:21] forKey:NSFontAttributeName];
            [attr2 safetySetObject:[HKMyCar tintColorForColorType:car.tintColorType] forKey:NSForegroundColorAttributeName];
            NSAttributedString *suffix = [[NSAttributedString alloc] initWithString:car.licencenumber attributes:attr2];
            [attrStr appendAttributedString:suffix];
        }
        
        self.bottomTitlelabel.attributedText  =attrStr;
    }];
}

- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i=0; i<self.loadingModel.datasource.count; i++) {
        HKMyCar *car = self.loadingModel.datasource[i];
        [self createCardWithCar:car atIndex:i];
    }
    
    NSInteger index = NSNotFound;
    
    if (self.model.currentCar) {
        index = [self.loadingModel.datasource indexOfObject:self.model.currentCar];
    }
    if (index == NSNotFound) {
        index = 0;
    }
    [self.scrollView loadPageIndex:index animated:NO];
}

- (void)createCardWithCar:(HKMyCar *)car atIndex:(NSInteger)index
{
    CGFloat w = CGRectGetWidth(self.scrollView.frame);
    CGFloat h = CGRectGetHeight(self.scrollView.frame);
    CGFloat x = self.scrollView.subviews.count * w;
    
    CarListSubView *view = [[CarListSubView alloc] initWithFrame:CGRectMake(x, 0, w, h)];
    [self.scrollView addSubview:view];
    self.scrollView.contentSize = CGSizeMake(x + w, h);
    
    [self reloadSubView:view withCar:car];
}
#pragma mark - Action
- (void)actionBack:(id)sender
{
    //如果爱车信息不完整
    if (self.model.allowAutoChangeSelectedCar && self.model.selectedCar && ![self.model.selectedCar isCarInfoCompleted]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您的爱车信息不完整，是否现在完善？"
                                                       delegate:nil cancelButtonTitle:@"放弃" otherButtonTitles:@"去完善", nil];
        [alert show];
        @weakify(self);
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
            @strongify(self);
            //放弃
            if ([x integerValue] == 0) {
                if (self.model.originVC) {
                    [self.navigationController popToViewController:self.model.originVC animated:YES];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else {
                EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Car"];
                vc.originCar = self.model.selectedCar;
                vc.model = self.model;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
    else {
        if (self.model.originVC) {
            [self.navigationController popToViewController:self.model.originVC animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.model.finishBlock) {
            self.model.finishBlock(self.model.selectedCar);
        }
    }
}

- (IBAction)actionAddCar:(id)sender
{
    [MobClick event:@"rp309-1"];
    EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Car"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Reload
- (void)reloadSubView:(CarListSubView *)subv withCar:(HKMyCar *)car
{
    [subv setCarTintColorType:car.tintColorType];
    
    subv.licenceNumberLabel.text = car.licencenumber;
    subv.markView.hidden = !car.isDefault;
    
    NSString *text = [self.model descForCarStatus:car.status];
    BOOL show = car.status == 3 || car.status == 0;
    [subv setShowBottomButton:show withText:text];
    
    [subv setCellTitle:@"购车时间" withValue:[car.purchasedate dateFormatForYYMM] atIndex:0];
    [subv setCellTitle:@"爱车品牌" withValue:car.brand atIndex:1];
    [subv setCellTitle:@"具体车系" withValue:car.model atIndex:2];
    [subv setCellTitle:@"整车价格" withValue:[NSString stringWithFormat:@"%.2f万元", car.price] atIndex:3];
    [subv setCellTitle:@"当前里程" withValue:[NSString stringWithFormat:@"%d公里", (int)car.odo] atIndex:4];
    [subv setCellTitle:@"年检到期日" withValue:[car.insexipiredate dateFormatForYYMM] atIndex:5];
    [subv setCellTitle:@"保险公司" withValue:car.inscomp atIndex:6];
    
    //汽车品牌logo
    [subv.logoView setImageByUrl:nil withType:ImageURLTypeThumbnail defImage:@"cm_logo_def" errorImage:@"cm_logo_def"];
    
    //上传行驶证
    @weakify(self);
    [subv setBottomButtonClickBlock:^(UIButton *btn, CarListSubView *view) {
        @strongify(self);
        [self uploadDrivingLicenceWithCar:car subView:view];
    }];
    
    //编辑爱车信息
    [subv setBackgroundClickBlock:^(CarListSubView *view) {
        @strongify(self);
        if (self.model.disableEditingCar) {
            return ;
        }
        EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Car"];
        vc.originCar = car;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)uploadDrivingLicenceWithCar:(HKMyCar *)car subView:(CarListSubView *)subView
{
    @weakify(self);
    [[[self.model rac_uploadDrivingLicenseWithTargetVC:self initially:^{
        
        [gToast showingWithText:@"正在上传..."];
    }] flattenMap:^RACStream *(NSString *url) {
        
        //更新行驶证的url，如果更新失败，重置为原来的行驶证url
        NSString *oldurl = car.licenceurl;
        car.licenceurl = url;
        return [[gAppMgr.myUser.carModel rac_updateCar:car] catch:^RACSignal *(NSError *error) {
            car.licenceurl = oldurl;
            return [RACSignal error:error];
        }];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        car.status = 1;
        [subView setShowBottomButton:NO withText:[self.model descForCarStatus:car.status]];
        [gToast showSuccess:@"上传行驶证成功!"];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    HKMyCar *car = [self.loadingModel.datasource safetyObjectAtIndex:[self.scrollView currentPage]];
    self.model.currentCar = car;
    if (self.model.allowAutoChangeSelectedCar) {
        self.model.selectedCar = car;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    HKMyCar *car = [self.loadingModel.datasource safetyObjectAtIndex:[self.scrollView currentPage]];
    self.model.currentCar = car;
    if (self.model.allowAutoChangeSelectedCar) {
        self.model.selectedCar = car;
    }
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.hidden = YES;
    return @"暂无爱车，快去添加一辆吧";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.hidden = YES;
    return @"获取爱车信息失败，点击重试";
}

- (BOOL)loadingModelShouldAllowRefreshing:(HKLoadingModel *)model
{
    return NO;
}

- (void)loadingModel:(HKLoadingModel *)model didTappedForBlankPrompting:(NSString *)prompting type:(HKDatasourceLoadingType)type
{
    [self actionAddCar:nil];
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    RACSignal *signal;
    if (type == HKDatasourceLoadingTypeReloadData) {
        signal = [gAppMgr.myUser.carModel rac_fetchData];
    }
    else {
        signal = [gAppMgr.myUser.carModel rac_fetchData];
    }
    return [[signal map:^id(JTQueue *queue) {
        return [queue allObjects];
    }] skip:1];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    self.scrollView.hidden = NO;
    HKMyCar *defCar = [gAppMgr.myUser.carModel getDefalutCar];
    if (self.model.allowAutoChangeSelectedCar) {
        BOOL currentCarValid = self.model.currentCar ? [model.datasource containsObject:self.model.currentCar] : NO;
        if (currentCarValid && ![self.model.currentCar isEqual:self.model.selectedCar]) {
            self.model.selectedCar = self.model.currentCar;
        }
        else {
            self.model.selectedCar = defCar;
            self.model.currentCar = defCar;
        }
    }
    else {
        self.model.currentCar = defCar;
        if (![defCar isEqual:self.model.selectedCar]) {
            self.model.selectedCar = defCar;
        }
    }
    if (model.datasource.count >= 5) {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    else {
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(actionAddCar:)];
        [self.navigationItem setRightBarButtonItem:right animated:NO];
    }
    [self refreshScrollView];
}


@end
