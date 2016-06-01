//
//  GroupIntroductionVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GroupIntroductionVC.h"
#import "SystemGroupListVC.h"
#import "PickCarVC.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "MutualInsPicUpdateVC.h"
#import "CreateGroupVC.h"
#import "MutualInsRequestJoinGroupVC.h"
#import "HKImageAlertVC.h"
#import "EditCarVC.h"
#import "JTAttributedLabel.h"


@interface GroupIntroductionVC () <UIWebViewDelegate,TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *sysGroupView;
@property (weak, nonatomic) IBOutlet UIView *selfGroupView;

@property (weak, nonatomic) IBOutlet UIButton *sysJoinBtn;
- (IBAction)joinAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *selfGroupTourBtn;
@property (weak, nonatomic) IBOutlet UIButton *selfGroupJoinBtn;

@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *linsenceLb;
@property (nonatomic)BOOL linsenceFlag;



@end

@implementation GroupIntroductionVC

- (void)dealloc
{
    DebugLog(@"GroupIntroductionVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.webView.delegate = self;
    self.webView.hidden = YES;
    
    NSString * urlStr;
    
    if (self.groupType == MutualGroupTypeSystem)
    {
        urlStr = self.groupIntrUrlStr;
    }
    else
    {
#if XMDDEnvironment==0
    urlStr = @"http://dev01.xiaomadada.com/apphtml/neicejihua.html";
#elif XMDDEnvironment==1
    urlStr = @"http://dev.xiaomadada.com/apphtml/neicejihua.html";
#else
    urlStr = @"http://www.xiaomadada.com/apphtml/neicejihua.html";
#endif
    }
    
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    });
}

#pragma mark - SetupUI
- (void)setupUI
{
    self.navigationItem.title = self.titleStr;
    
    if (self.groupType == MutualGroupTypeSystem)
    {
        [self.selfGroupView removeFromSuperview];
        if (self.btnType == BtnTypeJoinNow) {
            [self.sysJoinBtn setTitle:@"申请加入" forState:UIControlStateNormal];
        }
        else if (self.btnType == BtnTypeAlready) {
            [self.sysJoinBtn setTitle:@"再加一辆车" forState:UIControlStateNormal];
        }
        else if (self.btnType == BtnTypeNotStart) {
            self.sysJoinBtn.enabled = NO;
            [self.sysJoinBtn setTitle:@"未开始" forState:UIControlStateNormal];
            [self.sysJoinBtn setBackgroundColor:kLightLineColor];
        }
        else {
            self.sysGroupView.hidden = YES;
            self.bottomConstraint.constant = 0;
        }
    }
    else
    {
        [self.sysGroupView removeFromSuperview];
        
        [[self.selfGroupJoinBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self selfGroupJoin];
        }];
        
        [[self.selfGroupTourBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self selfGroupTour];
        }];
    }
    
    NSString * linsenceText = @"我已阅读并同意《小马互助公约》";
    
#if XMDDEnvironment==0
    NSString * linsenceUrlStr = @"http://dev01.xiaomadada.com/apphtml/view/agreement-beta1.0/convention.html";
#elif XMDDEnvironment==1
    NSString * linsenceUrlStr = @"http://dev.xiaomadada.com/apphtml/view/agreement-beta1.0/convention.html";
#else
    NSString * linsenceUrlStr = @"http://www.xiaomadada.com/apphtml/view/agreement-beta1.0/convention.html";
