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

@interface MutualInsAskClaimsVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MutualInsAskClaimsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            detailLabel.text = @"遭受严重事故请狂戳这里";
            
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
            
            titleLabel.text = @"理赔记录";
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
    
}

-(void)crimeReportSectionAction
{
//   @叶志成 改号码
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}

-(void)scenePageSectionAction
{
    [self getCarListData];
    [[MutualInsScencePhotoVM sharedManager]getNoticeArr];
    
}

-(void)historySectionAction
{
    MutualInsClaimsHistoryVC *claimsHistoryVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsClaimsHistoryVC"];
    [self.navigationController pushViewController:claimsHistoryVC animated:YES];
}

#pragma mark Utility

-(void)getCarListData
{
    GetCooperationMyCarOp *op = [[GetCooperationMyCarOp alloc]init];
    [[[op rac_postRequest]initially:^{
        [self.view startActivityAnimationWithType:MONActivityIndicatorType];
    }]subscribeNext:^(GetCooperationMyCarOp *op) {
        if (op.rsp_reports.count == 1)
        {
            NSDictionary *report = op.rsp_reports.firstObject;
            MutualInsScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"MutualInsScencePageVC" inStoryboard:@"MutualInsClaims"];
            scencePageVC.claimid = report[@"claimid"];
            [self.navigationController pushViewController:scencePageVC animated:YES];
        }
        else if (op.rsp_reports.count > 1)
        {
            MutualInsChooseCarVC *chooseVC = [UIStoryboard vcWithId:@"MutualInsChooseCarVC" inStoryboard:@"MutualInsClaims"];
            chooseVC.reports = op.rsp_reports;
            [self.navigationController pushViewController:chooseVC animated:YES];
        }
        else
        {
            [gToast showMistake:@"请先报案"];
        }
        [self.view stopActivityAnimation];
    }error:^(NSError *error) {
        [self.view stopActivityAnimation];
    }];
}


@end
