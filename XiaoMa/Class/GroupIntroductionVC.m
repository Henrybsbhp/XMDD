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
#import "MutualInsRequestJoinGroupVC.h"
#import "HKImageAlertVC.h"
#import "EditCarVC.h"

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
        [vc setFinishPickActionForMutualIns:^(MyCarListVModel * carModel, UIView * loadingView) {
            
            //爱车页面入团按钮委托实现
            [self requestApplyJoinGroupWithID:self.groupId groupName:self.groupName carModel:carModel loadingView:loadingView];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)requestApplyJoinGroupWithID:(NSNumber *)groupId groupName:(NSString *)groupName
                           carModel:(MyCarListVModel *)carModel loadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carModel.selectedCar.carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = rop.req_groupid;
        vc.groupName = groupName;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        if (error.code == 6115804) {
            [gToast dismissInView:view];
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = error.domain;
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
                [alertVC dismiss];
            }];
            @weakify(self);
            HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                [alertVC dismiss];
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                carModel.originVC = nil;  //设置为nil，返回爱车列表；或者用[UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
                vc.originCar = carModel.selectedCar;
                vc.model = carModel;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            alert.actionItems = @[cancel, improve];
            [alert show];
        }
        else {
            [gToast showError:error.domain inView:view];
        }
    }];
}


// 创建团
- (void)selfGroupTour
{
    CreateGroupVC * vc = [UIStoryboard vcWithId:@"CreateGroupVC" inStoryboard:@"MutualInsJoin"];
    vc.originVC = self.originVC;
    [self.navigationController pushViewController:vc animated:YES];
}

// 加入团
- (void)selfGroupJoin
{
    MutualInsRequestJoinGroupVC * vc = [UIStoryboard vcWithId:@"MutualInsRequestJoinGroupVC" inStoryboard:@"MutualInsJoin"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
