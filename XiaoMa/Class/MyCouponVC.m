//
//  MyCouponVC.m
//  XiaoMa
//
//  Created by Yawei Liu on 15/5/8.
//  Copyright (c) 2015年 Hangzhou Huika Tech.. All rights reserved.
//

#import "MyCouponVC.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "GetUserCouponOp.h"
#import "HKCoupon.h"

@interface MyCouponVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger whichSeg;
    NSArray *unused;//未使用
    NSMutableArray *validCoupon;//有效
    NSMutableArray *timeoutCoupon;//过期
    BOOL allLoad;
    NSMutableArray *usedCoupon;//已使用
}

@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentedControl;

- (IBAction)selectSegmented:(id)sender;

@end

@implementation MyCouponVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    [self.navBarItem setLeftBarButtonItem:back animated:YES];
    whichSeg = 0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    validCoupon = [[NSMutableArray alloc] init];
    timeoutCoupon = [[NSMutableArray alloc] init];
    usedCoupon = [[NSMutableArray alloc] init];
    [self requestValidCoupon:2 pageno:1];
}

-(void)actionBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Load Coupon
- (void)requestValidCoupon:(NSInteger)used pageno:(NSInteger)pageno
{
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = used;
    op.pageno = pageno;
    [[[op rac_postRequest] initially:^{
        [SVProgressHUD showWithStatus:@"Loading..."];
    }] subscribeNext:^(GetUserCouponOp * op) {
        if (op.rsp_couponsArray.count != 0)
        {
            unused = op.rsp_couponsArray;
            [self sortCoupon];
        }
        else
        {
            //没有优惠券时的页面
            [self handleData];//测试数据
        }
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        [SVProgressHUD  showErrorWithStatus:@"获取优惠券信息失败"];
    }];
}

-(void)sortCoupon
{
    for (HKCoupon *dic in unused) {
        if(dic.valid)
            [validCoupon addObject:dic];
        else
            [timeoutCoupon addObject:dic];
    }
    [self handleData];
}

- (void)requestUsedCoupon:(NSInteger)used pageno:(NSInteger)pageno
{
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = used;
    op.pageno = pageno;
    [[[op rac_postRequest] initially:^{
        [SVProgressHUD showWithStatus:@"Loading..."];
    }] subscribeNext:^(GetUserCouponOp * op) {
        if (op.rsp_couponsArray.count)
        {
            [usedCoupon addObjectsFromArray:nil];
            [self handleData];
        }
        else
        {
            //没有优惠券时的页面
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        [SVProgressHUD  showErrorWithStatus:@"获取优惠券信息失败"];
    }];
}

-(void)handleData
{
    //以下是测试数据
    HKCoupon *testDate1 = [[HKCoupon alloc]init];
    testDate1.couponName = @"这是个有效优惠券哟";
    testDate1.couponDescription = @"此处是测试优惠券的描述哟";
    testDate1.used = NO;
    testDate1.valid = YES;
    NSDate *now = [NSDate date];
    testDate1.validsince = now;
    [validCoupon addObject:testDate1];
    HKCoupon *testDate2 = [[HKCoupon alloc]init];
    testDate2.couponName = @"这是个过期优惠券哟";
    testDate2.couponDescription = @"此处是测试优惠券的描述哟";
    testDate2.used = NO;
    testDate2.valid = NO;
    testDate2.validsince = now;
    [timeoutCoupon addObject:testDate2];
    HKCoupon *testDate3 = [[HKCoupon alloc]init];
    testDate3.couponName = @"这是个已使用优惠券哟";
    testDate3.couponDescription = @"此处是测试优惠券的描述哟";
    testDate3.used = YES;
    testDate3.valid = YES;
    testDate3.validsince = now;
    [usedCoupon addObject:testDate3];
    
    [self.tableView reloadData];
}

#pragma mark - segmented
- (IBAction)selectSegmented:(id)sender {
    whichSeg = self.SegmentedControl.selectedSegmentIndex;
    if (whichSeg == 1 && !allLoad) {
        allLoad = YES;
        [self requestUsedCoupon:1 pageno:1];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (timeoutCoupon.count != 0)
        return whichSeg == 0 ? 2 : 1;
    else
        return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? nil : @"下列优惠券已过期";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 10 : 15;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(whichSeg == 0)
        return section == 0 ? validCoupon.count : timeoutCoupon.count;
    else
        return usedCoupon.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell.contentView viewWithTag:1001];
    UIImage * usable = [UIImage imageNamed:@"cw_ticket_bg"];
    UIImage * usableTicket = [usable resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage * unavailable = [UIImage imageNamed:@"me_ticket_bg"];
    UIImage * unavailableTicket = [unavailable resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //状态
    UILabel *status = (UILabel *)[cell.contentView viewWithTag:1005];
    
    NSUInteger section = [indexPath section];
    if (whichSeg == 0) {
        if (section == 0){
            status.text = @"有效";
            backgroundImg.image = usableTicket;
            HKCoupon *couponDic = validCoupon[indexPath.row];
            name.text = couponDic.couponName;
            description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
            validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",couponDic.validsince,couponDic.validthrough];
        }
        else{
            status.text = @"已过期";
            backgroundImg.image = unavailableTicket;
            HKCoupon *couponDic = timeoutCoupon[indexPath.row];
            name.text = couponDic.couponName;
            description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
            validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",couponDic.validsince,couponDic.validthrough];
        }
    }
    else{
        status.text = @"已使用";
        backgroundImg.image = unavailableTicket;
        HKCoupon *couponDic = usedCoupon[indexPath.row];
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",couponDic.validsince,couponDic.validthrough];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
