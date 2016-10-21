//
//  ViolationDelegateMissionVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationDelegateMissionVC.h"
#import "ViolationMyLicenceVC.h"
#import "DetailWebVC.h"
#import "ViolationDelegateCommitSuccessVC.h"
#import "GetViolationCommissionOp.h"
#import "ApplyViolationCommissionOp.h"
#import "NSString+RectSize.h"
#import "InsInputNameVC.h"
#import "UIView+Shake.h"

@interface ViolationDelegateMissionVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *confirmReadBtn;
@property (strong, nonatomic) DetailWebVC *webVC;


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
    [self setupObserver];
    [self setupNavi];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DDLogDebug(@"ViolationDelegateMissionVC dealloc");
}

#pragma mark - Setup

- (void)setupUI
{
    NSString *btnTitle = @"请选择您需要代办的违章";
    
    self.commitBtn.enabled = self.carArr.count != 0;
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    self.commitBtn.backgroundColor = self.carArr.count != 0 ? HEXCOLOR(@"#FF7428") : HEXCOLOR(@"#d3d3d3");
    [self.commitBtn setTitle:btnTitle forState:UIControlStateNormal];
}

- (void)setupNavi
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

-(void)setupObserver
{
    [[self.confirmReadBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        
        [MobClick event:@"weizhangdaiban" attributes:@{@"weizhangdaiban" : @"weizhangdaiban5"}];
        
    }];
}

#pragma mark - Network

- (void)getViolationCommission
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
        
        if (op.rsp_lists.count == 0)
        {
            self.bottomView.hidden = YES;
            self.tableView.hidden = YES;
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"暂无可代办违章"];
        }
        else
        {
            self.bottomView.hidden = NO;
            self.tableView.hidden = NO;
            
            self.dataSource = op.rsp_lists;
            self.tip = op.rsp_tip;
            [self.tableView reloadData];
        }
        
    } error:^(NSError *error) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击请重试" tapBlock:^{
            
            @strongify(self)
            
            [self getViolationCommission];
            
        }];
        
    }];
}

