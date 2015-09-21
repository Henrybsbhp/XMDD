//
//  CarWashCouponVModel.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashCouponVModel.h"
#import "XiaoMa.h"
#import "CouponDetailsVC.h"
#import "UIImageView+WebImage.h"

@interface CarWashCouponVModel ()<HKLoadingModelDelegate>
@property (nonatomic, assign) NSInteger curPageno;
@property (nonatomic, assign) CouponNewType couponNewType;
@property (nonatomic, strong) NSMutableArray * validCouponArr;
@property (nonatomic, strong) NSMutableArray * unvalidCouponArr;

@end

@implementation CarWashCouponVModel

- (id)initWithTableView:(JTTableView *)tableView withType:(CouponNewType)couponNewType
{
    self = [super init];
    if (self) {
        self.validCouponArr = [[NSMutableArray alloc] init];
        self.unvalidCouponArr = [[NSMutableArray alloc] init];
        self.tableView = tableView;
        self.couponNewType = couponNewType;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showBottomLoadingView = YES;
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    }
    return self;
}

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    if (self.couponNewType == CouponNewTypeCarWash) {
        return @"您还没有洗车优惠券";
    }
    else if (self.couponNewType == CouponNewTypeInsurance) {
        return @"您还没有保险优惠券";
    }
    return @"您还没有其他优惠券";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取优惠券失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    if (type != HKDatasourceLoadingTypeLoadMore) {
        self.curPageno = 0;
        self.validCouponArr = [[NSMutableArray alloc] init];
        self.unvalidCouponArr = [[NSMutableArray alloc] init];
    }
    GetCouponByTypeNewOp *op = [GetCouponByTypeNewOp operation];
    op.coupontype = self.couponNewType;
    op.pageno = self.curPageno+1;
    return [[op rac_postRequest] map:^id(GetCouponByTypeNewOp *rspOp) {
        
        self.curPageno = self.curPageno+1;
        return rspOp.rsp_couponsArray;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self sortCouponData];
}

- (void) sortCouponData
{
    for (HKCoupon * hkcoupon in self.loadingModel.datasource) {
        if (!hkcoupon.used && hkcoupon.valid) {
            [self.validCouponArr addObject:hkcoupon];
        }
        else {
            [self.unvalidCouponArr addObject:hkcoupon];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.unvalidCouponArr.count == 0) {
        return 1;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"下列优惠券已失效";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.validCouponArr.count;
    }
    else {
        return self.unvalidCouponArr.count;
    }
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
    //logo
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1005];
    //失效标签
    UIImageView *markV = (UIImageView *)[cell.contentView viewWithTag:1006];
    
    HKCoupon * couponDic;
    if (indexPath.section == 0) {
        couponDic = [self.validCouponArr safetyObjectAtIndex:indexPath.row];
        UIImage *bgImg = [UIImage imageNamed:@"coupon_background"];
        if (couponDic.rgbColor.length > 0) {
            NSString *strColor = [NSString stringWithFormat:@"#%@", couponDic.rgbColor];
            UIColor *color = HEXCOLOR(strColor);
            bgImg = [bgImg imageByFilledWithColor:color];
        }
        backgroundImg.image = bgImg;
        [logoV setImageByUrl:couponDic.logo
                          withType:ImageURLTypeThumbnail defImage:@"coupon_logo" errorImage:@"coupon_logo"];
        markV.hidden = YES;
    }
    else {
        couponDic = [self.unvalidCouponArr safetyObjectAtIndex:indexPath.row];
        backgroundImg.image = [[UIImage imageNamed:@"coupon_background"] imageByFilledWithColor:[UIColor colorWithHex:@"#d0d0d0" alpha:1.0f]];
        [logoV setImageByUrl:couponDic.logo
                    withType:ImageURLTypeThumbnail defImage:@"coupon_graylogo" errorImage:@"coupon_graylogo"];
        if (couponDic.used) {
            markV.image = [UIImage imageNamed:@"coupon_used"];
        }
        else {
            markV.image = [UIImage imageNamed:@"coupon_outtime"];
        }
    }
    logoV.layer.cornerRadius = 22.0F;
    [logoV.layer setMasksToBounds:YES];
    name.text = couponDic.couponName;
    description.text = [NSString stringWithFormat:@"（%@）", couponDic.subname];
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
    if (indexPath.section == 0) {
        CouponDetailsVC *vc = [UIStoryboard vcWithId:@"CouponDetailsVC" inStoryboard:@"Mine"];
        HKCoupon * hkcoupon = [self.validCouponArr safetyObjectAtIndex:indexPath.row];
        vc.couponId = hkcoupon.couponId;
        vc.rgbStr = hkcoupon.rgbColor;
        vc.isShareble = hkcoupon.isshareble;
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

@end
