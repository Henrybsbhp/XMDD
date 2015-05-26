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
@property (weak, nonatomic) IBOutlet UIImageView *blankImg;


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
    
    self.isRemain = YES;
    self.pageAmount = 10;
    self.currentPageIndexForUnused = 1;
    self.currentPageIndexForUsed = 1;
    
    unused = [[NSMutableArray alloc] init];
    validCoupon = [[NSMutableArray alloc] init];
    timeoutCoupon = [[NSMutableArray alloc] init];
    usedCoupon = [[NSMutableArray alloc] init];
    self.tableView.showBottomLoadingView = YES;
    [self setupGetMoreBtn];
    [self requestValidCoupon:2 pageno:self.currentPageIndexForUnused];
}

- (void)setupGetMoreBtn
{
    UIView *bottomView = [UIView new];
    UIButton *getMoreBtn = [UIButton new];
    [getMoreBtn setBackgroundColor:[UIColor orangeColor]];
    [getMoreBtn setTitle:@"如何获取更多优惠劵" forState:UIControlStateNormal];
    getMoreBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    getMoreBtn.cornerRadius = 5.0f;
    [getMoreBtn.layer setMasksToBounds:YES];
    [[getMoreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        //按钮点击获取更多优惠券事件
    }];
    [bottomView addSubview:getMoreBtn];
    [self.tableView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.tableView.mas_centerX);
        make.top.equalTo(self.tableView.tableFooterView.mas_bottom).priorityMedium();
        make.bottom.greaterThanOrEqualTo(self.view).offset(-10).priorityHigh();
    }];
    [getMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
}


#pragma mark - Load Coupon
- (void)requestValidCoupon:(NSInteger)used pageno:(NSInteger)pageno
{
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
        }
        else
        {
            //没有优惠券时的页面
            self.isRemain = NO;
            self.blankImg.hidden = NO;
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
    self.currentPageIndexForUsed = self.currentPageIndexForUsed + 1;
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = used;
    op.pageno = pageno;
    [[[op rac_postRequest] initially:^{
        [SVProgressHUD showWithStatus:@"Loading..."];
    }] subscribeNext:^(GetUserCouponOp * op) {
        if (op.rsp_couponsArray.count)
        {
            self.blankImg.hidden = YES;
            
            [usedCoupon addObjectsFromArray:op.rsp_couponsArray];
            if (usedCoupon.count >= self.pageAmount){
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
            self.isRemain = NO;
            self.blankImg.hidden = NO;
        }
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        [SVProgressHUD  showErrorWithStatus:@"获取优惠券信息失败"];
    }];
}

-(void)handleData
{
    //以下是测试数据
    
    //模拟数据时的点点点
//    [self.tableView.bottomLoadingView hideIndicatorText];
//    [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
//    NSDate *now = [NSDate date];
//    for (int i=0; i<12; i++) {
//        HKCoupon *testDate1 = [[HKCoupon alloc]init];
//        testDate1.couponName = @"这是个有效优惠券哟";
//        testDate1.couponDescription = @"此处是测试优惠券的描述哟";
//        testDate1.used = NO;
//        testDate1.valid = YES;
//        testDate1.validsince = now;
//        if (i == 3)
//        {
//            testDate1.conponType=2;
//        }
//        if (i == 5)
//        {
//            testDate1.conponType=1;
//        }
//        [validCoupon addObject:testDate1];
//        [unused addObject:testDate1];
//    }
////    HKCoupon *testDate2 = [[HKCoupon alloc]init];
////    testDate2.couponName = @"这是个过期优惠券哟";
////    testDate2.couponDescription = @"此处是测试优惠券的描述哟";
////    testDate2.used = NO;
////    testDate2.valid = NO;
////    testDate2.validsince = now;
////    [timeoutCoupon addObject:testDate2];
//    for (int i=0; i<12; i++) {
//        HKCoupon *testDate3 = [[HKCoupon alloc]init];
//        testDate3.couponName = @"这是个已使用优惠券哟";
//        testDate3.couponDescription = @"此处是测试优惠券的描述哟";
//        testDate3.used = YES;
//        testDate3.valid = YES;
//        testDate3.validsince = now;
//        [usedCoupon addObject:testDate3];
//    }
    
    [self.tableView reloadData];

    self.tableView.contentSize=CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+54);
}

