//
//  GroupIntroductionVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GroupIntroductionVC.h"
#import "AutoGroupInfoVC.h"
#import "CarListVC.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "MutualInsPicUpdateVC.h"
#import "CreateGroupVC.h"

#define IntroUrl @"http://www.baidu.com"

@interface GroupIntroductionVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *sysGroupView;
@property (weak, nonatomic) IBOutlet UIView *selfGroupView;

@property (weak, nonatomic) IBOutlet UIButton *sysJoinBtn;
- (IBAction)joinAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *selfGroupTourBtn;
@property (weak, nonatomic) IBOutlet UIButton *selfGroupJoinBtn;


@end

@implementation GroupIntroductionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.webView.delegate = self;
    self.webView.hidden = YES;
    
    CKAsyncMainQueue(^{
        self.webView.scrollView.contentInset = UIEdgeInsetsZero;
        self.webView.scrollView.contentSize = self.webView.frame.size;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:IntroUrl]]];
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
            [self.sysJoinBtn setTitle:@"立即加入" forState:UIControlStateNormal];
        }
        else if (self.btnType == BtnTypeAlready){
            [self.sysJoinBtn setTitle:@"再加一辆车" forState:UIControlStateNormal];
        }
        else {
            self.sysJoinBtn.enabled = NO;
            [self.sysJoinBtn setTitle:@"已结束" forState:UIControlStateNormal];
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

- (IBAction)joinAction:(id)sender {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
        vc.title = @"选择爱车";
        vc.model.allowAutoChangeSelectedCar = YES;
        vc.model.disableEditingCar = YES; //不可修改
        vc.canJoin = YES; //用于控制爱车页面底部view
        vc.model.originVC = self;
        [vc setFinishPickActionForMutualIns:^(HKMyCar *car,UIView * loadingView) {
            
            //爱车页面入团按钮委托实现
            [self requestApplyJoinGroup:self.groupId andCarId:car.carId andLoadingView:loadingView];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)requestApplyJoinGroup:(NSNumber *)groupId andCarId:(NSNumber *)carId andLoadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain inView:view];
    }];
}

- (void)selfGroupTour
{
    CreateGroupVC * vc = [UIStoryboard vcWithId:@"CreateGroupVC" inStoryboard:@"MutualInsJoin"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selfGroupJoin
{

}
@end
