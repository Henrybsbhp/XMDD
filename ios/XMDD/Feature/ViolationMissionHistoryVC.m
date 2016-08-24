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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (strong, nonatomic) DetailWebVC *webVC;

@property (strong, nonatomic) NSArray *tips;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSDictionary *statusDic;
@property (strong, nonatomic) NSIndexPath *indexPath;
/**
 *  记录上次页面偏移量。保证后台更新后位置不变。
 */
@property (assign, nonatomic) CGPoint offset;
@property (strong, nonatomic) NSNumber *recordID;

@end

@implementation ViolationMissionHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupNavi];
    [self setupNotify];
    [self getViolationCommissionApply];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.offset.y != 0)
    {
        self.tableView.contentOffset = self.offset;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.offset = self.tableView.contentOffset;
}

#pragma mark - Setup

-(void)setupNotify
{
    @weakify(self)
    
    [self listenNotificationByName:kNotifyViolationPaySuccess withNotifyBlock:^(NSNotification *note, id weakSelf) {
        
        @strongify(self)
        
        [self getViolationCommissionApply];
        [self configButtomView];
        
    }];
    
    [self listenNotificationByName:kNotifyCommissionAbandoned withNotifyBlock:^(NSNotification *note, id weakSelf) {
        
        @strongify(self)
        
        [self getViolationCommissionApply];
        [self configButtomView];
        
    }];
    
}

-(void)setupUI
{
    NSString *btnTitle = @"请选择您需要支付的代办订单";
    
    self.commitBtn.enabled = (self.indexPath != nil);
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    self.commitBtn.backgroundColor = self.indexPath != nil ? HEXCOLOR(@"#FF7428") : HEXCOLOR(@"#d3d3d3");
    [self.commitBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    self.bottomViewHeight.constant = 0;
}

-(void)setupNavi
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Network

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
        
        [self configButtomView];
        
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
        NSDictionary *dic = [self.tips safetyObjectAtIndex:indexPath.row];
        UILabel *tipLabel = [cell viewWithTag:100];
        tipLabel.text = dic[@"tip"];
        
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
        licenceLabel.text = data[@"licencenumber"];
        
        UILabel *dateLabel = [cell viewWithTag:103];
        dateLabel.text = data[@"date"];
        
        UILabel *areaLabel = [cell viewWithTag:104];
        areaLabel.text = data[@"area"];
        
        UILabel *actLabel = [cell viewWithTag:105];
        actLabel.text = data[@"act"];
        
        UIImageView *selectImg = [cell viewWithTag:106];
        selectImg.hidden = [(NSNumber *)data[@"status"] integerValue] != 1;
        selectImg.image = (self.indexPath.row == indexPath.row && self.indexPath.section == indexPath.section && self.indexPath) ? [UIImage imageNamed:@"illegal_radioSelect"] : [UIImage imageNamed:@"illegal_radioUnselect"];
        
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
        CGFloat heightAct = actStr.length == 0 ? 0 : ceil([actStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 60 font:[UIFont systemFontOfSize:15]].height);
        CGFloat heightArea = ceil([areaStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 75 font:[UIFont systemFontOfSize:13]].height);
        CGFloat height = 140 + heightAct + heightArea;
        return height;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    @weakify(self)
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"MissionCell"])
    {
        NSInteger index = indexPath.row - self.tips.count;
        NSDictionary *dic = self.dataSource[index];
        ViolationCommissionStateVC *vc = [UIStoryboard vcWithId:@"ViolationCommissionStateVC" inStoryboard:@"Violation"];
        vc.recordID = (NSNumber *)dic[@"recordid"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSDictionary *dic = self.tips[indexPath.row];
        ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Violation"];
        vc.usercarID = (NSNumber *)dic[@"usercarid"];
        vc.carNum = dic[@"licencenumber"];
        [vc setCommitSuccessBlock:^{
            
            @strongify(self)
            
            [self getViolationCommissionApply];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Utility

// 重置底部按钮
- (void)configButtomView
{
    for (NSDictionary *data in self.dataSource)
    {
        if ([data[@"status"] integerValue] == 1)
        {
            self.bottomViewHeight.constant = 60;
            break;
        }
    }
    self.bottomViewHeight.constant = 0;
}

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
        [self.commitBtn setTitle:@"请选择您需要支付的代办订单" forState:UIControlStateNormal];
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
    NSDictionary *dic = self.dataSource[self.indexPath.row];
    ViolationPayConfirmVC *vc = [UIStoryboard vcWithId:@"ViolationPayConfirmVC" inStoryboard:@"Violation"];
    vc.recordID = (NSNumber *)dic[@"recordid"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)actionBack
{
    if (self.router.userInfo[kOriginRoute])
    {
        UIViewController *vc = [self.router.userInfo[kOriginRoute] targetViewController];
        [self.router.navigationController popToViewController:vc animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
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

-(DetailWebVC *)webVC
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