- (void)applyViolationCommission
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
        
        ViolationDelegateCommitSuccessVC *vc = [UIStoryboard vcWithId:@"ViolationDelegateCommitSuccessVC" inStoryboard:@"Violation"];
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
        [gToast showMistake:error.domain.length == 0 ? @"申请代办失败，请点击重试" : error.domain];
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count + (self.tip.length == 0 ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    @weakify(self)
    
    UITableViewCell *cell = nil;
    if (self.tip.length != 0 && indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"IssuesCell"];
        
        UILabel *tipLabel = [cell viewWithTag:100];
        tipLabel.text = self.tip;
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MissionCell"];
        NSDictionary *data = [self.dataSource safetyObjectAtIndex:(self.tip.length != 0 ? indexPath.row - 1 : indexPath.row)];
        
        UIImageView *selectImg = [cell viewWithTag:106];
        selectImg.image = [self.carArr containsObject:data] ? [UIImage imageNamed:@"illegal_selected"] : [UIImage imageNamed:@"illegal_unselected"];
        
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
        
        UIButton *btn = [cell viewWithTag:107];
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            [MobClick event:@"weizhangdaiban" attributes:@{@"weizhangdaiban" : @"weizhangdaiban3"}];
            
            if ([self.carArr containsObject:data])
            {
                [self.carArr removeObject:data];
            }
            else
            {
                [self.carArr addObject:data];
            }
            
            selectImg.image = [self.carArr containsObject:data] ? [UIImage imageNamed:@"illegal_selected"] : [UIImage imageNamed:@"illegal_unselected"];
            
            [self configCommitBtn];
            
        }];
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
        CGFloat heightAct = actStr.length == 0 ? 0 : ceil([actStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 60 font:[UIFont systemFontOfSize:15]].height);
        CGFloat heightArea = ceil([areaStr labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 75 font:[UIFont systemFontOfSize:13]].height);
        CGFloat height = 140 + heightAct + heightArea;
        return height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    @weakify(self)
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *data = [self.dataSource safetyObjectAtIndex:(self.tip.length != 0 ? indexPath.row - 1 : indexPath.row)];
    if ([cell.reuseIdentifier isEqualToString:@"MissionCell"])
    {
        
        [MobClick event:@"weizhangdaiban" attributes:@{@"weizhangdaiban" : @"weizhangdaiban4"}];
        
        UIImageView *selectImg = [cell viewWithTag:106];
        
        if ([self.carArr containsObject:data])
        {
            [self.carArr removeObject:data];
        }
        else
        {
            [self.carArr addObject:data];
        }
        
        selectImg.image = [self.carArr containsObject:data] ? [UIImage imageNamed:@"illegal_selected"] : [UIImage imageNamed:@"illegal_unselected"];
        
        [self configCommitBtn];
    }
    else
    {
        
        [MobClick event:@"weizhangdaiban" attributes:@{@"weizhangdaiban" : @"weizhangdaiban2"}];
        
        ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Violation"];
        vc.usercarID = self.userCarID;
        vc.carNum = self.licenceNumber;
        [vc setCommitSuccessBlock:^{
            
            @strongify(self)
            
            [self getViolationCommission];
            
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Utility

- (void)configCommitBtn
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

- (NSInteger)calculateDelegateFee
{
    NSInteger total = 0;
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dic in self.carArr)
    {
        [tempArr addObject:dic[@"date"]];
        total = total + [(NSString *)dic[@"money"] integerValue] + [(NSString *)dic[@"servicefee"] integerValue];
    }
    self.dates = [tempArr componentsJoinedByString:@"@"];
    return total;
}

#pragma mark - Action

- (void)actionBack
{
    [MobClick event:@"weizhangdaiban" attributes:@{@"navi" : @"back"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionJumpToGuideVC:(id)sender
{
    [MobClick event:@"weizhangdaiban" attributes:@{@"navi" : @"fuwushuoming"}];
    [self.navigationController pushViewController:self.webVC animated:YES];
}

- (IBAction)actionCommit:(id)sender
{

    @weakify(self)
    [MobClick event:@"weizhangdaiban" attributes:@{@"weizhangdaiban" : @"tijiao"}];
    // 不需要补全信息
    if (self.tip.length == 0)
    {
        [self applyViolationCommission];
    }
    // 需要补全身证号
    else if (/* DISABLES CODE */ (YES))
    {
        [self.view endEditing:YES];
        InsInputNameVC *vc = [UIStoryboard vcWithId:@"InsInputNameVC" inStoryboard:@"Insurance"];
        vc.nameField.textLimit = 20;
        vc.titleLabel.text = @"请输入车主身份证号码";
        vc.nameField.placeholder = @"因业务需要，需提供身份证号码";
//        [vc.nameField setDidBeginEditingBlock:^(CKLimitTextField *field) {
//            field.placeholder = nil;
//        }];
//        [vc.nameField setDidEndEditingBlock:^(CKLimitTextField *field) {
//            field.placeholder = @"因业务需要，需提供身份证号码";
//        }];
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(270, 160) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        //取消
        [[[vc.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        //确定
        @weakify(vc, self);
        [[vc.ensureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(vc, self);
            if (vc.nameField.text.length == 18)
            {
                [vc.nameField endEditing:YES];
                [sheet dismissAnimated:YES completionHandler:nil];
                
                // 消除警告。回头删
                [self class];
                
                //@YZC 等待接口。获取身份证后
            }
            else
            {
                [vc.nameField shake];
            }
        }];
    }
    // 需要补全照片
    else
    {
        HKAlertActionItem *jumpToLicenceVC = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#18D06A") clickBlock:^(id alertVC) {
            
            @strongify(self)
            
            [MobClick event:@"weizhangdaiban" attributes:@{@"buwanshantankuang" : @"weizhangdaiban9"}];
            
            ViolationMyLicenceVC *vc = [UIStoryboard vcWithId:@"ViolationMyLicenceVC" inStoryboard:@"Violation"];
            vc.usercarID = self.userCarID;
            vc.carNum = self.licenceNumber;
            [vc setCommitSuccessBlock:^{
                
                @strongify(self)
                
                [self getViolationCommission];
                
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#454545") clickBlock:^(id alertVC) {
            [MobClick event:@"weizhangdaiban" attributes:@{@"buwanshantankuang" : @"quxiao"}];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您的爱车的证件信息不完整，完善爱车的证件信息后即可申请代办。" ActionItems:@[cancel, jumpToLicenceVC]];
        [alert show];
    }
    
    
}

- (IBAction)actionConfirmReading:(id)sender
{
    self.confirmReadBtn.selected = !self.confirmReadBtn.isSelected;
    [self configCommitBtn];
}


#pragma mark - Lazyload

- (NSMutableArray *)carArr
{
    if (!_carArr)
    {
        _carArr = [[NSMutableArray alloc]init];
    }
    return _carArr;
}

- (DetailWebVC *)webVC
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
