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
#import "ShareUserCouponOp.h"
#import "SocialShareViewController.h"
#import "DownloadOp.h"
#import "NSDate+DateForText.h"

@interface MyCouponVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger whichSeg;
    NSMutableArray *unusedCouponArray;//未使用
    NSMutableArray *validCouponArray;//有效
    NSMutableArray *timeoutCouponArray;//过期
    BOOL allLoad;
    NSMutableArray *usedCouponArray;//已使用
}

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *blankImg;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *getMoreBtn;


/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;

///列表下面是否还有未使用的优惠劵
@property (nonatomic, assign) BOOL isUnusedRemain;
///列表下面是否还有使用的优惠劵
@property (nonatomic, assign) BOOL isUsedRemain;
///是否正在获取未使用的优惠劵
@property (nonatomic, assign) BOOL isLoadingUnusedCoupon;
///是否正在获取未使用的优惠劵
@property (nonatomic, assign) BOOL isLoadingUsedCoupon;
///未使用优惠券当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndexForUnused;
///已使用优惠券当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndexForUsed;


- (void)selectSegmented:(id)sender;

@end

@implementation MyCouponVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupGetMoreBtn];
    
    whichSeg = 0;
    
    self.isUnusedRemain = YES;
    self.isUsedRemain = YES;
    self.pageAmount = 10;
    self.currentPageIndexForUnused = 1;
    self.currentPageIndexForUsed = 1;
    
    unusedCouponArray = [[NSMutableArray alloc] init];
    validCouponArray = [[NSMutableArray alloc] init];
    timeoutCouponArray = [[NSMutableArray alloc] init];
    usedCouponArray = [[NSMutableArray alloc] init];

    [self requestUnuseCoupon];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - SetupUI
- (void)setupUI
{
    //将SegmentedControl添加到Navigationbar
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"未使用",@"已使用",nil];
    UISegmentedControl *segmentedControl =[[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(0, 0, 150, 30);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = RGBCOLOR(68, 187, 92);
    [view addSubview:segmentedControl];
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl addTarget:self action:@selector(selectSegmented:) forControlEvents:UIControlEventValueChanged];
    self.navigationController.navigationItem.titleView = view;
}

- (void)setupGetMoreBtn
{
    UIView *bottomView = [UIView new];
    UIButton *getMoreBtn = [UIButton new];
    [getMoreBtn setBackgroundColor:[UIColor orangeColor]];
    [getMoreBtn setTitle:@"如何获取更多优惠劵" forState:UIControlStateNormal];
    [getMoreBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
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
        make.top.equalTo(self.tableView.tableFooterView.mas_bottom).offset(-10).priorityMedium();
        make.bottom.greaterThanOrEqualTo(self.view).offset(-10).priorityHigh();
    }];
    [getMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
    
    self.bottomView = bottomView;
    self.getMoreBtn = getMoreBtn;
}


#pragma mark - Load Coupon
- (void)requestUnuseCoupon
{
//    @LYW 
//    self.currentPageIndexForUnused = self.currentPageIndexForUnused + 1;
    
//    @LYW 需要判断是否正在加载
    if (self.isLoadingUnusedCoupon)
    {
        return;
    }
    
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = CouponUnuse;
    op.pageno = self.currentPageIndexForUnused;
    [[[op rac_postRequest] initially:^{
        
        self.isLoadingUnusedCoupon = YES;
        self.tableView.showBottomLoadingView = YES;
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        
    }] subscribeNext:^(GetUserCouponOp * op) {
        
        self.isLoadingUnusedCoupon = NO;
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
        
        if (op.rsp_couponsArray.count != 0)
        {
            [unusedCouponArray addObjectsFromArray:op.rsp_couponsArray];
            
            if (op.rsp_couponsArray.count >= self.pageAmount )
            {
//                if (unusedCouponArray.count > 30)
//                {
//                    self.isUnusedRemain = NO;
//                    [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
//                }
//                else
                    self.isUnusedRemain = YES;
            }
            else
            {
                self.isUnusedRemain = NO;
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
            }
        }
        else
        {
            //没有优惠券时的页面
            self.isUnusedRemain = NO;
            if (self.currentPageIndexForUnused == 1)
            {}
            else
            {
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
            }
        }
        
        self.currentPageIndexForUnused = self.currentPageIndexForUnused + 1;
        
        [self sortCoupon];
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        
        self.isLoadingUnusedCoupon = NO;
        [self.tableView.bottomLoadingView stopActivityAnimation];
//        [gToast showError:@"获取优惠券信息失败"];
    }];
}


