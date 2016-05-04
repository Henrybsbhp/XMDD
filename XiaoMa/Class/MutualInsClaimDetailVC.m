//
//  ClaimDetailVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsClaimDetailVC.h"
#import "GetCooperationClaimDetailOp.h"
#import "NSString+Price.h"
#import "MutualInsClaimAccountVC.h"
#import "ConfirmClaimOp.h"
#import "NSString+Split.h"
#import "HKImageAlertVC.h"
#import "NSString+BankNumber.h"
#import "HKImageAlertVC.h"
#import "MutualInsScencePageVC.h"
#import "NSString+RectSize.h"
#import "MutualInsAskClaimsVC.h"
#import "MutualInsClaimsHistoryVC.h"

@interface MutualInsClaimDetailVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *agreeBtn;
@property (strong, nonatomic) IBOutlet UIButton *disagreeBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) HKImageAlertVC *alert;
@property (nonatomic,strong) NSString *statusdesc;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,strong) NSString *accidenttime;
@property (nonatomic,strong) NSString *accidentaddress;
@property (nonatomic,strong) NSString *chargepart;
@property (nonatomic,strong) NSString *cardmgdesc;
@property (nonatomic,strong) NSString *reason;
@property (nonatomic) CGFloat claimfee;
@property (nonatomic,strong) NSNumber *cardid;
@property (nonatomic,strong) NSString *cardno;
@property (nonatomic,strong) NSString *bankcardno;
@property (nonatomic,strong) NSString *insurancename;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;

@property (strong, nonatomic) CKList *dataSource;

@end

@implementation MutualInsClaimDetailVC

-(void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    DebugLog(@"MutualInsClaimDetailVC dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(setBackAction)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *list = self.dataSource[section];
    return list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block)
    {
        block(data, cell, indexPath);
    }
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block)
    {
        return block(data,indexPath);
    }
    else
    {
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==1 && indexPath.section == 1 && self.status.integerValue != 0 && self.status.integerValue != 20)
    {
        MutualInsClaimAccountVC *accountVC = [UIStoryboard vcWithId:@"MutualInsClaimAccountVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:accountVC animated:YES];
    }
}

#pragma mark Utility

-(void)loadData
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        GetCooperationClaimDetailOp *op = [[GetCooperationClaimDetailOp alloc]init];
        op.req_claimid = self.claimid;
        @weakify(self)
        [[[op rac_postRequest]initially:^{
            @strongify(self)
            self.tableView.hidden = YES;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }]subscribeNext:^(GetCooperationClaimDetailOp *op) {
            @strongify(self)
            self.tableView.hidden = NO;
            [self.view stopActivityAnimation];
            self.statusdesc = op.rsp_statusdesc;
            self.status = op.rsp_status;
            self.accidenttime = op.rsp_accidenttime;
            self.accidentaddress = op.rsp_accidentaddress;
            self.chargepart = op.rsp_chargepart;
            self.cardmgdesc = op.rsp_cardmgdesc;
            self.reason = op.rsp_reason;
            self.claimfee = op.rsp_claimfee;
            self.insurancename = op.rsp_insurancename;
            self.cardno = op.rsp_cardno;
            // 设置底部按钮
            [self setupBottomViewStatus:self.status.integerValue];
            // 设置数据源
            [self setupDataSourceWithStatus:self.status.integerValue];
            // 更新约束
            [self.view layoutIfNeeded];
            [self.tableView reloadData];
        }error:^(NSError *error) {
            @strongify(self)
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败，请重试" tapBlock:^{
                [self loadData];
            }];
            
        }];
    }
}

#pragma mark Action

-(void)setBackAction
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0020"}];
    
    for (UIViewController * vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[MutualInsAskClaimsVC class]] ||
            [vc isKindOfClass:[MutualInsClaimsHistoryVC class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)call:(id)sender
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0019"}];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#ff7428") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客服电话：4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

#pragma mark Init

-(void)setupUI
{
    [self addCorner:self.takePhotoBtn];
    [self addCorner:self.agreeBtn];
    [self addCorner:self.disagreeBtn];
    [self addBorder:self.disagreeBtn WithColor:@"#18D06A"];
    self.tableView.tableFooterView = [UIView new];
    self.bottomView.hidden = YES;
    @weakify(self)
    [[self.agreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0023"}];
        if (self.bankcardno.length != 0)
        {
            [self confirmClaimWithAgreement:@2];
        }
        else
        {
            [gToast showMistake:@"请输入借记卡卡号"];
        }
    }];
    [[self.disagreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0024"}];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [self confirmClaimWithAgreement:@1];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您确定不同意上述补偿金额？若您不同意，将无法继续快速补偿流程。" ActionItems:@[cancel,confirm]];
        [alert show];
    }];
    [[self.takePhotoBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0021"}];
        MutualInsScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"MutualInsScencePageVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:scencePageVC animated:YES];
    }];
    
}