#pragma mark - segmented
- (void)selectSegmented:(id)sender {
    UISegmentedControl * segment=sender;
    whichSeg = segment.selectedSegmentIndex;
    if (allLoad) {
        if (whichSeg == 0 && unused.count == 0) {
            self.blankImg.hidden = NO;
        }
        else if (whichSeg == 0 && unused.count != 0) {
            self.blankImg.hidden = YES;
            [self.tableView reloadData];
            self.tableView.contentSize=CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+54);
        }
        
        if (whichSeg == 1 && usedCoupon.count == 0) {
            self.blankImg.hidden = NO;
        }
        else if (whichSeg == 1 && usedCoupon.count != 0) {
            self.blankImg.hidden = YES;
            [self.tableView reloadData];
            self.tableView.contentSize=CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+54);
        }
    }
    else if (whichSeg == 1) {
        allLoad = YES;
        [self requestUsedCoupon:1 pageno:1];
        
        //测试操作
//        [self.tableView reloadData];
//        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+54);
    }
    
    self.isRemain = YES;
}

-(void) shareAction
{
    //此处分享优惠券
    NSLog(@"%@",unused);
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
    //模拟数据时的点点点消失
    [self.tableView.bottomLoadingView stopActivityAnimation];
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
    
    UIImage * carWash = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#00BFFF" alpha:1.0f]];//type = 1
    UIImage * rescue = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#0ACDC0" alpha:1.0f]];//type = 2,4
    UIImage * agency = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#FFA54F" alpha:1.0f]];//type = 3,5
    UIImage * unavailable = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#0ACDC0" alpha:1.0f]];//已过期
    
    //已使用
    UIImage * used = [[UIImage imageNamed:@"cw_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#0ACDC0" alpha:1.0f]];//过期或已使用
    UIImage * usableTicket = [used resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //状态
    UIButton *status = (UIButton *)[cell.contentView viewWithTag:1005];
    
    NSUInteger section = [indexPath section];
    if (whichSeg == 0) {
        if (section == 0){
            HKCoupon *couponDic = validCoupon[indexPath.row];
            if (couponDic.conponType == 1) {
                status.enabled = YES;
                [status setTitle:@"分享" forState:UIControlStateNormal];
                [status addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
                backgroundImg.image = carWash;
            }
            else if (couponDic.conponType == 2 || couponDic.conponType == 4) {
                backgroundImg.image = rescue;
            }
            else {
                backgroundImg.image = agency;
            }
            name.text = couponDic.couponName;
            description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
            validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",couponDic.validsince,couponDic.validthrough];
        }
        else {
            [status setTitle:@"已过期" forState:UIControlStateNormal];
            backgroundImg.image = unavailable;
            HKCoupon *couponDic = timeoutCoupon[indexPath.row];
            name.text = couponDic.couponName;
            description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
            validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",couponDic.validsince,couponDic.validthrough];
        }
    }
    else{
        [status setTitle:@"已使用" forState:UIControlStateNormal];
        backgroundImg.image = usableTicket;
        HKCoupon *couponDic = usedCoupon[indexPath.row];
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",couponDic.validsince,couponDic.validthrough];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (whichSeg == 0 && unused.count-1 <= indexPath.row && self.isRemain) {
        //[self handleData];
        [self requestValidCoupon:2 pageno:self.currentPageIndexForUnused];
    }
    if (whichSeg == 1 && usedCoupon.count-1 <= indexPath.row && self.isRemain) {
        //[self handleData];
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
