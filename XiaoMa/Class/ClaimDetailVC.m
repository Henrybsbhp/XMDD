//
//  ClaimDetailVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ClaimDetailVC.h"
#import "GetCooperationClaimDetailOp.h"
#import "NSString+Price.h"

@interface ClaimDetailVC ()<UITableViewDelegate,UITableViewDataSource>
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


@end

@implementation ClaimDetailVC

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
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        if (self.status.integerValue == 0 || self.status.integerValue == 20)
        {
            return 1;
        }
        else
        {
            return 2;
        }
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
    else
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
            UILabel *timeLb = [cell viewWithTag:100];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            UILabel *locationLb = [cell viewWithTag:101];
            UILabel *dutyLb = [cell viewWithTag:102];
            UILabel *conditionLb = [cell viewWithTag:103];
            UILabel *reasonLb = [cell viewWithTag:104];
            timeLb.text = [NSString stringWithFormat:@"%@",[format dateFromString:self.accidenttime]];
            locationLb.text = self.accidentaddress;
            dutyLb.text = self.chargepart;
            conditionLb.text = self.cardmgdesc;
            reasonLb.text = self.reason;
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"feeCell"];
            UILabel *feeLb = [cell viewWithTag:100];
            feeLb.text = [[NSString formatForPriceWithFloat:self.claimfee]append:@"元"];
            UIView *view = [cell viewWithTag:101];
            view.layer.borderWidth = 1;
            view.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
        }
    }
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 50;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            return UITableViewAutomaticDimension;
        }
        else
        {
            return 140;
        }
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
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
        self.cardname = op.rsp_cardname;
        if (self.status.integerValue == 2)
        {
            self.bottomView.hidden = NO;
        }
        else
        {
            self.bottomView.hidden = YES;
        }
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
    self.agreeBtn.layer.cornerRadius = 5;
    self.agreeBtn.layer.masksToBounds = YES;
    self.disagreeBtn.layer.cornerRadius = 5;
    self.disagreeBtn.layer.masksToBounds = YES;
    self.disagreeBtn.layer.borderColor = [[UIColor colorWithHex:@"#18D06A" alpha:1]CGColor];
    self.disagreeBtn.layer.borderWidth = 1;
    self.tableView.tableFooterView = [UIView new];
}

@end
