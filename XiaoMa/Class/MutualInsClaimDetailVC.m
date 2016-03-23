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

@interface MutualInsClaimDetailVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *agreeBtn;
@property (strong, nonatomic) IBOutlet UIButton *disagreeBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

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

@end

@implementation MutualInsClaimDetailVC

-(void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
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
        switch (self.status.integerValue)
        {
            case 0:
                label.text = @"理赔记录审核中，待估价";
                break;
            case 1:
                label.text = @"审核通过，待用户确认金额";
                break;
            case 2:
                label.text = @"用户确认金额，理赔待打款";
                break;
            case 3:
                label.text = @"理赔完成打款，已结束";
                break;
            case 10:
                label.text = @"用户拒绝确认理赔金额";
                break;
            default:
                label.text = @"超过快速理赔金额，无法快速理赔";
                break;
        }
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
        label.hidden = self.status.integerValue == 1 ? NO : YES;
        [self addBorder:nameTF WithColor:@"#dedfe0"];
        [self addBorder:numTF WithColor:@"#dedfe0"];
        @weakify(self);
        [[[[numTF rac_textSignal] takeUntilForCell:cell]skip:1] subscribeNext:^(NSString *x) {
            @strongify(self);
            numTF.text = [self splitCardNumString:x];
        }];
        numTF.text = [self splitCardNumString:self.cardno];
        nameTF.text = self.insurancename;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ||( indexPath.section == 1 && self.status.integerValue != 0 && self.status.integerValue != 20))
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
    [[[op rac_postRequest]initially:^{
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }]subscribeNext:^(GetCooperationClaimDetailOp *op) {
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
//        if (self.status.integerValue == 1)
//        {
            self.bottomView.hidden = NO;
//        }
//        else
//        {
//            self.bottomView.hidden = YES;
//        }
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [self.view stopActivityAnimation];
    }];
}

#pragma mark Action

- (IBAction)call:(id)sender {
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"如有任何疑问，可拨打客服电话：4007-111-111"];
}

#pragma mark Init

-(void)setupUI
{
    [self addCorner:self.agreeBtn];
    [self addCorner:self.disagreeBtn];
    [self addBorder:self.disagreeBtn WithColor:@"#18D06A"];
    self.tableView.tableFooterView = [UIView new];
    self.bottomView.hidden = YES;
    
    [[self.agreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [self confirmClaimWithAgreement:@2];
    }];
    
    [[self.disagreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
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
    if(![self.bankcardno isValidCreditCardNumber] && agreement.integerValue == 2)
    {
        [gToast showMistake:@"请输入正确银行卡号"];
    }
    else
    {
        ConfirmClaimOp *op = [[ConfirmClaimOp alloc]init];
        op.req_claimid = self.claimid;
        op.req_agreement = agreement;
        op.req_bankcardno = [NSNumber numberWithInteger:self.bankcardno.integerValue];
        [[[op rac_postRequest]initially:^{
        }]subscribeNext:^(id x) {
            [alert show];
        }];
    }
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

@end
