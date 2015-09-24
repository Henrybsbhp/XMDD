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

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic,strong)NSArray * datasource;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef DEBUG
    self.datasource = @[@{@"title":@"用户服务协议",@"action":^(void){
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
#else
    self.datasource = @[@{@"title":@"用户服务协议",@"action":^(void){
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
    vc.url = @"http://www.xiaomadada.com/apphtml/license.html";
    [self.navigationController pushViewController:vc animated:YES];
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
    textField.text = @"http://";
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
@end
