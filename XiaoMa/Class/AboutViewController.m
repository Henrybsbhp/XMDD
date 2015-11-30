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
#import "WebVC.h"
#import "SocialShareViewController.h"
#import "JoinUsViewController.h"
#import "GetShareButtonOp.h"
#import "ShareResponeManager.h"

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
    self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
                            [self gotoInstructions];
                        }},
                        
                        @{@"title":@"推荐App给好友",@"action":^(void){
                            [self shareApp];
                        }},
                        
                        @{@"title":@"用户服务协议",@"action":^(void){
                            [self serviceAgreement];
                        }},
                        
                        @{@"title":@"前往评价",@"action":^(void){
                            [self rateOurApp];
                        }},
                        
                        @{@"title":@"意见反馈",@"action":^(void){
                            [self gotoFeedback];
                        }},
                        
                        @{@"title":@"客服电话4007-111-111",@"action":^(void){
                            [self callCustomerService];
                        }},
                        
                        @{@"title":@"网页跳转",@"action":^(void){
                            
                            [self gotoTestWeb];
                        }},
                        @{@"title":@"环境切换",@"action":^(void){
                            
                            [self switchSurrounding];
                        }}];
    }
    else
    {
        self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
            [self gotoInstructions];
        }},
                            
                            
                            @{@"title":@"用户服务协议",@"action":^(void){
                                [self serviceAgreement];
                            }},
                            
                            @{@"title":@"前往评价",@"action":^(void){
                                [self rateOurApp];
                            }},
                            
                            @{@"title":@"意见反馈",@"action":^(void){
                                [self gotoFeedback];
                            }},
                            
                            @{@"title":@"客服电话4007-111-111",@"action":^(void){
                                [self callCustomerService];
                            }},
                            
                            @{@"title":@"网页跳转",@"action":^(void){
                                
                                [self gotoTestWeb];
                            }},
                            @{@"title":@"环境切换",@"action":^(void){
                                
                                [self switchSurrounding];
                            }}];
    }
#else
    if (gAppMgr.canShareFlag)
    {
    self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
                            [self gotoInstructions];
                        }},
                        
                        @{@"title":@"推荐App给好友",@"action":^(void){
                            [self shareApp];
                        }},
                        
                        @{@"title":@"用户服务协议",@"action":^(void){
                            [self serviceAgreement];
                        }},
                        
                        @{@"title":@"前往评价",@"action":^(void){
                            [self rateOurApp];
                        }},
                        
                        @{@"title":@"意见反馈",@"action":^(void){
                            [self gotoFeedback];
                        }},
                        
                        @{@"title":@"客服电话4007-111-111",@"action":^(void){
                            
                            [self callCustomerService];
                        }}];
    }
    else
    {
        self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
            [self gotoInstructions];
        }},
                            
                            @{@"title":@"用户服务协议",@"action":^(void){
                                [self serviceAgreement];
                            }},
                            
                            @{@"title":@"前往评价",@"action":^(void){
                                [self rateOurApp];
                            }},
                            
                            @{@"title":@"意见反馈",@"action":^(void){
                                [self gotoFeedback];
                            }},
                            
                            @{@"title":@"客服电话4007-111-111",@"action":^(void){
                                
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"rp322"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp322"];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
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
    [MobClick event:@"rp322-1"];
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"服务协议";
    vc.url = kServiceLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoInstructions
{
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"使用帮助";
    vc.url = kServiceHelpUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) shareApp
{
    [MobClick event:@"rp110-1"];
    
    GetShareButtonOp * op = [GetShareButtonOp operation];
    op.pagePosition = ShareSceneAbout;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOp * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneAbout;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns;  //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110-7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[ShareResponeManager init] setFinishAction:^ (NSInteger code){
            DebugLog(@"code:%ld!", (long)code);
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [[ShareResponeManagerForQQ init] setFinishAction:^ (NSString * code){
            DebugLog(@"code:%@!", code);
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
    } error:^(NSError *error) {
        
        //调试
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneAbout;    //页面位置
        vc.btnTypeArr = @[@1, @2, @3, @4]; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110-7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[ShareResponeManager init] setFinishAction:^ (NSInteger code){
            DebugLog(@"code:%ld!", (long)code);
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [[ShareResponeManagerForQQ init] setFinishAction:^ (NSString * code){
            DebugLog(@"code:%@!", code);
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
    }];
}

- (void)callCustomerService
{
    [MobClick event:@"rp322-3"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"呼叫客服"];
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
    
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
        
        NSInteger i = [n integerValue];
        if (i == 1)
        {
            WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
            vc.url = textField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
}

- (void)switchSurrounding
{
    gAppMgr.isSwitchToFormalSurrounding = !gAppMgr.isSwitchToFormalSurrounding;
}

- (IBAction)joinAction:(id)sender {
    JoinUsViewController * vc = [UIStoryboard vcWithId:@"JoinUsViewController" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
