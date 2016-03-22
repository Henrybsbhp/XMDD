//
//  ClaimAccountVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsClaimAccountVC.h"
#import "GetCooperationClaimBankcardOp.h"
#import "MutualInsChooseBankVC.h"
@interface MutualInsClaimAccountVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) NSString *bankName;
@end

@implementation MutualInsClaimAccountVC

-(void)dealloc
{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataArr.count == 0)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArr.count == 0)
    {
        return 5;
    }
    else
    {
        if (section == 0)
        {
            return 1 + self.dataArr.count;
        }
        else
        {
            return 5;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self titleCellForRowAtIndexPath:indexPath];
    }
    else if(indexPath.section == 0 && indexPath.row == 1 && self.dataArr.count != 0 )
    {
        cell = [self cardCellForRowAtIndexPath:indexPath];
    }
    else if ((indexPath.row == 1 && self.dataArr.count == 0 && indexPath.section == 0) || indexPath.row == 2 )
    {
        cell = [self inputCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.row == 3)
    {
        cell = [self chooseCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.row == 4)
    {
        cell = [self commitCellForRowAtIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *)titleCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"titleCell"];
    UILabel *titleLb = [cell viewWithTag:100];
    titleLb.text = indexPath.section == 0 ? @"已有账户" : @"添加其他理赔账户";
    return cell;
}

-(UITableViewCell *)cardCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cardCell"];
    NSDictionary *dic = [self.dataArr safetyObjectAtIndex:indexPath.row - 1];
    UILabel *carNum = [cell viewWithTag:100];
    UILabel *bankName = [cell viewWithTag:101];
    carNum.text = dic[@"cardno"];
    bankName.text = dic[@"issuebank"];
    return cell;
}

-(UITableViewCell *)inputCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"inputCell"];
    UITextField *textField = [cell viewWithTag:100];
    textField.placeholder = indexPath.row == 1 ? @"请输入银行卡号":@"请再次输入银行卡号";
    [self addBorder:textField];
    return cell;
}

-(UITableViewCell *)chooseCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"chooseCell"];
    UIView *backgroundView = [cell viewWithTag:100];
    UILabel *label = [cell viewWithTag:1010];
    label.text = self.bankName.length ? self.bankName : @"请选择银行";
    label.textColor = self.bankName.length ? [UIColor colorWithHex:@"#000000" alpha:1] : [UIColor colorWithHex:@"#DBDBDB" alpha:1];
    [self addBorder:backgroundView];
    return cell;
}

-(UITableViewCell *)commitCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"commitCell"];
    UIButton *btn = [cell viewWithTag:100];
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntilForCell:cell] subscribeNext:^(id x) {
//        @叶志成 提交操作
    }];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        MutualInsChooseBankVC *chooseBankVC = [UIStoryboard vcWithId:@"MutualInsChooseBankVC" inStoryboard:@"MutualInsClaims"];
        @weakify(self)
        [chooseBankVC setBankName:^(NSString *str) {
            @strongify(self)
            self.bankName = str;
            [self.tableView reloadData];
        }];
        [self.navigationController pushViewController:chooseBankVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 48;
    }
    else
    {
        return 60;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 5;
    }
    return CGFLOAT_MIN;
}

#pragma mark Action

- (IBAction)callAction:(id)sender {
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}

#pragma mark Utility

-(void)addBorder:(UIView *)view
{
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
}

-(void)getData
{
//    @叶志成 可能要删除这个接口
    GetCooperationClaimBankcardOp *op = [GetCooperationClaimBankcardOp new];
    [[[op rac_postRequest]initially:^{
        [self.tableView startActivityAnimationWithType:GifActivityIndicatorType];
    }]subscribeNext:^(GetCooperationClaimBankcardOp *op) {
        [self.tableView stopActivityAnimation];
        self.dataArr = op.rsp_cardlist;
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [self.tableView stopActivityAnimation];
        [gToast showMistake:error.domain];
    }];
}

-(NSArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [[NSArray alloc]init];
    }
    return _dataArr;
}

@end
