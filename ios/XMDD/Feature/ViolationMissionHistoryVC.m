//
//  ViolationMissionHistoryVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationMissionHistoryVC.h"
#import "ViolationMyLicenceVC.h"
#import "ViolationPayConfirmVC.h"
#import "WebVC.h"
#import "ViolationCommissionStateVC.h"
#import "GetViolationCommissionApplyOp.h"
#import "NSString+RectSize.h"

@interface ViolationMissionHistoryVC ()
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) WebVC *webVC;

@property (strong, nonatomic) NSArray *tips;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSDictionary *statusDic;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation ViolationMissionHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    //    [self getSimutateData];
    [self getViolationCommissionApply];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

-(void)setupUI
{
    NSString *btnTitle = @"请选择您需要代办的违章";
    
    self.commitBtn.enabled = (self.indexPath != nil);
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    self.commitBtn.backgroundColor = self.indexPath != nil ? HEXCOLOR(@"#FF7428") : HEXCOLOR(@"#d3d3d3");
    [self.commitBtn setTitle:btnTitle forState:UIControlStateNormal];
}

#pragma mark - Network

-(void)getSimutateData
{
    self.bottomView.hidden = YES;
    self.tableView.hidden = YES;
    [self.view hideDefaultEmptyView];
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    
    CKAfter(0.5, ^{
        if (random()%2)
        {
            
            
            [self.view stopActivityAnimation];
            
            self.bottomView.hidden = NO;
            self.tableView.hidden = NO;
            
            
            NSDictionary *dic = @{@"date":@"2015-11-25 17:00",
                                  @"area":@"[浙江衢州] S33龙丽温高速丽水方向16KM889M",
                                  @"act":@"驾驶中型以上载客载货汽车、危险物品运输车辆以外的其它机动车行驶超过规定时速10%未达20%",
                                  @"code":@"100",
                                  @"money":@"200",
                                  @"servicefee":@"40",
                                  @"licencenumber":@"浙A12345",
                                  @"status" : @(0)};
            NSDictionary *dic1 = @{@"date":@"2015-11-25 17:00",
                                   @"area":@"[浙江衢州] S33龙丽温高速丽水方向16KM889M",
                                   @"act":@"驾驶中型以上载客载货汽车、危险物品运输车辆以外的其它机动车行驶超过规定时速10%未达20%",
                                   @"code":@"100",
                                   @"money":@"200",
                                   @"servicefee":@"40",
                                   @"licencenumber":@"浙A12345",
                                   @"status" : @(1)};
            NSDictionary *dic2 = @{@"date":@"2015-11-25 17:00",
                                   @"area":@"[浙江衢州] S33龙丽温高速丽水方向16KM889M",
                                   @"act":@"驾驶中型以上载客载货汽车、危险物品运输车辆以外的其它机动车行驶超过规定时速10%未达20%",
                                   @"code":@"100",
                                   @"money":@"200",
                                   @"servicefee":@"40",
                                   @"licencenumber":@"浙A12345",
                                   @"status" : @(2)};
            NSDictionary *dic3 = @{@"date":@"2015-11-25 17:00",
                                   @"area":@"[浙江衢州] S33龙丽温高速丽水方向16KM889M",
                                   @"act":@"驾驶中型以上载客载货汽车、危险物品运输车辆以外的其它机动车行驶超过规定时速10%未达20%",
                                   @"code":@"100",
                                   @"money":@"200",
                                   @"servicefee":@"40",
                                   @"licencenumber":@"浙A12345",
                                   @"status" : @(3)};
            NSDictionary *dic4 = @{@"date":@"2015-11-25 17:00",
                                   @"area":@"[浙江衢州] S33龙丽温高速丽水方向16KM889M",
                                   @"act":@"驾驶中型以上载客载货汽车、危险物品运输车辆以外的其它机动车行驶超过规定时速10%未达20%",
                                   @"code":@"100",
                                   @"money":@"100",
                                   @"servicefee":@"35",
                                   @"licencenumber":@"浙A12345",
                                   @"status" : @(1)};
            NSDictionary *dic6 = @{@"date":@"2015-11-25 17:00",
                                   @"area":@"[浙江衢州] S33龙丽温高速丽水方向16KM889M",
                                   @"act":@"驾驶中型以上载客载货汽车、危险物品运输车辆以外的其它机动车行驶超过规定时速10%未达20%",
                                   @"code":@"100",
                                   @"money":@"200",
                                   @"servicefee":@"40",
                                   @"licencenumber":@"浙A12345",
                                   @"status" : @(6)};
            self.tips = @[@"浙A12345的证件信息不完整，完善后即可申请代办"];
            self.dataSource = @[dic1,dic,dic2,dic3,dic4,dic6,dic4,dic1,dic3,dic2,dic,dic6,dic2,dic1,dic,dic6];
            
            [self.tableView reloadData];
        }
        else
        {
            [self.view stopActivityAnimation];
            
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击请重试" tapBlock:^{
                
                
                [self getSimutateData];
                
            }];
        }
    });
    
}

