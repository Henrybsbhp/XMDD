//
//  AboutViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AboutViewController.h"
#import "JTTableView.h"
#import "FeedbackVC.h"
#import "SocialShareViewController.h"
#import "JoinUsViewController.h"
#import "GetShareButtonOpV2.h"
#import "ShareResponeManager.h"
#import "ReactTestViewController.h"
#import "RRFPSBar.h"
#import "ScanQRCodeVC.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLb;
- (IBAction)joinAction:(id)sender;
@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic,strong)NSArray * datasource;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef DEBUG
    if (gAppMgr.canShareFlag)
    {
        @weakify(self)
    self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
        
                            @strongify(self)
                            [self gotoInstructions];
                        }},
                        
                        @{@"title":@"推荐App给好友",@"action":^(void){
                            
                            @strongify(self)
                            [self shareApp];
                        }},
                        
                        @{@"title":@"用户服务协议",@"action":^(void){
                            
                            @strongify(self)
                            [self serviceAgreement];
                        }},
                        
                        @{@"title":@"前往评价",@"action":^(void){
                            
                            @strongify(self)
                            [self rateOurApp];
                        }},
                        
                        @{@"title":@"意见反馈",@"action":^(void){
                            
                            @strongify(self)
                            [self gotoFeedback];
                        }},
                        
                        @{@"title":@"客服电话4007-111-111",@"action":^(void){
                            
                            @strongify(self)
                            [self callCustomerService];
                        }},
                        
                        @{@"title":@"网页跳转",@"action":^(void){
                            
                            @strongify(self)
                            [self gotoTestWeb];
                        }},
                        @{@"title":@"环境切换",@"action":^(void){
                            
                            @strongify(self)
                            [self switchSurrounding];
                        }},
                        @{@"title":@"FPS开关",@"action":^(void){
                            
                            @strongify(self)
                            [self setupFPSObserver];
                        }},@{@"title":@"RCT",@"action":^(void){
                            
                            @strongify(self)
                            [self actionRCT];
                        }},@{@"title":@"RCT2",@"action":^(void){
                            
                            @strongify(self)
                            [self actionRCT2];
                        }}, @{@"title":@"网络请求参数开关",@"action":^(void){
                            
                            @strongify(self)
                            [self actionShowRequestParamsAlert];
                        }}, @{@"title":@"二维码扫描",@"action":^(void){
                            
                            @strongify(self);
                            [self goToQRScanVC];
                        }}];
    }
    else
    {
        @weakify(self)
        self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
            
            @strongify(self)
            [self gotoInstructions];
        }},
                            
                            
                            @{@"title":@"用户服务协议",@"action":^(void){
                                
                                @strongify(self)
                                [self serviceAgreement];
                            }},
                            
                            @{@"title":@"前往评价",@"action":^(void){
                                
                                @strongify(self)
                                [self rateOurApp];
                            }},
                            
                            @{@"title":@"意见反馈",@"action":^(void){
                                
                                @strongify(self)
                                [self gotoFeedback];
                            }},
                            
                            @{@"title":@"客服电话4007-111-111",@"action":^(void){
                                
                                @strongify(self)
                                [self callCustomerService];
                            }},
                            
                            @{@"title":@"网页跳转",@"action":^(void){
                                
                                @strongify(self)
                                [self gotoTestWeb];
                            }},
                            @{@"title":@"环境切换",@"action":^(void){
                                
                                @strongify(self)
                                [self switchSurrounding];
                            }},
                            @{@"title":@"FPS开关",@"action":^(void){
                                
                                @strongify(self)
                                [self setupFPSObserver];
                            }},@{@"title":@"RCT",@"action":^(void){
                                
                                @strongify(self)
                                [self actionRCT];
                            }},@{@"title":@"RCT2",@"action":^(void){
                                
                                @strongify(self)
                                [self actionRCT2];
                            }}, @{@"title":@"网络请求参数开关",@"action":^(void){
                                
                                @strongify(self)
                                [self actionShowRequestParamsAlert];
                            }}, @{@"title":@"二维码扫描",@"action":^(void){
                                
                                @strongify(self);
                                [self goToQRScanVC];
                            }}];
    }