- (void)requestUsedCoupon
{
    if (self.isLoadingUsedCoupon)
    {
        return;
    }
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = CouponUse;
    op.pageno = self.currentPageIndexForUsed;
    [[[op rac_postRequest] initially:^{
        
        
        self.isLoadingUsedCoupon = YES;
        self.tableView.showBottomLoadingView = YES;
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
    }] subscribeNext:^(GetUserCouponOp * op) {
        
        self.isLoadingUsedCoupon = NO;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        if (op.rsp_couponsArray.count)
        {
            self.blankImg.hidden = YES;
            
            [usedCouponArray addObjectsFromArray:op.rsp_couponsArray];
            if (op.rsp_couponsArray.count >= self.pageAmount){
                self.isUsedRemain = YES;
            }
            else
            {
                self.isUsedRemain = NO;
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
            }

            [self refreshTableView];
        }
        else
        {
            //没有优惠券时的页面
            self.isUsedRemain = NO;
            if (self.currentPageIndexForUsed == 1)
            {
                
            }
            else
            {
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
            }
        }
        
        self.currentPageIndexForUsed = self.currentPageIndexForUsed + 1;
        
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        
        self.isLoadingUsedCoupon = NO;
        [self.tableView.bottomLoadingView stopActivityAnimation];
    }];
}

- (void)requestShareCoupon:(NSNumber *)cid
{
    ShareUserCouponOp * op = [ShareUserCouponOp operation];
    op.cid = cid;
    [[[op rac_postRequest] initially:^{
        
        [gToast showText:@"..."];
    }] subscribeNext:^(ShareUserCouponOp * sop) {
        
        DownloadOp * op = [[DownloadOp alloc] init];
        op.req_uri = sop.rsp_picUrl;
        [[op rac_getRequest] subscribeNext:^(DownloadOp *op) {
            
            [gToast dismiss];
            NSObject * obj = [UIImage imageWithData: op.rsp_data];
            if (obj && [obj isKindOfClass:[UIImage class]])
            {
                [self shareAction:sop andImage:(UIImage *)obj];
            }
            else
            {
                [self shareAction:sop andImage:nil];
            }
        } error:^(NSError *error) {
            
            [gToast dismiss];
            [self shareAction:sop andImage:nil];
        }];
    } error:^(NSError *error) {
        
        [gToast showError:@"无法分享"];
    }];
}





#pragma mark - Utilitly
- (void)shareAction:(ShareUserCouponOp *)op andImage:(UIImage *)image
{
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = op.rsp_title;
    vc.subtitle = op.rsp_content;
    vc.image = image ? image :[UIImage imageNamed:@"logo"];
    vc.urlStr = op.rsp_linkUrl;
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [vc setFinishAction:^{
        
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}

-(void)sortCoupon
{
//    @LYW 先要移除
    [validCouponArray removeAllObjects];
    [timeoutCouponArray removeAllObjects];
    for (HKCoupon *dic in unusedCouponArray)
    {
        if(dic.valid)
            [validCouponArray addObject:dic];
        else
            [timeoutCouponArray addObject:dic];
    }
    [self refreshTableView];
}

- (void)refreshTableView
{
    [self.tableView reloadData];
     self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+55);
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.tableView.mas_centerX);
        make.top.equalTo(self.tableView.tableFooterView.mas_bottom).offset(-10).priorityMedium();
        make.bottom.greaterThanOrEqualTo(self.view).offset(-10).priorityHigh();
    }];
    
    [self.getMoreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomView);
    }];
}


