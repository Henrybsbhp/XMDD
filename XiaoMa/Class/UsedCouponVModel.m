//
//  UsedCouponVModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UsedCouponVModel.h"
#import "XiaoMa.h"
#import "HKCoupon.h"
#import "GetUserCouponV2Op.h"

@interface UsedCouponVModel ()<HKLoadingModelDelegate>
@property (nonatomic, assign) NSInteger curPageno;

@end

@implementation UsedCouponVModel


- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showBottomLoadingView = YES;
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    }
    return self;
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"您未使用过优惠券";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取已使用优惠券失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    if (type != HKDatasourceLoadingTypeLoadMore) {
        self.curPageno = 0;
    }

    GetUserCouponV2Op *op = [GetUserCouponV2Op operation];
    op.used = 1;
    op.pageno = self.curPageno+1;
    return [[op rac_postRequest] map:^id(GetUserCouponV2Op *rspOp) {
        
        self.curPageno = self.curPageno+1;
        return rspOp.rsp_couponsArray;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loadingModel.datasource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell.contentView viewWithTag:1001];
    
    //已使用
    UIImage * used = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#d0d0d0" alpha:1.0f]];//过期或已使用
    UIImage * usableTicket = [used resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];
    
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //状态
    UIButton *status = (UIButton *)[cell.contentView viewWithTag:1005];
    
    UIImageView * lineImageView = (UIImageView *)[cell searchViewWithTag:102];
    lineImageView.backgroundColor = [UIColor colorWithHex:@"#000000" alpha:0.1];
    
    [status setTitle:@"已使用" forState:UIControlStateNormal];
    backgroundImg.image = usableTicket;

    HKCoupon * couponDic = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    name.text = couponDic.couponName;
    description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp304-5"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