#else
    if (gAppMgr.canShareFlag)
    {
        @weakify(self)
    self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
        
                            @strongify(self)
                            [self gotoInstructions];
                        }},
                        
                        @{@"title":@"推荐App给好友",@"action":^(void){
                            
                            @strongify(self)
                            [self shareApp];
                        }},
                        
                        @{@"title":@"用户服务协议",@"action":^(void){
                            
                            @strongify(self)
                            [self serviceAgreement];
                        }},
                        
                        @{@"title":@"前往评价",@"action":^(void){
                            
                            @strongify(self)
                            [self rateOurApp];
                        }},
                        
                        @{@"title":@"意见反馈",@"action":^(void){
                            
                            @strongify(self)
                            [self gotoFeedback];
                        }},
                        
                        @{@"title":@"客服电话4007-111-111",@"action":^(void){
                            
                            @strongify(self)
                            [self callCustomerService];
                        }}];
    }
    else
    {
        @weakify(self)
        self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
            
            @strongify(self)
            [self gotoInstructions];
        }},
                            
                            @{@"title":@"用户服务协议",@"action":^(void){
                                
                                @strongify(self)
                                [self serviceAgreement];
                            }},
                            
                            @{@"title":@"前往评价",@"action":^(void){
                                
                                @strongify(self)
                                [self rateOurApp];
                            }},
                            
                            @{@"title":@"意见反馈",@"action":^(void){
                                
                                @strongify(self)
                                [self gotoFeedback];
                            }},
                            
                            @{@"title":@"客服电话4007-111-111",@"action":^(void){
                                
                                @strongify(self)
                                [self callCustomerService];
                            }}];
    }
#endif
    
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
#ifndef DEBUG
    #if XMDDENT == 0
    version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    #endif
#endif
    
    self.versionLb.text = version;
    
    

}


- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"AboutViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell" forIndexPath:indexPath];
    UILabel * lb = (UILabel *)[cell searchViewWithTag:101];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    lb.text = [dict objectForKey:@"title"];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    typedef void(^MyBlock)(void);
    MyBlock area = dict[@"action"];
    area();
}

#pragma mark - Utilitly
- (void)rateOurApp
{
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/xiao-ma-da-da-xi-che-zhi-yao1fen/id991665445&mt=8"];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
}

- (void)serviceAgreement
{
    [MobClick event:@"rp322_1"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"服务协议";
    vc.url = kServiceLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoInstructions
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"使用帮助";
    vc.url = kServiceHelpUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) shareApp
{
    [MobClick event:@"rp110_1"];
    [gToast showingWithText:@"分享信息拉取中..."];
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneInsurance;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneAppAbout;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110-7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)callCustomerService
{
    [MobClick event:@"rp322_3"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}

- (void)gotoFeedback
{
    [MobClick event:@"rp322-2"];
    FeedbackVC *vc = [UIStoryboard vcWithId:@"FeedbackVC" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoTestWeb
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请输入网址" message:@"" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往",nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [av textFieldAtIndex:0];
    textField.text = @"https://";
    [av show];
    
    @weakify(self);
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
        @strongify(self)
        NSInteger i = [n integerValue];
        if (i == 1)
        {
            DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
            vc.url = textField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
}

- (void)goToQRScanVC
{
    ScanQRCodeVC *vc = [[ScanQRCodeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchSurrounding
{
    gAppMgr.isSwitchToFormalSurrounding = !gAppMgr.isSwitchToFormalSurrounding;
}

- (IBAction)joinAction:(id)sender {
    /**
     *  商户加盟点击事件
     */
    [MobClick event:@"rp322_4"];
    JoinUsViewController * vc = [UIStoryboard vcWithId:@"JoinUsViewController" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - FPS
- (void)setupFPSObserver
{
    [gAssistiveMgr showFPSObserver];
}

#pragma mark - RN
- (void)actionRCT
{
    ReactTestViewController * vc = [aboutStoryboard instantiateViewControllerWithIdentifier:@"ReactTestViewController"];
    vc.modulName = @"MyInfoView";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionRCT2
{
    ReactTestViewController * vc = [aboutStoryboard instantiateViewControllerWithIdentifier:@"ReactTestViewController"];
    vc.modulName = @"helloworld";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Network request parameters
- (void)actionShowRequestParamsAlert {
    [gAssistiveMgr switchShowLogWithAlertView];
}

@end
