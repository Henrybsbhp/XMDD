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
#import "MutualInsChooseBankVC.h"
#import "MutualInsClaimAccountVC.h"
#import "ConfirmClaimOp.h"
#import "NSString+Split.h"
#import "HKImageAlertVC.h"
#import "NSString+BankNumber.h"
#import "HKImageAlertVC.h"

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



@end

@implementation MutualInsClaimDetailVC

-(void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    DebugLog(@"MutualInsClaimDetailVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.status.integerValue == 20)
    {
        return 2;
    }
    else if (self.status.integerValue == 10 || self.status.integerValue == 0)
    {
        return 3;
    }
    else
    {
        return 4;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
        UILabel *label = [cell viewWithTag:100];
        label.text = self.statusdesc;
    }
    else if ((indexPath.section == 1 && self.status.integerValue == 20)||indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
        UILabel *timeLb = [cell viewWithTag:100];
        UILabel *locationLb = [cell viewWithTag:101];
        UILabel *dutyLb = [cell viewWithTag:102];
        UILabel *conditionLb = [cell viewWithTag:103];
        UILabel *reasonLb = [cell viewWithTag:104];
        
        timeLb.text = self.accidenttime.length ? self.accidenttime : @" ";
        locationLb.text = self.accidentaddress.length ? self.accidentaddress : @" ";
        dutyLb.text = self.chargepart.length ? self.chargepart : @" ";
        conditionLb.text = self.cardmgdesc.length ? self.cardmgdesc : @" ";
        reasonLb.text = self.reason.length ? self.reason : @" ";
    }
    else if (indexPath.section == 1 && self.status.integerValue != 20)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"feeCell"];
        UILabel *feeLb = [cell viewWithTag:100];
        feeLb.text = self.claimfee != 0 ? [NSString formatForPriceWithFloat:self.claimfee] : @" ";
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell"];
        UITextField *nameTF = [cell viewWithTag:100];
        UITextField *numTF = [cell viewWithTag:101];
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
        if (self.status.integerValue == 1)
        {
            numTF.enabled = YES;
        }
        else
        {
            numTF.enabled = NO;
        }
        numTF.text = [self splitCardNumString:[self convertAccount:self.cardno]];
        nameTF.text = self.insurancename;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ||( indexPath.section == 1 && self.status.integerValue != 20))
    {
        return 50;
    }
    else if ((indexPath.section == 1 && self.status.integerValue == 20)||indexPath.section == 2 || self.status.integerValue == 1)
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        return ceil(size.height);
    }
    else
    {
        return 180;
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
    GetCooperationClaimDetailOp *op = [[GetCooperationClaimDetailOp alloc]init];
    op.req_claimid = self.claimid;
    @weakify(self)
    [[[op rac_postRequest]initially:^{
        @strongify(self)
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }]subscribeNext:^(GetCooperationClaimDetailOp *op) {
        @strongify(self)
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
        if (self.status.integerValue == 1)
        {
            self.bottomView.hidden = NO;
            self.bottomViewHeight.constant = 65;
        }
        else
        {
            self.bottomView.hidden = YES;
            self.bottomViewHeight.constant = 0;
        }
        [self.view layoutIfNeeded];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        @strongify(self)
        [self.view stopActivityAnimation];
    }];
}

#pragma mark Action

- (IBAction)call:(id)sender {
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
        [alertVC dismiss];
    }];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
        [alertVC dismiss];
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客服电话：4007-111-111" ActionItems:@[confirm,cancel]];
    [alert show];
}

#pragma mark Init

-(void)setupUI
{
    [self addCorner:self.agreeBtn];
    [self addCorner:self.disagreeBtn];
    [self addBorder:self.disagreeBtn WithColor:@"#18D06A"];
    self.tableView.tableFooterView = [UIView new];
    self.bottomView.hidden = YES;
    @weakify(self)
    [[self.agreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [self confirmClaimWithAgreement:@2];
    }];
    [[self.disagreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self)
        [self confirmClaimWithAgreement:@1];
    }];
    
}

-(void)confirmClaimWithAgreement:(NSNumber *)agreement
{
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"提交成功";
    alert.imageName = @"mins_ok";
    alert.message = agreement.integerValue == 1 ?  @"客服人员将很快与您取得联系，请留意号码为4007-111-111点来电请耐心等待" : @"系统将在1个工作日内（周末及节假日顺延）内打款至您预留的银行卡，请耐心等待，如有问题请致电4007-111-111";
    @weakify(self)
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
        @strongify(self)
        NSArray *viewControllers = self.navigationController.viewControllers;
        [self.navigationController popToViewController:[viewControllers safetyObjectAtIndex:1] animated:YES];
        [alertVC dismiss];
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

#pragma mark Utility

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
    if (account.length > 3)
    {
        NSString *temp = [account substringWithRange:NSMakeRange(account.length - 4, 4)];
        NSString *ciphertext = [[NSMutableString alloc]init];
        for (NSInteger i = 0 ; i < account.length - 4 ; i ++ )
        {
            ciphertext = [ciphertext append:@"*"];
        }
        ciphertext = [ciphertext append:temp];
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
