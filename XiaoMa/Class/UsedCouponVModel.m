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
#import "GetUserCouponOp.h"

@interface UsedCouponVModel ()
@property (nonatomic, strong) NSMutableArray *usedCoupons;
@property (nonatomic, assign) NSInteger curPageno;
@property (nonatomic, assign) BOOL isRemain;
@end

@implementation UsedCouponVModel


- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)reloadData
{
    self.curPageno = 0;
    self.isRemain = NO;
    self.usedCoupons = [NSMutableArray array];
    [self requestUsedCoupons];
}

- (void)refreshTableView
{
    if (self.usedCoupons.count == 0 && self.usedCoupons.count == 0) {
        [self.tableView showDefaultEmptyViewWithText:@"您未使用过优惠券"];
    }
    else {
        [self.tableView hideDefaultEmptyView];
    }
    [self.tableView reloadData];
}

- (void)requestUsedCoupons
{
    NSInteger pageno = self.curPageno+1;
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = 1;
    op.pageno = pageno;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        [self.tableView.bottomLoadingView hideIndicatorText];
        if (pageno == 1) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            [self.tableView.bottomLoadingView startActivityAnimation];
        }
    }] subscribeNext:^(GetUserCouponOp * op) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self.tableView.bottomLoadingView stopActivityAnimation];

        [self.usedCoupons safetyAddObjectsFromArray:op.rsp_couponsArray];
        self.isRemain = op.rsp_couponsArray.count >= PageAmount;
        self.curPageno = pageno;
        [self refreshTableView];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [gToast showError:error.domain];
        [self refreshTableView];
    }];
    
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
    return self.usedCoupons.count;
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
    UIImage * used = [[UIImage imageNamed:@"cw_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#A7A7A7" alpha:1.0f]];//过期或已使用
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

    HKCoupon * couponDic = [self.usedCoupons safetyObjectAtIndex:indexPath.row];
    name.text = couponDic.couponName;
    description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isRemain && indexPath.row >= self.usedCoupons.count-1) {
        [self requestUsedCoupons];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
