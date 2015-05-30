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
    
    self.datasource = @[@{@"title":@"去给小马达达评分",@"action":^(void){
        
        [self rateOurApp];
    }},
                        @{@"title":@"用户服务协议",@"action":^(void){
        [self serviceAgreement];
    }},
                        @{@"title":@"查看欢迎页",@"action":^(void){}},
                        
                        @{@"title":@"意见反馈",@"action":^(void){
                            [self gotoFeedback];
                        }},
                        
                        @{@"title":@"客服电话4007111111",@"action":^(void){
        
         [self callCustomerService];
    }}];
    
#ifdef DEBUG
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
#else
     NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#endif
    self.versionLb.text = version;

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
//    NSString *url = [NSString stringWithFormat:@""];
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
//    
//    DebugLog(@"Opening URL for Remarks: %@", url);
}

- (void)serviceAgreement
{
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"服务协议";
    vc.url = @"http://www.xiaomadada.com/apphtml/license.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)callCustomerService
{
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"呼叫客服"];
}

- (void)gotoFeedback
{
    FeedbackVC *vc = [UIStoryboard vcWithId:@"FeedbackVC" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
