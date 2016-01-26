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
                        }}];
    }
    else
    {
        @weakify(self)
        self.datasource = @[@{@"title":@"使用帮助",@"action":^(void){
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
    [MobClick event:@"rp322-1"];
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
    [MobClick event:@"rp110-1"];
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.sceneType = ShareSceneLocalShare;
    vc.btnTypeArr = @[@1, @2, @3, @4];
    vc.tt = @"小马达达－洗车1分钱都不要";
    vc.subtitle = @"我正在使用小马达达，洗车1分钱也不要，你也来试试吧！";
    vc.image = [UIImage imageNamed:@"wechat_share_carwash"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_carwash"];
    vc.urlStr = kAppShareUrl;
    
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
    
    //单例模式下，不需要处理回调应将单例的block设置为空，否则将执行上次set的block
    [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
        
    }];
    [[ShareResponeManagerForQQ init] setFinishAction:^(NSString * code, ShareResponseType type){
        
    }];

}

- (void)callCustomerService
{
    [MobClick event:@"rp322-3"];
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
    
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
        
        NSInteger i = [n integerValue];
        if (i == 1)
        {
            DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
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
    /**
     *  商户加盟点击事件
     */
    [MobClick event:@"rp322-4"];
    JoinUsViewController * vc = [UIStoryboard vcWithId:@"JoinUsViewController" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
