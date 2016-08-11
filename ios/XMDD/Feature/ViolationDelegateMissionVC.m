//
//  ViolationDelegateMissionVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationDelegateMissionVC.h"
#import "ViolationMyLicenceVC.h"
#import "ViolationMissionHistoryVC.h"
#import "WebVC.h"
#import "ViolationDelegateCommitSuccessVC.h"
#import "GetViolationCommissionOp.h"
#import "ApplyViolationCommissionOp.h"
#import "NSString+RectSize.h"

@interface ViolationDelegateMissionVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *confirmReadBtn;
@property (strong, nonatomic) WebVC *webVC;


@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray *carArr;
@property (strong, nonatomic) NSString *tip;
@property (strong, nonatomic) NSString *dates;

@end

@implementation ViolationDelegateMissionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getViolationCommission];
    
    [self setupUI];
    
    
    //    [self getSimutateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    DDLogDebug(@"ViolationDelegateMissionVC dealloc");
}

#pragma mark - Setup

-(void)setupUI
{
    NSString *btnTitle = self.carArr.count != 0 ? [NSString stringWithFormat:@"服务费合计%ld元，立即申请代办",self.carArr.count * 235] : @"请选择您需要代办的违章";
    
    self.commitBtn.enabled = self.carArr.count != 0;
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    self.commitBtn.backgroundColor = self.carArr.count != 0 ? HEXCOLOR(@"#FF7428") : HEXCOLOR(@"#d3d3d3");
    [self.commitBtn setTitle:btnTitle forState:UIControlStateNormal];
}

#pragma mark - Network

-(void)getSimutateData
{
    @weakify(self)
    
    self.bottomView.hidden = YES;
    self.tableView.hidden = YES;
    [self.view hideDefaultEmptyView];
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    
    CKAfter(0.5, ^{
        
        @strongify(self)
        
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
                                  @"licencenumber":@"浙A12345"};
            self.tip = @"浙A12345的证件信息不完整，完善后即可申请代办";
            self.licenceNumber = @"浙A12345";
            self.dataSource = @[dic,dic,dic,dic,dic,dic,dic,dic,dic,dic,dic,dic,dic,dic,dic,dic];
            
            [self.tableView reloadData];
        }
        else
        {
            [self.view stopActivityAnimation];
            
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击请重试" tapBlock:^{
                
                @strongify(self)
                
                [self getSimutateData];
                
            }];
        }
    });
    
}

-(void)getViolationCommission
{
    @weakify(self)
    GetViolationCommissionOp *op = [GetViolationCommissionOp operation];
    
    op.req_licenceNumber = self.licenceNumber;
    
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        
        self.bottomView.hidden = YES;
        self.tableView.hidden = YES;
        
        [self.view hideDefaultEmptyView];
        
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }]subscribeNext:^(GetViolationCommissionOp *op) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        self.bottomView.hidden = NO;
        self.tableView.hidden = NO;
        
        self.dataSource = op.rsp_lists;
        self.tip = op.rsp_tip;
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击请重试" tapBlock:^{
            
            @strongify(self)
            
            [self getViolationCommission];
            
        }];
        
    }];
}

