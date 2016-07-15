//
//  GroupIntroductionVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GroupIntroductionVC.h"
#import "MutualInsPicUpdateVC.h"
#import "CreateGroupVC.h"
#import "MutualInsRequestJoinGroupVC.h"
#import "MutualInsPickCarVC.h"
#import "HKImageAlertVC.h"

#import "ApplyCooperationGroupJoinOp.h"
#import "GetCooperationUsercarListOp.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    if (self.groupType == MutualGroupTypeSystem)
    {
        [self.selfGroupView removeFromSuperview];
        
        self.navigationItem.title = @"入团要求";
        [self.sysJoinBtn setTitle:@"加入互助" forState:UIControlStateNormal];
    }
    else
    {
        self.navigationItem.title = @"自组团介绍";
        
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
    NSString * linsenceUrlStr = @"http://dev01.xiaomadada.com/apphtml/view/agreement/v1.0/convention.html";
#elif XMDDEnvironment==1
    NSString * linsenceUrlStr = @"http://dev.xiaomadada.com/apphtml/view/agreement/v1.0/convention.html";
#else
    NSString * linsenceUrlStr = @"http://www.xiaomadada.com/apphtml/view/agreement/v1.0/convention.html";
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
    
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        CKAsyncMainQueue(^{
            self.navigationItem.title = title;
        });
    }
    
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
        
        GetCooperationUsercarListOp * op = [[GetCooperationUsercarListOp alloc] init];
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"获取车辆数据中..." inView:self.view];
        }] subscribeNext:^(GetCooperationUsercarListOp * x) {
            
            [gToast dismissInView:self.view];
            if (x.rsp_carArray.count)
            {
                MutualInsPickCarVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPickCarVC"];
                vc.mutualInsCarArray = x.rsp_carArray;
                [vc setFinishPickCar:^(HKMyCar *car) {
                    
                    [self gotoIdLicenseInfoupdateWithCar:car];
                }];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [self gotoIdLicenseInfoupdateWithCar:nil];
            }
        } error:^(NSError *error) {
            
            [gToast showError:@"获取失败，请重试" inView:self.view];
        }];
    }
}

- (void)gotoIdLicenseInfoupdateWithCar:(HKMyCar *)car
{
    MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
    vc.curCar = car;
    [self.navigationController pushViewController:vc animated:YES];
}


// 创建团
- (void)selfGroupTour
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        CreateGroupVC * vc = [UIStoryboard vcWithId:@"CreateGroupVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self.originVC;
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
