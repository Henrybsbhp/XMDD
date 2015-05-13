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
#import "JTTableView.h"

@interface MyCouponVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger whichSeg;
    NSMutableArray *unused;//未使用
    NSMutableArray *validCoupon;//有效
    NSMutableArray *timeoutCoupon;//过期
    BOOL allLoad;
    NSMutableArray *usedCoupon;//已使用
}

@property (weak, nonatomic) IBOutlet JTTableView *tableView;

/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;
///列表下面是否还有商品
@property (nonatomic, assign) BOOL isRemain;
///未使用优惠券当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndexForUnused;
///已使用优惠券当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndexForUsed;

- (void)selectSegmented:(id)sender;

@end

@implementation MyCouponVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //将SegmentedControl添加到Navigationbar
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"未使用",@"已使用",nil];
    UISegmentedControl *segmentedControl =[[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(0, 0, 150, 30);
    segmentedControl.selectedSegmentIndex=0;
    segmentedControl.tintColor = RGBCOLOR(68, 187, 92);
    [view addSubview:segmentedControl];
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl addTarget:self action:@selector(selectSegmented:) forControlEvents:UIControlEventValueChanged];
    self.navigationController.navigationItem.titleView = view;
    
    whichSeg = 0;
    self.tableView.showBottomLoadingView = YES;
    
    self.isRemain = YES;
    self.pageAmount = 10;
    self.currentPageIndexForUnused = 1;
    self.currentPageIndexForUsed = 1;
    
    unused = [[NSMutableArray alloc] init];
    validCoupon = [[NSMutableArray alloc] init];
    timeoutCoupon = [[NSMutableArray alloc] init];
    usedCoupon = [[NSMutableArray alloc] init];
    [self requestValidCoupon:2 pageno:self.currentPageIndexForUnused];
}

#pragma mark - Load Coupon
- (void)requestValidCoupon:(NSInteger)used pageno:(NSInteger)pageno
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    self.currentPageIndexForUnused = self.currentPageIndexForUnused + 1;
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = used;
    op.pageno = pageno;
    [[[op rac_postRequest] initially:^{
        [SVProgressHUD showWithStatus:@"Loading..."];
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
    }] subscribeNext:^(GetUserCouponOp * op) {
        [self.tableView.bottomLoadingView stopActivityAnimation];
        if (op.rsp_couponsArray.count != 0)
        {
            [unused addObjectsFromArray:op.rsp_couponsArray];
            if (unused.count >= self.pageAmount){
                self.isRemain = YES;
            }
            else{
                self.isRemain = NO;
            }
            if (!self.isRemain){
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
            }
            [self.tableView reloadData];
        }
        else
        {
            //没有优惠券时的页面
            [self handleData];//测试数据
        }
        [self sortCoupon];
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
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    self.currentPageIndexForUsed = self.currentPageIndexForUsed + 1;
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = used;
    op.pageno = pageno;
    [[[op rac_postRequest] initially:^{
        [SVProgressHUD showWithStatus:@"Loading..."];
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
    }] subscribeNext:^(GetUserCouponOp * op) {
        if (op.rsp_couponsArray.count)
        {
            [usedCoupon addObjectsFromArray:op.rsp_couponsArray];
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
- (void)selectSegmented:(id)sender {
    UISegmentedControl * segment=sender;
    whichSeg = segment.selectedSegmentIndex;
    if (whichSeg == 1 && !allLoad) {
        allLoad = YES;
        [self requestUsedCoupon:1 pageno:1];
    }
    if (allLoad) {
        [self.tableView reloadData];
    }
    self.isRemain = YES;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",self.currentPageIndexForUnused);
    if (whichSeg == 0 && unused.count-1 <= indexPath.row && self.isRemain) {
        [self requestValidCoupon:2 pageno:self.currentPageIndexForUnused];
    }
    if (whichSeg == 1 && usedCoupon.count-1 <= indexPath.row && self.isRemain) {
        [self requestUsedCoupon:1 pageno:self.currentPageIndexForUsed];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
