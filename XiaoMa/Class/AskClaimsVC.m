//
//  askClaimsVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "AskClaimsVC.h"
#import "HKInclinedLabel.h"
#import "ClaimsHistoryVC.h"

@interface AskClaimsVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation AskClaimsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

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
        [self scenePhotoSectionAction];
    }
    else
    {
        [self historySectionAction];
    }
}

-(void)guideSectionAction
{
    
}

-(void)crimeReportSectionAction
{
//   @叶志成 改号码
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}

-(void)scenePhotoSectionAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"选取照片" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [sheet showInView:self.view];
    
//    [[sheet rac_buttonClickedSignal]subscribeNext:^(id x) {
//        
//    }];
    
//    [sheet bk_setHandler:^{
//        if ([UIImagePickerController isCameraAvailable])
//        {
//            self.imgPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//            [self presentViewController:self.imgPickerController animated:YES completion:nil];
//        }
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该设备不支持拍照" message:nil delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];
//            [alert show];
//        }
//    } forButtonAtIndex:0];
//    [sheet bk_setHandler:^{
//        MLSelectPhotoPickerViewController *pickerVC = [[MLSelectPhotoPickerViewController alloc] init];
//        // 默认显示相册里面的内容SavePhotos
//        pickerVC.status = PickerViewShowStatusCameraRoll;
//        [pickerVC showPickerVc:self];
//        pickerVC.maxCount = 6 - self.mArr.count;
//        __weak typeof(self) weakSelf = self;
//        pickerVC.callBack = ^(NSArray *assets){
//            [weakSelf assetsToImgs:assets];
//            [weakSelf reloadButtons];
//        };
//    } forButtonAtIndex:1];
}

-(void)historySectionAction
{
    ClaimsHistoryVC *testVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"ClaimsHistoryVC"];
    [self.navigationController pushViewController:testVC animated:YES];
}

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

@end