#endif

    NSAttributedString *attstr = [[NSAttributedString alloc] initWithString:linsenceText
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                              NSForegroundColorAttributeName: HEXCOLOR(@"#9a9a9a")}];
    
    self.linsenceLb.delegate = self;
    self.linsenceLb.attributedText = attstr;
    [self.linsenceLb setLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                               NSForegroundColorAttributeName: HEXCOLOR(@"#007aff")}];
    [self.linsenceLb setActiveLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                     NSForegroundColorAttributeName: kGrayTextColor}];
    [self.linsenceLb addLinkToURL:[NSURL URLWithString:linsenceUrlStr] withRange:NSMakeRange(linsenceText.length - 8, 8)];
    
    self.linsenceFlag = YES;
    
    @weakify(self)
    [[self.checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        self.linsenceFlag = !self.linsenceFlag;
    }];
    
    [RACObserve(self, linsenceFlag) subscribeNext:^(NSNumber * number) {
        
        BOOL flag = [number boolValue];
        self.checkBtn.selected = flag;
        
        self.sysJoinBtn.enabled = flag;
        [self.sysJoinBtn setBackgroundColor:flag?kDefTintColor:kLightLineColor];
        self.selfGroupJoinBtn.enabled = flag;
        [self.selfGroupJoinBtn setBackgroundColor:flag?kDefTintColor:kLightLineColor];
        self.selfGroupTourBtn.enabled = flag;
        [self.selfGroupTourBtn setBackgroundColor:flag?kOrangeColor:kLightLineColor];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view stopActivityAnimation];
    DebugLog(@"%@ WebViewLoadError:%@\n,error=%@", kErrPrefix, webView.request.URL, error);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    self.webView.scrollView.contentSize = self.webView.frame.size;
    [gToast showError:kDefErrorPormpt];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    DebugLog(@"%@ WebViewStartLoad:%@", kReqPrefix, webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view stopActivityAnimation];
    self.webView.hidden = NO;
    DebugLog(@"%@ WebViewFinishLoad:%@", kRspPrefix, webView.request.URL);
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"qurutuan" : @"qurutuan0009"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)joinAction:(id)sender {
    [MobClick event:@"xiaomahuzhu" attributes:@{@"qurutuan" : @"qurutuan0010"}];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        if (self.originCarId) {
            [self requestApplyJoinGroupWithCarId:self.originCarId];
        }
        
        else {
            PickCarVC *vc = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
            vc.isShowBottomView = YES;
            vc.model.originVC = self;
            @weakify(self);
            [vc setFinishPickCar:^(MyCarListVModel *carModel, UIView * loadingView) {
                @strongify(self);
                //爱车页面入团按钮委托实现
                [self requestApplyJoinGroupWithID:self.groupId groupName:self.groupName carModel:carModel loadingView:loadingView];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)requestApplyJoinGroupWithCarId:(NSNumber *)carId
{
    @weakify(self);
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = self.groupId;
    op.req_carid = carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:self.view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        @strongify(self);
        
        [gToast dismissInView:self.view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = rop.req_groupid;
        vc.groupName = self.groupName;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        if (error.code == 6115804) {
            @strongify(self);
            [self showAlertWithError:error.domain carId:self.originCarId];
        }
        else {
            [gToast showError:error.domain inView:self.view];
        }
    }];
}

- (void)showAlertWithError:(NSString *)errorString carId:(NSNumber *)carId
{
    [gToast dismissInView:self.view];
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"温馨提示";
    alert.imageName = @"mins_bulb";
    alert.message = errorString;
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    @weakify(self);
    HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        @strongify(self);
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        vc.originCarId = carId;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    alert.actionItems = @[cancel, improve];
    [alert show];
}

- (void)requestApplyJoinGroupWithID:(NSNumber *)groupId groupName:(NSString *)groupName carModel:(MyCarListVModel *)carModel loadingView:(UIView *)view
{
    @weakify(self);
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carModel.selectedCar.carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        @strongify(self);
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = rop.req_groupid;
        vc.groupName = groupName;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        if (error.code == 6115804) {
            @strongify(self);
            [self showErrorAlertInView:view error:error.domain carModel:carModel];
        }
        else {
            [gToast showError:error.domain inView:view];
        }
    }];
}

- (void)showErrorAlertInView:(UIView *)view error:(NSString *)errorString carModel:(MyCarListVModel *)carModel
{
    [gToast dismissInView:view];
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"温馨提示";
    alert.imageName = @"mins_bulb";
    alert.message = errorString;
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    @weakify(self);
    HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        @strongify(self);
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        carModel.originVC = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
        vc.originCar = carModel.selectedCar;
        vc.model = carModel;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    alert.actionItems = @[cancel, improve];
    [alert show];
}

// 创建团
- (void)selfGroupTour
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        CreateGroupVC * vc = [UIStoryboard vcWithId:@"CreateGroupVC" inStoryboard:@"MutualInsJoin"];
        //    vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 加入团
- (void)selfGroupJoin
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        MutualInsRequestJoinGroupVC * vc = [UIStoryboard vcWithId:@"MutualInsRequestJoinGroupVC" inStoryboard:@"MutualInsJoin"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = [url absoluteString];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
