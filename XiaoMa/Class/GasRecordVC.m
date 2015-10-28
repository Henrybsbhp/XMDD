//
//  GasRecordVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/16.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GasRecordVC.h"
#import "GetGaschargeRecordListOp.h"
#import "HKLoadingModel.h"
#import "NSDate+DateForText.h"
#import "NSString+Split.h"

@interface GasRecordVC ()<HKLoadingModelDelegate>
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;

@property (nonatomic, strong) HKLoadingModel *loadingModel;

@property (nonatomic, assign) long long curTimetag;
@property (nonatomic,assign) int curCharegeTotal;
@property (nonatomic,assign) int curCouponedTotal;
@end

@implementation GasRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = nil;
    CKAsyncMainQueue(^{
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
        [self.loadingModel loadDataForTheFirstTime];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHeadView
{
    NSDictionary * dic1 = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
    NSDictionary * dic2 = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    NSInteger recharge = self.curCharegeTotal;
    NSInteger discount = self.curCouponedTotal;
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"今年您的油卡充值了%ld元，", (long)recharge] attributes:dic1];
    NSAttributedString * attributedStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"总计优惠了%ld元", (long)discount] attributes:dic2];
    [attributedStr appendAttributedString:attributedStr2];
    self.headLabel.attributedText = attributedStr;
    self.tableView.tableHeaderView = self.headView;
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无加油记录";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取加油记录失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        self.curTimetag = 0;
    }
    GetGaschargeRecordListOp *op = [GetGaschargeRecordListOp operation];
    op.req_payedtime = self.curTimetag;
    @weakify(self);
    return [[op rac_postRequest] map:^id(GetGaschargeRecordListOp *rspOp) {
        
        @strongify(self);
        if (rspOp.req_payedtime == 0) {
            self.curCharegeTotal = rspOp.rsp_charegetotal;
            self.curCouponedTotal = rspOp.rsp_couponedtotal;
        }
        return rspOp.rsp_gaschargeddatas;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    if (self.curTimetag == 0) {
        [self setupHeadView];
    }
    GasChargeRecord *record = [model.datasource lastObject];
    self.curTimetag = record.payedtime;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.loadingModel.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 137;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RecordCell" forIndexPath:indexPath];
    UILabel * timeLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UIImageView * logoV = (UIImageView *)[cell.contentView viewWithTag:1002];
    UILabel * cardnumLbabel = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel * rechargeLabel = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel * payLabel = (UILabel *)[cell.contentView viewWithTag:1007];
    UILabel * stateLabel = (UILabel *)[cell.contentView viewWithTag:1008];
    GasChargeRecord *record = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    
    timeLabel.text = [[NSDate dateWithUTS:@(record.payedtime)] dateFormatForYYYYMMddHHmm2];
    logoV.image = [UIImage imageNamed:record.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    cardnumLbabel.text = [record.gascardno splitByStep:4 replacement:@" "];
    rechargeLabel.text = [NSString stringWithFormat:@"￥%d", record.chargemoney];
    payLabel.text = [NSString stringWithFormat:@"支付金额：￥%d", record.paymoney];
    stateLabel.text = record.statusdesc;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndex:indexPath.section promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