-(void)confirmClaimWithAgreement:(NSNumber *)agreement
{
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"提交成功";
    alert.imageName = @"mins_ok";
    alert.message = agreement.integerValue == 1 ?  @"客服人员将很快与您取得联系，请留意号码为4007-111-111点来电请耐心等待" : @"系统将在1个工作日内（周末及节假日顺延）打款至您预留的银行卡，请耐心等待，如有问题请致电4007-111-111";
    @weakify(self)
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
        @strongify(self)
        NSArray *viewControllers = self.navigationController.viewControllers;
        [self.navigationController popToViewController:[viewControllers safetyObjectAtIndex:1] animated:YES];
    }];
    alert.actionItems = @[cancel];
    ConfirmClaimOp *op = [[ConfirmClaimOp alloc]init];
    op.req_claimid = self.claimid;
    op.req_agreement = agreement;
    op.req_bankcardno = [NSNumber numberWithInteger:self.bankcardno.integerValue];
    [[op rac_postRequest]subscribeNext:^(id x) {
        @strongify(self)
        [alert show];
        [self loadData];
    }];
}

#pragma mark Setup

-(void)setupBottomViewStatus:(NSInteger)status
{
    if (status != -1 && status != 1)
    {
        self.bottomView.hidden = YES;
        self.bottomViewHeight.constant = 0;
    }
    else
    {
        self.bottomView.hidden = NO;
        self.bottomViewHeight.constant = 65;
        if (status == 1)
        {
            self.disagreeBtn.hidden = NO;
            self.agreeBtn.hidden = NO;
            self.takePhotoBtn.hidden = YES;
        }
        else
        {
            self.disagreeBtn.hidden = YES;
            self.agreeBtn.hidden = YES;
            self.takePhotoBtn.hidden = NO;
        }
    }
}

-(void)setupDataSourceWithStatus:(NSInteger)status
{
    self.dataSource = $($([self noticeCellData]),
                        $([self feeCellData]),
                        $([self titleCellData],
                          [self accidentTimeData],
                          [self accidentLocationData],
                          [self accidentDutyData],
                          [self accidentSituationData],
                          [self accidentReasonData]),
                        $([self cardCellData])
                        );
}

-(id)noticeCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"noticeCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *label = [cell viewWithTag:100];
        label.text = self.statusdesc;
    });
    return data;
}

-(id)feeCellData
{
    if (self.claimfee <= 0.001 || self.status.integerValue == 20)
    {
        return CKNULL;
    }
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"feeCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        
        return 53;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *feeLb = [cell viewWithTag:100];
        feeLb.text = self.claimfee != 0 ? [NSString formatForPriceWithFloat:self.claimfee] : @" ";
    });
    return data;
}

-(id)titleCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"titleCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    return data;
}

-(id)accidentTimeData
{
    //    if ([self.accidenttime isEqual:CKNULL])
    if (!self.accidenttime)
    {
        return CKNULL;
    }
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"detailCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        CGSize size = [self.accidenttime labelSizeWithWidth:self.tableView.frame.size.width - 105 font:[UIFont systemFontOfSize:14]];
        return size.height + 15;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *title = [cell viewWithTag:100];
        title.text = @"事故时间：";
        
        UILabel *timeLb = [cell viewWithTag:101];
        timeLb.text = self.accidenttime.length ? self.accidenttime : @" ";
        timeLb.preferredMaxLayoutWidth = self.view.bounds.size.width - 110;
    });
    return data;
}

-(id)accidentLocationData
{
    //    if ([self.accidentaddress isEqual:CKNULL])
    if (!self.accidentaddress)
    {
        return CKNULL;
    }
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"detailCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [self.accidentaddress labelSizeWithWidth:self.tableView.frame.size.width - 105 font:[UIFont systemFontOfSize:14]];
        return size.height + 15;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *title = [cell viewWithTag:100];
        title.text = @"事故地点：";
        
        UILabel *locationLb = [cell viewWithTag:101];
        locationLb.text = self.accidentaddress.length ? self.accidentaddress : @" ";
        locationLb.preferredMaxLayoutWidth = self.view.bounds.size.width - 110;
    });
    return data;
}

