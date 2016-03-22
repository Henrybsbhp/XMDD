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
@property (nonatomic,strong) NSString *cardname;
@property (nonatomic,strong) NSString *cardno;

@property (nonatomic) BOOL hasCard;

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
    if (self.status.integerValue == 0 || self.status.integerValue == 20)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((self.status.integerValue != 0 && self.status.integerValue != 20) && section == 1)
    {
        return 2;
    }
    else
    {
        return 1;
    }
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
    else if (indexPath.section == 1 && self.status.integerValue != 0 && self.status.integerValue != 20)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"feeCell"];
            UILabel *feeLb = [cell viewWithTag:100];
            feeLb.text = [NSString formatForPriceWithFloat:self.claimfee];
        }
        if (self.hasCard && indexPath.row ==1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell"];
            UILabel *cardNumLb = [cell viewWithTag:100];
            UILabel *bankLb = [cell viewWithTag:1010];
            cardNumLb.text = self.cardno;
            bankLb.text = self.cardname;
        }
        else if(!self.hasCard && indexPath.row ==1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"selectCardCell"];
        }
    }
    else
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 50;
    }
    else if (indexPath.section == 1 && self.status.integerValue != 0 && self.status.integerValue != 20)
    {
        if (indexPath.row == 0)
        {
            return 68;
        }
        else
        {
            return 43;
        }
        
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height);
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
    if (!self.hasCard && indexPath.row ==1 && indexPath.section == 1 && self.status.integerValue != 0 && self.status.integerValue != 20)
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
        self.cardid = op.rsp_cardid;
        self.hasCard = op.rsp_cardid.integerValue == 0 ? NO : YES;
        self.cardname = op.rsp_cardname;
        self.cardno = op.rsp_cardno;
        if (self.status.integerValue == 1)
        {
            self.bottomView.hidden = NO;
        }
        else
        {
            self.bottomView.hidden = YES;
        }
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [self.view stopActivityAnimation];
    }];
    
}

#pragma mark Action

- (IBAction)call:(id)sender {
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}

#pragma mark Init

-(void)setupUI
{
    [self addCorner:self.agreeBtn];
    [self addCorner:self.disagreeBtn];
    [self addBorder:self.disagreeBtn];
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
    if (self.cardid.integerValue != 0)
    {
        ConfirmClaimOp *op = [[ConfirmClaimOp alloc]init];
        [[[op rac_postRequest]initially:^{
            [gToast showingWithText:@"提交中"];
        }]subscribeNext:^(id x) {
            [gToast showSuccess:@"提交成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
    {
        [gToast showMistake:@"请添加银行卡"];
    }
}

#pragma mark Utility

-(void)addCorner:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
}

-(void)addBorder:(UIView *)view
{
    view.layer.borderColor = [[UIColor colorWithHex:@"#18D06A" alpha:1]CGColor];
    view.layer.borderWidth = 1;
}

@end