#pragma mark - segmented
- (void)selectSegmented:(id)sender
{
    UISegmentedControl * segment=sender;
    whichSeg = segment.selectedSegmentIndex;
//    if (allLoad) {
//        if (whichSeg == 0 && unusedCouponArray.count == 0) {
//            self.blankImg.hidden = NO;
//        }
//        else if (whichSeg == 0 && unusedCouponArray.count != 0) {
//            self.blankImg.hidden = YES;
//            [self.tableView reloadData];
//            self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+54);
//        }
//        
//        if (whichSeg == 1 && usedCouponArray.count == 0) {
//            self.blankImg.hidden = NO;
//        }
//        else if (whichSeg == 1 && usedCouponArray.count != 0) {
//            self.blankImg.hidden = YES;
//            [self.tableView reloadData];
//            self.tableView.contentSize=CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+54);
//        }
//    }
//    else if (whichSeg == 1) {
//        allLoad = YES;
//        [self requestUsedCoupon:1 pageno:1];
//    }
//    
//    self.isRemain = YES;
    if (whichSeg == 0)
    {
        if (!self.isUnusedRemain)
        {
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
        }
    }
    else
    {
        if (self.isUsedRemain && usedCouponArray.count == 0)
        {
            [self requestUsedCoupon];
        }
        else if (!self.isUsedRemain)
        {
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
        }
    }
    [self refreshTableView];
}

- (void)shareAction:(NSNumber *)cid
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否分享本张优惠劵" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
        
        NSInteger index = [number integerValue];
        if (index == 1)
        {
            [self requestShareCoupon:cid];
        }
    }];
    [av show];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (whichSeg == 0)
    {
        NSInteger num = timeoutCouponArray.count ? 1 : 0 + validCouponArray.count ? 1 : 0;
        return num;
    }
    else
    {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? nil : @"下列优惠券已过期";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = section == 0 ? (validCouponArray.count ? 0 : 10) : 15;
    return height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(whichSeg == 0)
    {
        return section == 0 ? validCouponArray.count : timeoutCouponArray.count;
    }
    else
    {
        return usedCouponArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell" forIndexPath:indexPath];
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell.contentView viewWithTag:1001];
    
    UIImage * carWash = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#00BFFF" alpha:1.0f]];//type = 1
    UIImage * rescue = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#0ACDC0" alpha:1.0f]];//type = 2,4
    UIImage * agency = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#FFA54F" alpha:1.0f]];//type = 3,5
    UIImage * unavailable = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#A7A7A7" alpha:1.0f]];//已过期
    
    //已使用
    UIImage * used = [[UIImage imageNamed:@"cw_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#A7A7A7" alpha:1.0f]];//过期或已使用
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
            HKCoupon *couponDic = [validCouponArray safetyObjectAtIndex:indexPath.row];;
            if (couponDic.conponType == 1) {
                [status setTitle:@"分享" forState:UIControlStateNormal];
//                @LYW
//                [status addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
                [[[status rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                    
                    [self shareAction:couponDic.couponId];
                }];
                
                backgroundImg.image = carWash;
            }
            else if (couponDic.conponType == 2 || couponDic.conponType == 4) {
//               @LYW 重用
                backgroundImg.image = rescue;
                [status setTitle:@"有效" forState:UIControlStateNormal];
            }
            else {
                backgroundImg.image = agency;
                [status setTitle:@"有效" forState:UIControlStateNormal];
            }
            name.text = couponDic.couponName;
            description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
            // @LYW 时间显示有误
            validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
        }
        else {
            [status setTitle:@"已过期" forState:UIControlStateNormal];
            backgroundImg.image = unavailable;
            HKCoupon *couponDic = [timeoutCouponArray safetyObjectAtIndex:indexPath.row];
            name.text = couponDic.couponName;
            description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
            validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
        }
    }
    else{
        [status setTitle:@"已使用" forState:UIControlStateNormal];
        backgroundImg.image = usableTicket;
//        HKCoupon *couponDic = usedCoupon[indexPath.row];
//        @LYW
        HKCoupon * couponDic = [usedCouponArray safetyObjectAtIndex:indexPath.row];
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (whichSeg == 0 && unusedCouponArray.count-1 <= indexPath.row && self.isUnusedRemain)
    {
        [self requestUnuseCoupon];
    }
    if (whichSeg == 1 && usedCouponArray.count-1 <= indexPath.row && self.isUsedRemain) {
        //[self handleData];
        [self requestUsedCoupon];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
