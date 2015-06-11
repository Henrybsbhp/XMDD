//
//  UnusedCouponVModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UnusedCouponVModel.h"
#import "XiaoMa.h"
#import "GetUserCouponOp.h"
#import "HKCoupon.h"
#import "SocialShareViewController.h"
#import "ShareUserCouponOp.h"
#import "DownloadOp.h"

@interface UnusedCouponVModel ()
@property (nonatomic, strong) NSMutableArray *validCoupons;//有效
@property (nonatomic, strong) NSMutableArray *overdueCoupons;//过期
@property (nonatomic, assign) NSInteger curPageno;
@property (nonatomic, assign) BOOL isRemain;
@end

@implementation UnusedCouponVModel

- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        self.tableView.showBottomLoadingView = YES;
    }
    return self;
}

- (void)reloadData
{
    self.curPageno = 0;
    self.isRemain = NO;
    self.validCoupons = [NSMutableArray array];
    self.overdueCoupons = [NSMutableArray array];
    [self requestUnuseCoupons];
}

- (void)refreshTableView
{
    if (self.validCoupons.count == 0 && self.overdueCoupons.count == 0) {
        [self.tableView showDefaultEmptyViewWithText:@"暂无优惠券"];
    }
    else {
        [self.tableView hideDefaultEmptyView];
    }
    [self.tableView reloadData];
}

- (void)requestUnuseCoupons
{
    NSInteger pageno = self.curPageno+1;
    GetUserCouponOp * op = [GetUserCouponOp operation];
    op.used = 2;
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

        [self sortCoupons:op.rsp_couponsArray];
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

#pragma mark - Share
- (void)requestShareCoupon:(NSNumber *)cid
{
    ShareUserCouponOp * op = [ShareUserCouponOp operation];
    op.cid = cid;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"分享信息获取中..."];
    }] subscribeNext:^(ShareUserCouponOp * sop) {
        
        [gToast dismiss];
        [self shareAction:sop andImage:nil];
        
        
//        DownloadOp * op = [[DownloadOp alloc] init];
//        op.req_uri = sop.rsp_picUrl;
//        [[op rac_getRequest] subscribeNext:^(DownloadOp *op) {
//            
//            [gToast dismiss];
//            NSObject * obj = [UIImage imageWithData: op.rsp_data];
//            if (obj && [obj isKindOfClass:[UIImage class]])
//            {
//                [self shareAction:sop andImage:(UIImage *)obj];
//            }
//            else
//            {
//                [self shareAction:sop andImage:nil];
//            }
//        } error:^(NSError *error) {
//            
//            [gToast dismiss];
//            [self shareAction:sop andImage:nil];
//        }];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)shareAction:(NSNumber *)cid
{
    [MobClick event:@"rp304-3"];
    
    [self requestShareCoupon:cid];
}

- (void)shareAction:(ShareUserCouponOp *)op andImage:(UIImage *)image
{
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = op.rsp_title;
    vc.subtitle = op.rsp_content;
    vc.image = [UIImage imageNamed:@"wechat_share_coupon"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_carwash"];
    vc.urlStr = op.rsp_linkUrl;
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [vc setFinishAction:^{
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [MobClick event:@"rp110-7"];
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}

#pragma mark - Utility
-(void)sortCoupons:(NSArray *)coupons
{
    for (HKCoupon *cpn in coupons)
    {
        if (cpn.valid) {
            [self.validCoupons addObject:cpn];
        }
        else {
            [self.overdueCoupons addObject:cpn];
        }
    }
}
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1 && self.overdueCoupons.count > 0) {
        return @"下列优惠券已过期";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 10;
    if (section == 1 && self.overdueCoupons.count > 0) {
        height = 25;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.validCoupons.count : self.overdueCoupons.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell.contentView viewWithTag:1001];
    
    UIImage * carWash = [[[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#5fb8e2" alpha:1.0f]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];//type = 1
    UIImage * cashImage = [[[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#f54a4a" alpha:1.0f]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];//type = 2
    UIImage * rescue = [[[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#4bc4b3" alpha:1.0f]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];//type = 2,4
    UIImage * agency = [[[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#f7b45d" alpha:1.0f]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];//type = 3,5
    UIImage * unavailable = [[[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#d0d0d0" alpha:1.0f]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];//已过期
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //状态
    UIButton *status = (UIButton *)[cell.contentView viewWithTag:1005];
    
    NSUInteger section = [indexPath section];
    if (section == 0){
        HKCoupon *couponDic = [self.validCoupons safetyObjectAtIndex:indexPath.row];;
        if (couponDic.conponType == CouponTypeCarWash) {
            [status setTitle:@"分享" forState:UIControlStateNormal];
            [[[status rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                [self shareAction:couponDic.couponId];
            }];
            
            backgroundImg.image = carWash;
        }
        else if (couponDic.conponType == CouponTypeCash || couponDic.conponType == CouponTypeInsurance) {
            backgroundImg.image = cashImage;
            [status setTitle:@"有效" forState:UIControlStateNormal];
            
            [[[status rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                [MobClick event:@"rp304-4"];
            }];
        }
        else if (couponDic.conponType == CouponTypeAgency)
        {
            backgroundImg.image = agency;
            [status setTitle:@"有效" forState:UIControlStateNormal];
            
            [[[status rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                [MobClick event:@"rp304-4"];
            }];
        }
        else if (couponDic.conponType == CouponTypeRescue)
        {
            backgroundImg.image = rescue;
            [status setTitle:@"有效" forState:UIControlStateNormal];
        }
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    }
    else {
        [status setTitle:@"已过期" forState:UIControlStateNormal];
        backgroundImg.image = unavailable;
        HKCoupon *couponDic = [self.overdueCoupons safetyObjectAtIndex:indexPath.row];
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.refreshView.refreshing) {
        return;
    }
    if (self.isRemain && indexPath.section == 0 &&  self.overdueCoupons.count == 0 && indexPath.row >= self.validCoupons.count-1) {
        [self requestUnuseCoupons];
    }
    else if (self.isRemain && indexPath.section == 1 && indexPath.row >= self.overdueCoupons.count-1) {
        [self requestUnuseCoupons];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp304-5"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
