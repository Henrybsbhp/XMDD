//
//  UnusedCouponVModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UnusedCouponVModel.h"
#import "XiaoMa.h"
#import "GetUserCouponV2Op.h"
#import "HKCoupon.h"
#import "SocialShareViewController.h"
#import "ShareUserCouponOp.h"
#import "DownloadOp.h"

@interface UnusedCouponVModel ()<HKLoadingModelDelegate>
@property (nonatomic, assign) NSInteger curPageno;
@end

@implementation UnusedCouponVModel

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

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"暂无优惠券";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取未使用优惠券失败，点击重试";
}

- (NSArray *)loadingModel:(HKLoadingModel *)model datasourceFromLoadedData:(NSArray *)data withType:(HKDatasourceLoadingType)type
{
    NSMutableArray *datasource;
    if (type == HKDatasourceLoadingTypeLoadMore) {
        datasource = (NSMutableArray *)model.datasource;
    }
    
    if (!datasource) {
        datasource = [NSMutableArray array];
        [datasource addObject:[NSMutableArray array]];
    }
    
    NSMutableArray *array1 = [datasource safetyObjectAtIndex:0];
    NSMutableArray *array2 = [datasource safetyObjectAtIndex:1];
    for (HKCoupon *cpn in data)
    {
        if (cpn.valid) {
            [array1 addObject:cpn];
        }
        else {
            if (!array2) {
                array2 = [NSMutableArray array];
                [datasource addObject:array2];
            }
            [array2 addObject:cpn];
        }
    }
    return datasource;
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    if (type != HKDatasourceLoadingTypeLoadMore) {
        self.curPageno = 0;
    }
    
    GetUserCouponV2Op * op = [GetUserCouponV2Op operation];
    op.used = 2;
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
    return self.loadingModel.datasource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"下列优惠券已过期";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 10;
    if (section == 1) {
        height = 25;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.loadingModel.datasource safetyObjectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell.contentView viewWithTag:1001];
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //状态
    UIButton *statusB = (UIButton *)[cell.contentView viewWithTag:1005];
    
    HKCoupon *couponDic = [[self.loadingModel.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    
    NSUInteger section = [indexPath section];
    NSString *bgColorName;
    NSString *statusText;
    if (section == 0){
        if (couponDic.isshareble) {
            
            statusText = @"转赠";
            @weakify(self);
            [[[statusB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                [self shareAction:couponDic.couponId];
            }];
        }
        else
        {
            statusText = @"有效";
        }
        
        if (couponDic.conponType == CouponTypeCarWash) {
            bgColorName = @"#5fb8e2";
        }
        else if (couponDic.conponType == CouponTypeCash || couponDic.conponType == CouponTypeInsurance) {
            bgColorName = @"#f54a4a";
        }
        else if (couponDic.conponType == CouponTypeAgency)
        {
            bgColorName = @"#f7b45d";
        }
        else if (couponDic.conponType == CouponTypeRescue)
        {
            bgColorName = @"#4bc4b3";
        }
        else if (couponDic.conponType == CouponTypeCZBankCarWash)
        {
            bgColorName = @"#c01920";
        }
        if ([statusText equalByCaseInsensitive:@"有效"]) {
            [[[statusB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                [MobClick event:@"rp304-4"];
            }];
        }
        [statusB setTitle:statusText forState:UIControlStateNormal];
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
        backgroundImg.image = [[UIImage imageNamed:@"coupon_background"] imageByFilledWithColor:HEXCOLOR(bgColorName)];
    }
    else {
        [statusB setTitle:@"已过期" forState:UIControlStateNormal];
        bgColorName = @"#d0d0d0";
        backgroundImg.image = [[UIImage imageNamed:@"coupon_background"] imageByFilledWithColor:HEXCOLOR(bgColorName)];
        name.text = couponDic.couponName;
        description.text = [NSString stringWithFormat:@"使用说明：%@",couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:YES promptView:self.tableView.bottomLoadingView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp304-5"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