-(void)applyViolationCommission
{
    @weakify(self)
    ApplyViolationCommissionOp *op = [ApplyViolationCommissionOp operation];
    
    op.req_usercarid = self.userCarID;
    op.req_licencenumber = self.licenceNumber;
    op.req_dates = self.dates;
    
    [[[op rac_postRequest]initially:^{
        
        [gToast showingWithText:@"申请代办中"];
        
    }]subscribeNext:^(ApplyViolationCommissionOp *op) {
        
        @strongify(self)
        
        [gToast dismiss];
        
        if (self.missionSuccessBlock)
        {
            self.missionSuccessBlock(op.rsp_tip);
        }
        
        ViolationDelegateCommitSuccessVC *vc = [UIStoryboard vcWithId:@"ViolationDelegateCommitSuccessVC" inStoryboard:@"Temp_YZC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
        [gToast showMistake:@"申请代办失败，请点击重试"];
        
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count + (self.tip.length == 0 ? 0 : 1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.tip.length != 0 && indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"IssuesCell"];
        
        UILabel *tipLabel = [cell viewWithTag:100];
        tipLabel.text = [NSString stringWithFormat:@"%@",self.tip];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MissionCell"];
        NSDictionary *data = [self.dataSource safetyObjectAtIndex:(self.tip.length != 0 ? indexPath.row - 1 : indexPath.row)];
        
        UIImageView *selectImg = [cell viewWithTag:106];
        selectImg.image = [self.carArr containsObject:indexPath] ? [UIImage imageNamed:@"illegal_selected"] : [UIImage imageNamed:@"illegal_unselected"];
        
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
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tip.length != 0 && indexPath.row == 0)
    {
        CGFloat height = 25 + ceil([self.tip labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 80 font:[UIFont systemFontOfSize:12]].height);
        return height;
    }
    else
    {
        NSDictionary *data = [self.dataSource safetyObjectAtIndex:(self.tip.length != 0 ? indexPath.row - 1 : indexPath.row)];
        NSString *actStr = data[@"act"];
        NSString *areaStr = data[@"area"];
        CGFloat height = 140 +
        ceil([actStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 60 font:[UIFont systemFontOfSize:15]].height) +
        ceil([areaStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 75 font:[UIFont systemFontOfSize:13]].height);
        return height;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"MissionCell"])
    {
        UIImageView *selectImg = [cell viewWithTag:106];
        
        if ([self.carArr containsObject:indexPath])
        {
            [self.carArr removeObject:indexPath];
        }
        else
        {
            [self.carArr addObject:indexPath];
        }
        
        selectImg.image = [self.carArr containsObject:indexPath] ? [UIImage imageNamed:@"illegal_selected"] : [UIImage imageNamed:@"illegal_unselected"];
        
        [self configCommitBtn];
    }
    else
    {
        ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Temp_YZC"];
        vc.usercarID = self.userCarID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Utility

-(void)configCommitBtn
{
    if (self.carArr.count == 0)
    {
        [self.commitBtn setTitle:@"请选择您需要代办的违章" forState:UIControlStateNormal];
    }
    else
    {
        NSString *btnTitle = [NSString stringWithFormat:@"服务费合计%ld元，立即申请代办",[self calculateDelegateFee]];
        [self.commitBtn setTitle:btnTitle forState:UIControlStateNormal];
    }
    
    self.commitBtn.backgroundColor = (self.carArr.count != 0 && self.confirmReadBtn.isSelected) ? HEXCOLOR(@"#FF7428") : HEXCOLOR(@"#d3d3d3");
    self.commitBtn.enabled = (self.carArr.count != 0 && self.confirmReadBtn.isSelected);
    
}

-(NSInteger)calculateDelegateFee
{
    NSDictionary *dic = nil;
    NSInteger total = 0;
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    
    for (NSIndexPath *index in self.carArr)
    {
        if (self.tip.length != 0)
        {
            dic = [self.dataSource safetyObjectAtIndex:index.row - 1];
        }
        else
        {
            dic = [self.dataSource safetyObjectAtIndex:index.row];
        }
        
        [tempArr addObject:dic[@"date"]];
        total = total + [(NSString *)dic[@"money"] integerValue] + [(NSString *)dic[@"servicefee"] integerValue];
    }
    self.dates = [tempArr componentsJoinedByString:@"@"];
    return total;
}

#pragma mark - Action

- (IBAction)actionJumpToGuideVC:(id)sender
{
    [self.navigationController pushViewController:self.webVC animated:YES];
}

- (IBAction)actionCommit:(id)sender
{
    
    @weakify(self)
    
    if (self.tip.length != 0)
    {
        [self applyViolationCommission];
    }
    else
    {
        HKAlertActionItem *jumpToLicenceVC = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#18D06A") clickBlock:^(id alertVC) {
            
            @strongify(self)
            
            ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Temp_YZC"];
            vc.usercarID = self.userCarID;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#454545") clickBlock:^(id alertVC) {
            
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您的爱车的证件信息不完整，完善爱车饿证件信息后即可申请代办。" ActionItems:@[cancel, jumpToLicenceVC]];
        [alert show];
    }
    
    
}

- (IBAction)actionConfirmReading:(id)sender
{
    self.confirmReadBtn.selected = !self.confirmReadBtn.isSelected;
    [self configCommitBtn];
}


#pragma mark - Lazyload

-(NSMutableArray *)carArr
{
    if (!_carArr)
    {
        _carArr = [[NSMutableArray alloc]init];
    }
    return _carArr;
}

-(WebVC *)webVC
{
    if (!_webVC)
    {
        _webVC = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
        _webVC.navigationController.title = @"服务说明";
        
        NSString *urlStr = nil;
        
#if XMDDEnvironment==0
        urlStr = @"http://dev01.xiaomadada.com/apphtml/daiban-server.html";
#elif XMDDEnvironment==1
        urlStr = @"http://dev.xiaomadada.com/apphtml/daiban-server.html";
#else
        urlStr = @"http://www.xiaomadada.com/apphtml/daiban-server.html";
#endif
        _webVC.url =  urlStr;
        
    }
    return _webVC;
}


@end
