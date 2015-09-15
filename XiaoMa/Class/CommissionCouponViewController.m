//
//  CommissionCouponViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionCouponViewController.h"
#import "GetUserCouponByTypeOp.h"
#import "HKLoadingModel.h"

@interface CommissionCouponViewController ()<HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@end

@implementation CommissionCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    [self.loadingModel loadDataForTheFirstTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"暂无代办券";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    GetUserCouponByTypeOp * op = [GetUserCouponByTypeOp operation];
    op.type = CouponTypeAgency;
    return [[op rac_postRequest] map:^id(GetUserCouponByTypeOp *rspOp) {
        return rspOp.rsp_couponsArray;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    
    //背景图片
    UIImage * bgImage = [[[UIImage imageNamed:@"coupon_background"] imageByFilledWithColor:[UIColor colorWithHex:@"#f7b45d" alpha:1.0f]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];
    
    UIImageView * ticketBgView = (UIImageView *)[cell searchViewWithTag:1001];
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //状态
    UIButton *status = (UIButton *)[cell.contentView viewWithTag:1005];
    
    
    [status setTitle:@"有效" forState:UIControlStateNormal];
    
    HKCoupon * coupon = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    ticketBgView.image = bgImage;
    name.text = coupon.couponName;
    description.text = [NSString stringWithFormat:@"使用说明：%@",coupon.couponDescription];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[coupon.validsince dateFormatForYYMMdd2],[coupon.validthrough dateFormatForYYMMdd2]];
    
    
    return cell;
}

@end
