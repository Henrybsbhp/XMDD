//
//  CommissionCouponViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionCouponViewController.h"
#import "GetUserCouponByTypeOp.h"

@interface CommissionCouponViewController ()

@property (nonatomic,strong)NSArray * couponArray;
@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@end

@implementation CommissionCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView.refreshView addTarget:self action:@selector(requestCoupon) forControlEvents:UIControlEventValueChanged];
    [self requestCoupon];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestCoupon
{
    GetUserCouponByTypeOp * op = [GetUserCouponByTypeOp operation];
    op.type = CouponTypeAgency;
    [[[op rac_postRequest] initially:^{
        
        [self.tableView.refreshView beginRefreshing];
    }] subscribeNext:^(GetUserCouponByTypeOp * op) {
        
        [self.tableView.refreshView endRefreshing];
        self.couponArray = op.rsp_couponsArray;
        [self.tableView reloadData];
        if (self.couponArray.count == 0) {
            [self.tableView showDefaultEmptyViewWithText:@"暂无免费券"];
        }
        else {
            [self.tableView hideDefaultEmptyView];
        }
    } error:^(NSError *error) {
        
        [self.tableView.refreshView endRefreshing];
        [self.tableView showDefaultEmptyViewWithText:@"刷新失败"];
    }];
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
    
    return self.couponArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    
    //背景图片
    UIImage * bgImage = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#00BFFF" alpha:1.0f]];
    
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
    
    HKCoupon * coupon = [self.couponArray safetyObjectAtIndex:indexPath.row];
    ticketBgView.image = bgImage;
    name.text = coupon.couponName;
    description.text = [NSString stringWithFormat:@"使用说明：%@",coupon.couponDescription];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[coupon.validsince dateFormatForYYMMdd2],[coupon.validthrough dateFormatForYYMMdd2]];
    
    
    return cell;
}

@end
