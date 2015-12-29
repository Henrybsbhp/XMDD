//
//  GainAwardViewController.m
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GainAwardViewController.h"
#import "GainUserAwardOp.h"
#import "GainedViewController.h"
#import "AwardShareSheetVC.h"
#import "SocialShareViewController.h"
#import "ShareResponeManager.h"
#import "AwardOtherSheetVC.h"
#import "CarWashTableVC.h"
#import "SharedNotifyOp.h"
#import "GetShareButtonOp.h"

@interface GainAwardViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GainAwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp401"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp401"];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"GainAwardViewController dealloc");
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger width = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    CGFloat height;
    switch (width) {
        case 320:
            height = 506;
            break;
        case 375:
            height = 606;
            break;
        case 414:
            height = 674;
            break;
        default:
            height = 504;
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    
    UIImageView * bgView = (UIImageView *)[cell searchViewWithTag:101];
//    UIImageView * elementView = (UIImageView *)[cell searchViewWithTag:102];
    UIButton * gainBtn = (UIButton *)[cell searchViewWithTag:103];
    UILabel * numLb = (UILabel *)[cell searchViewWithTag:104];
//    UILabel * tipLb = (UILabel *)[cell searchViewWithTag:105];
    
    NSInteger deviceWidth = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    NSString * imageName = [NSString stringWithFormat:@"award_bg_%ld",(long)deviceWidth];
    bgView.image = [UIImage imageNamed:imageName];
    
    @weakify(self);
    [[[gainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {

        @strongify(self);
        [MobClick event:@"rp401-1"];
        [self requestGainAward];
    }];
    
    
    numLb.text = [NSString stringWithFormat:@"已有%ld人领取",(long)self.gainedNum];
    
    return cell;
}

#pragma mark - Utilitly
- (void)requestGainAward
{
    GainUserAwardOp * op = [GainUserAwardOp operation];
    op.req_province = gMapHelper.addrComponent.province;
    op.req_city = gMapHelper.addrComponent.city;
    op.req_district = gMapHelper.addrComponent.district;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"抢红包啦..."];
    }] subscribeNext:^(GainUserAwardOp * op) {
        
        @strongify(self);
        
        [gToast dismiss];
        
        AwardShareSheetVC * sheetVC = [awardStoryboard instantiateViewControllerWithIdentifier:@"AwardShareSheetVC"];
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(300, 400) viewController:sheetVC];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[sheetVC.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                [self shareAction];
            }];
        }];
        
        [[sheetVC.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        GainedViewController * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"GainedViewController"];
        vc.amount = op.rsp_amount;
        vc.tip = op.rsp_tip;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)shareAction
{
    GetShareButtonOp * op = [GetShareButtonOp operation];
    op.pagePosition = ShareSceneGain;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOp * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneGain;    //页面位置
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
        
        [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
            
            @strongify(self)
            [self handleResultCode:code from:type forSheet:sheet];
        }];
        [[ShareResponeManagerForQQ init] setFinishAction:^(NSString * code, ShareResponseType type){
            
            @strongify(self)
            [self handleResultCode:[code integerValue] from:type forSheet:sheet];
        }];
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)handleResultCode:(NSInteger)code from:(ShareResponseType)type forSheet:(MZFormSheetController *)sheet
{
    @weakify(self);
    [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
        if (code == 0) {
            SharedNotifyOp * op = [SharedNotifyOp operation];
            [gToast showingWithoutText];
            [[op rac_postRequest] subscribeNext:^(SharedNotifyOp * op) {
                
                @strongify(self);
                [gToast dismiss];
                if (op.rsp_flag == AwardSheetTypeSuccess) {
                    [self presentSheet:AwardSheetTypeSuccess];
                }
                else {
                    [self presentSheet:AwardSheetTypeAlreadyget];
                }
            } error:^(NSError *error) {
                [gToast dismiss];
            }];
        }
        else if (type ==ShareResponseWechat && code == -2) {
            [self presentSheet:AwardSheetTypeCancel];
        }
        else if (type == ShareResponseWeibo && code == -1) {
            [self presentSheet:AwardSheetTypeCancel];
        }
        else if (type == ShareResponseQQ && code == -4) {
            [self presentSheet:AwardSheetTypeCancel];
        }
        else {
            [self presentSheet:AwardSheetTypeFailure];
        }
    }];
}

- (void)presentSheet:(AwardSheetType)type
{
    AwardOtherSheetVC * otherVC = [awardStoryboard instantiateViewControllerWithIdentifier:@"AwardOtherSheetVC"];
    otherVC.sheetType = type;
    MZFormSheetController *resultSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(300, 200) viewController:otherVC];
    resultSheet.shouldCenterVertically = YES;
    [resultSheet presentAnimated:YES completionHandler:nil];
    
    [[otherVC.carwashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [resultSheet dismissAnimated:YES completionHandler:nil];
        CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
        vc.type = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[otherVC.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [resultSheet dismissAnimated:YES completionHandler:nil];
    }];
}

@end