-(id)accidentDutyData
{
    //    if ([self.chargepart isEqual:CKNULL])
    if (!self.chargepart)
    {
        return CKNULL;
    }
    
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"detailCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [self.chargepart labelSizeWithWidth:self.tableView.frame.size.width - 105 font:[UIFont systemFontOfSize:14]];
        return size.height + 15;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *title = [cell viewWithTag:100];
        title.text = @"事故责任：";
        
        UILabel *dutyLb = [cell viewWithTag:101];
        dutyLb.text = self.chargepart.length ? self.chargepart : @" ";
        dutyLb.preferredMaxLayoutWidth = self.view.bounds.size.width - 110;
    });
    return data;
}

-(id)accidentSituationData
{
    //    if ([self.cardmgdesc isEqual:CKNULL])
    if (!self.cardmgdesc)
    {
        return CKNULL;
    }
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"detailCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [self.cardmgdesc labelSizeWithWidth:self.tableView.frame.size.width - 105 font:[UIFont systemFontOfSize:14]];
        return size.height + 15;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *title = [cell viewWithTag:100];
        title.text = @"车损情况：";
        
        UILabel *conditionLb = [cell viewWithTag:101];
        conditionLb.text = self.cardmgdesc.length ? self.cardmgdesc : @" ";
        conditionLb.preferredMaxLayoutWidth = self.view.bounds.size.width - 110;
    });
    return data;
}

-(id)accidentReasonData
{
    //    if ([self.reason isEqual:CKNULL])
    if (!self.reason)
    {
        return CKNULL;
    }
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"detailCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [self.reason labelSizeWithWidth:self.tableView.frame.size.width - 110 font:[UIFont systemFontOfSize:14]];
        return size.height + 15;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *title = [cell viewWithTag:100];
        title.text = @"事故经过：";
        
        UILabel *reasonLb = [cell viewWithTag:101];
        reasonLb.text = self.reason.length ? self.reason : @" ";
        reasonLb.preferredMaxLayoutWidth = self.view.bounds.size.width - 110;
    });
    return data;
}

-(id)cardCellData
{
    if (self.status.integerValue == 20 || self.status.integerValue == 10 || self.status.integerValue == 0 || self.status.integerValue == -1 || self.status.integerValue == -2)
    {
        return CKNULL;
    }
    
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"cardCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 164;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UITextField *nameTF = [cell viewWithTag:100];
        UITextField *numTF = [cell viewWithTag:101];
        numTF.keyboardType = UIKeyboardTypeNumberPad;
        UILabel *label = [cell viewWithTag:102];
        label.preferredMaxLayoutWidth = self.view.bounds.size.width - 30;
        label.hidden = self.status.integerValue == 1 ? NO : YES;
        [self addBorder:nameTF WithColor:@"#dedfe0"];
        [self addBorder:numTF WithColor:@"#dedfe0"];
        @weakify(self);
        [[[[numTF rac_textSignal] takeUntilForCell:cell]skip:1] subscribeNext:^(NSString *x) {
            @strongify(self);
            
            numTF.text = [self splitCardNumString:x];
        }];
        numTF.enabled = self.status.integerValue == 1 ;
        numTF.text = [self convertAccount:self.cardno];
        nameTF.text = self.insurancename;
    });
    return data;
}

#pragma mark - Utility

-(void)addCorner:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
}

-(void)addBorder:(UIView *)view WithColor:(NSString *)color
{
    view.layer.borderColor = [[UIColor colorWithHex:color alpha:1]CGColor];
    view.layer.borderWidth = 1;
}

-(NSString *)splitCardNumString:(NSString *)str
{
    if (str.length < 24)
    {
        self.bankcardno = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
        return [self.bankcardno splitByStep:4 replacement:@" "];
    }
    else
    {
        return [str substringToIndex:23];
    }
}

-(NSString *)convertAccount:(NSString *)account
{
    if (account.length > 7)
    {
        NSString *temp1 = [account substringWithRange:NSMakeRange(0, 4)];
        NSString *temp2 = [account substringWithRange:NSMakeRange(account.length - 4, 4)];
        
        NSMutableString *ciphertext = [[NSMutableString alloc] init];
        [ciphertext appendString:temp1];
        
        for (NSInteger i = 4 ; i < account.length - 4 ; i ++ )
        {
            [ciphertext appendString:@"*"];
        }
        [ciphertext appendString:temp2];
        
        return ciphertext;
    }
    return nil;
}

-(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    if (!_alert)
    {
        _alert = [[HKImageAlertVC alloc]init];
    }
    _alert.topTitle = topTitle;
    _alert.imageName = imageName;
    _alert.message = message;
    _alert.actionItems = actionItems;
    return _alert;
}

@end
