//
//  MutualInsAskClaimsVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsAskClaimsVC.h"
#import "HKInclinedLabel.h"
#import "MutualInsClaimsHistoryVC.h"
#import "MutualInsScencePhotoVC.h"
#import "MutualInsScencePageVC.h"
#import "GetCooperationMyCarOp.h"
#import "MutualInsChooseCarVC.h"
#import "MutualInsScencePhotoVM.h"
#import "GetCoorperationClaimConfigOp.h"
#import "HKImageAlertVC.h"

@interface MutualInsAskClaimsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *tempArr;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsAskClaimsVC

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsAskClaimsVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(setBackAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    
    UIView *backView = [cell viewWithTag:100];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    
    UIImageView *imageView = [cell viewWithTag:1000];
    HKInclinedLabel *hkLabel = [cell viewWithTag:1001];
    UILabel *titleLabel = [cell viewWithTag:1002];
    UILabel *detailLabel = [cell viewWithTag:1003];
    switch (indexPath.section)
    {
        case 0:
            
            imageView.image = [UIImage imageNamed:@"mutualIns_guiding"];
            
            hkLabel.fontSize = 14;
            hkLabel.hidden = NO;
            hkLabel.text = @"必读";
            hkLabel.backgroundColor = [UIColor clearColor];
            hkLabel.trapeziumColor = [UIColor colorWithHex:@"#18d06a" alpha:1];
            hkLabel.textColor = [UIColor whiteColor];
            
            titleLabel.text = @"新手引导";
            detailLabel.text = @"不知道怎么用请点击这里";
            
            break;
        case 1:
            
            imageView.image = [UIImage imageNamed:@"mutualIns_crimesReport"];
            
            titleLabel.text = @"我要报案";
            detailLabel.text = @"发生交通事故请狂戳这里";
            
            hkLabel.hidden = YES;
            break;
        case 2:
            
            imageView.image = [UIImage imageNamed:@"mutualIns_scenePhoto"];
            
            titleLabel.text = @"现场拍照";
            detailLabel.text = @"用拍照记录事故第一现场";
            
            hkLabel.hidden = YES;
            break;
        default:
            
            imageView.image = [UIImage imageNamed:@"mutualIns_claimsHistory"];
            
            titleLabel.text = @"补偿记录";
            detailLabel.text = @"小马伴您走过的点点滴滴";
            
            hkLabel.hidden = YES;
            break;
    }
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 15;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        [self guideSectionAction];
    }
    else if (indexPath.section == 1)
    {
        [self crimeReportSectionAction];
    }
    else if (indexPath.section == 2)
    {
        [self scenePageSectionAction];
    }
    else
    {
        [self historySectionAction];
    }
}

#pragma mark Action



-(void)guideSectionAction
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0002"}];
}

-(void)crimeReportSectionAction
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0003"}];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"快速报案可拨打客服电话：4007-111-111，是否立即拨打？" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (void)scenePageSectionAction
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0004"}];
    [self getNoticeArr];
    [self getCarListData];
}

-(void)historySectionAction
{
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0005"}];
    
    if (![LoginViewModel loginIfNeededForTargetViewController:self]) {
        return;
    }
    MutualInsClaimsHistoryVC *claimsHistoryVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsClaimsHistoryVC"];
    [self.navigationController pushViewController:claimsHistoryVC animated:YES];
}

#pragma mark Utility

-(void)setBackAction
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0001"}];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getNoticeArr
{
    GetCoorperationClaimConfigOp *op = [[GetCoorperationClaimConfigOp alloc]init];
    [[op rac_postRequest]subscribeNext:^(GetCoorperationClaimConfigOp *op) {
        self.tempArr = @[op.rsp_scenedesc,op.rsp_cardamagedesc,op.rsp_carinfodesc,op.rsp_idinfodesc];
    }];
}

-(void)getCarListData
{
    @weakify(self)
    if (![LoginViewModel loginIfNeededForTargetViewController:self]) {
        return;
    }
    else
    {
        GetCooperationMyCarOp *op = [[GetCooperationMyCarOp alloc]init];
        [[[op rac_postRequest]initially:^{
            @strongify(self)
            
            [gToast showingWithText:@"" inView:self.view];
        }]subscribeNext:^(GetCooperationMyCarOp *op) {
            @strongify(self)
            if (op.rsp_reports.count == 1)
            {
                NSDictionary *report = op.rsp_reports.firstObject;
                MutualInsScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"MutualInsScencePageVC" inStoryboard:@"MutualInsClaims"];
                scencePageVC.noticeArr = self.tempArr;
                scencePageVC.claimid = report[@"claimid"];
                [self.navigationController pushViewController:scencePageVC animated:YES];
            }
            else if (op.rsp_reports.count > 1)
            {
                MutualInsChooseCarVC *chooseVC = [UIStoryboard vcWithId:@"MutualInsChooseCarVC" inStoryboard:@"MutualInsClaims"];
                chooseVC.noticeArr = self.tempArr;
                chooseVC.reports = op.rsp_reports;
                [self.navigationController pushViewController:chooseVC animated:YES];
            }
            else
            {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
                HKAlertActionItem *makePhone = [HKAlertActionItem itemWithTitle:@"电话报案" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                    [gPhoneHelper makePhone:@"4007111111"];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"未检测到您的爱车有车险报案记录，快速补偿需要先报案后才能进行现场拍照。请先报案，谢谢～" ActionItems:@[cancel,makePhone]];
                [alert show];
            }
            [gToast dismissInView:self.view];
        }error:^(NSError *error) {
            @strongify(self)
            [gToast dismissInView:self.view];
        }];
    }
}


@end