-(void)getViolationCommissionApply
{
    @weakify(self)
    GetViolationCommissionApplyOp *op = [GetViolationCommissionApplyOp operation];
    
    
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        
        self.bottomView.hidden = YES;
        self.tableView.hidden = YES;
        
        [self.view hideDefaultEmptyView];
        
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }]subscribeNext:^(GetViolationCommissionApplyOp *op) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        if (op.rsp_lists.count == 0)
        {
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"暂无代办记录"];
        }
        else
        {
            self.bottomView.hidden = NO;
            self.tableView.hidden = NO;
            
            self.dataSource = op.rsp_lists;
            self.tips = op.rsp_tipslist;
            [self.tableView reloadData];
        }
        
    } error:^(NSError *error) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击请重试" tapBlock:^{
            
            @strongify(self)
            
            [self getViolationCommissionApply];
            
        }];
        
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count + self.tips.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UITableViewCell *cell = nil;
    if (indexPath.row < self.tips.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"IssuesCell"];
        NSDictionary *dic = self.tips[indexPath.row];
        UILabel *tipLabel = [cell viewWithTag:100];
        tipLabel.text = [NSString stringWithFormat:@"%@",dic[@"tip"]];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MissionCell"];
        NSDictionary *data = [self.dataSource safetyObjectAtIndex:indexPath.row - self.tips.count];
        
        UILabel *moneyLabel = [cell viewWithTag:100];
        moneyLabel.text = [NSString stringWithFormat:@"罚款%@元",data[@"money"]];
        
        UILabel *serviceFeeLabel = [cell viewWithTag:101];
        serviceFeeLabel.text = [NSString stringWithFormat:@"服务费%@元",data[@"servicefee"]];
        
        UILabel *licenceLabel = [cell viewWithTag:102];
        licenceLabel.text = [NSString stringWithFormat:@"%@",data[@"licencenumber"]];
        
        UILabel *dateLabel = [cell viewWithTag:103];
        dateLabel.text = [NSString stringWithFormat:@"%@",data[@"date"]];
        
        UILabel *areaLabel = [cell viewWithTag:104];
        areaLabel.text = [NSString stringWithFormat:@"%@",data[@"area"]];
        
        UILabel *actLabel = [cell viewWithTag:105];
        actLabel.text = [NSString stringWithFormat:@"%@",data[@"act"]];
        
        UIImageView *selectImg = [cell viewWithTag:106];
        selectImg.hidden = [(NSNumber *)data[@"status"] integerValue] != 1;
        selectImg.image = (self.indexPath.row == indexPath.row && self.indexPath.section == indexPath.section) ? [UIImage imageNamed:@"illegal_radioSelect"] : [UIImage imageNamed:@"illegal_radioUnselect"];
        
        UILabel *tagLabel = [cell viewWithTag:107];
        tagLabel.text = [self.statusDic objectForKey:data[@"status"]];
        
        UIButton *btn = [cell viewWithTag:108];
        btn.enabled = [(NSNumber *)data[@"status"] integerValue] == 1;
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            [self configRadioBtnWithIndexPath:indexPath];
            
        }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < self.tips.count)
    {
        NSDictionary *dic = self.tips[indexPath.row];
        CGFloat height = 25 + ceil([(NSString *)dic[@"tip"] labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 80 font:[UIFont systemFontOfSize:12]].height);
        return height;
    }
    else
    {
        NSDictionary *data = [self.dataSource safetyObjectAtIndex:indexPath.row - self.tips.count];
        NSString *actStr = data[@"act"];
        NSString *areaStr = data[@"area"];
        CGFloat height = 140 +
        ceil([actStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 60 font:[UIFont systemFontOfSize:15]].height) +
        ceil([areaStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 90 font:[UIFont systemFontOfSize:13]].height);
        return height;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"MissionCell"])
    {
        NSDictionary *dic = self.dataSource[indexPath.row];
        ViolationCommissionStateVC *vc = [UIStoryboard vcWithId:@"ViolationCommissionStateVC" inStoryboard:@"HX_Temp"];
        vc.recordID = (NSNumber *)dic[@"recordid"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSDictionary *dic = self.tips[indexPath.row];
        ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Temp_YZC"];
        vc.usercarID = (NSNumber *)dic[@"usercarid"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Utility

-(void)configRadioBtnWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.indexPath && (self.indexPath.row != indexPath.row || self.indexPath.section != indexPath.section))
    {
        NSIndexPath *tempIndex = self.indexPath;
        self.indexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:@[tempIndex, self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(self.indexPath && (self.indexPath.row == indexPath.row && self.indexPath.section == indexPath.section))
    {
        self.indexPath = nil;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        self.indexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self configCommitBtn];
}

-(void)configCommitBtn
{
    if (!self.indexPath)
    {
        self.commitBtn.enabled = NO;
        [self.commitBtn setTitle:@"请选择您需要代办的违章" forState:UIControlStateNormal];
        self.commitBtn.backgroundColor = HEXCOLOR(@"#d3d3d3");
    }
    else
    {
        self.commitBtn.enabled = YES;
        NSString *btnTitle = [NSString stringWithFormat:@"您仅需支付合计%ld元，前去支付",[self calculateDelegateFee]];
        [self.commitBtn setTitle:btnTitle forState:UIControlStateNormal];
        self.commitBtn.backgroundColor = HEXCOLOR(@"#FF7428");
    }
    
}

-(NSInteger)calculateDelegateFee
{
    NSDictionary *dic = nil;
    
    NSInteger total = 0;
    
    if (self.tips.count != 0)
    {
        dic = [self.dataSource safetyObjectAtIndex:self.indexPath.row - self.tips.count];
    }
    else
    {
        dic = [self.dataSource safetyObjectAtIndex:self.indexPath.row];
    }
    
    total = [(NSString *)dic[@"money"] integerValue] + [(NSString *)dic[@"servicefee"] integerValue];
    return total;
}

#pragma mark - Action

- (IBAction)actionJumpToGuideVC:(id)sender
{
    [self.navigationController pushViewController:self.webVC animated:YES];
}

- (IBAction)actionCommit:(id)sender
{
    if (self.tips.count == 0)
    {
        ViolationPayConfirmVC *vc = [UIStoryboard vcWithId:@"ViolationPayConfirmVC" inStoryboard:@"Temp_YZC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        HKAlertActionItem *jumpToLicenceVC = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#18D06A") clickBlock:^(id alertVC) {
            ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Temp_YZC"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#18D06A") clickBlock:^(id alertVC) {
            
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您的爱车的证件信息不完整，完善爱车饿证件信息后即可申请代办。" ActionItems:@[cancel, jumpToLicenceVC]];
        [alert show];
    }
}

#pragma mark - Lazyload

-(NSDictionary *)statusDic
{
    if (!_statusDic)
    {
        _statusDic = @{
                       @(0): @"等待受理",
                       @(1): @"待支付",
                       @(2): @"代办中",
                       @(3): @"代办完成",
                       @(4): @"代办失败",
                       @(6): @"证件审核失败"
                       };
    }
    return _statusDic;
}

-(WebVC *)webVC
{
    if (!_webVC)
    {
        _webVC = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
        _webVC.navigationController.title = @"服务说明";
        
#if XMDDENT == 2
        
        _webVC.url = @"www.xiaomadada.com/apphtml/daiban-server.html";
        
#else
        
        _webVC.url = @"dev.xiaomadada.com/apphtml/daiban-server.html";
        
#endif
        
    }
    return _webVC;
}

@end
