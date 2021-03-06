//
//  CarWashCouponVModel.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashCouponVModel.h"
#import "Xmdd.h"
#import "CouponDetailsVC.h"
#import "UIImageView+WebImage.h"
#import "MyCouponVC.h"
#import "UIView+RoundedCorner.h"

@interface CarWashCouponVModel ()<HKLoadingModelDelegate>
@property (nonatomic, assign) NSInteger curPageno;
@property (nonatomic, assign) CouponNewType couponNewType;
@property (nonatomic, assign) BOOL spreadFlag;

@end

@implementation CarWashCouponVModel

- (id)initWithTableView:(JTTableView *)tableView withType:(CouponNewType)couponNewType
{
    self = [super init];
    if (self) {
        self.spreadFlag = NO;
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

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    
    if (self.couponNewType == CouponNewTypeCarWash) {
        return @{@"title":@"您还没有洗车优惠券",@"image":@"def_withoutCoupon"};
    }
    else if (self.couponNewType == CouponNewTypeGas) {
        return @{@"title":@"您还没有加油优惠券",@"image":@"def_withoutCoupon"};
    }
    else if (self.couponNewType == CouponNewTypeInsurance) {
        return @{@"title":@"您还没有保险优惠券",@"image":@"def_withoutCoupon"};
    }
    return @{@"title":@"您还没有其他优惠券",@"image":@"def_withoutCoupon"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取优惠券失败，点击重试",@"image":@"def_failConnect"};
}

- (NSArray *)loadingModel:(HKLoadingModel *)model datasourceFromLoadedData:(NSArray *)data withType:(HKLoadingTypeMask)type
{
    NSMutableArray *datasource;
    if (type == HKLoadingTypeLoadMore) {
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
        if (!cpn.used && cpn.valid) {
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

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        self.curPageno = 0;
    }
    GetCouponByTypeNewV2Op *op = [GetCouponByTypeNewV2Op operation];
    op.coupontype = self.couponNewType;
    op.pageno = self.curPageno + 1;
    return [[op rac_postRequest] map:^id(GetCouponByTypeNewV2Op *rspOp) {
        
        self.curPageno = self.curPageno + 1;
        return rspOp.rsp_couponsArray;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.spreadFlag) {
        return 1;
    }
    else {
        return self.loadingModel.datasource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.loadingModel.datasource.count == 2 && section == 0) {
        return 40;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 && self.loadingModel.datasource.count == 2) {
        UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
        footView.backgroundColor = [UIColor clearColor];
        
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
        [btn setTitle:@"下列优惠券已失效" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        if (self.spreadFlag) {
            [btn setImage:[UIImage imageNamed:@"coupon_pullup"] forState:UIControlStateNormal];
        }
        else {
            [btn setImage:[UIImage imageNamed:@"coupon_pulldown"] forState:UIControlStateNormal];
        }
        
        UIEdgeInsets imgInsets = UIEdgeInsetsZero;
        UIEdgeInsets titleInsets = UIEdgeInsetsZero;
        imgInsets.left = 250;
        titleInsets.left = - 15;
        [btn setImageEdgeInsets:imgInsets];
        [btn setTitleEdgeInsets:titleInsets];
        
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[footView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            [MobClick event:@"wodeyouhuiquan" attributes:@{@"wodeyouhuiquan" : @"zhankai"}];
            self.spreadFlag = !self.spreadFlag;
            if (self.spreadFlag) {
                [btn setImage:[UIImage imageNamed:@"coupon_pullup"] forState:UIControlStateNormal];
            }
            else {
                [btn setImage:[UIImage imageNamed:@"coupon_pulldown"] forState:UIControlStateNormal];
            }
            [self.tableView reloadData];
        }];
        
        [footView addSubview:btn];
        return footView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.loadingModel.datasource safetyObjectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell.contentView viewWithTag:1001];
    
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:1002];
    //backgroundViwe
    UIView *backgroundView = [cell viewWithTag:100];
    backgroundView.layer.cornerRadius = 5;
    backgroundView.layer.masksToBounds = YES;
    
    UIView *topView = [cell viewWithTag:1010];
    
    
    
    UIImageView *imgView = [cell viewWithTag:10101];
    UIImage *img = [[UIImage imageNamed:@"coupon_sawtooth"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, -1, -0.5, 0) resizingMode:UIImageResizingModeTile];
    imgView.image = img;
    
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    //logo
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1005];
    //失效标签
    UIImageView *markV = (UIImageView *)[cell.contentView viewWithTag:1006];
    
    HKCoupon *couponDic = [[self.loadingModel.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if (indexPath.section == 0) {
        topView.backgroundColor = [UIColor colorWithHex:@"#18d06a" alpha:1];
        markV.hidden = YES;
        [logoV setImageByUrl:couponDic.logo
                          withType:ImageURLTypeThumbnail defImage:@"coupon_logo" errorImage:@"coupon_logo"];
    }
    else {
        topView.backgroundColor = [UIColor colorWithHex:@"#dedfe0" alpha:1];
        markV.hidden = NO;
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
    logoV.layer.cornerRadius = 22.0f;
    [logoV.layer setMasksToBounds:YES];
    name.text = couponDic.couponName;
    description.text = [NSString stringWithFormat:@"%@", couponDic.subname];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:YES promptView:self.tableView.bottomLoadingView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [MobClick event:@"wodeyouhuiquan" attributes:@{@"wodeyouhuiquan" : @"dianjiyouhuiquan"}];
        CouponDetailsVC *vc = [UIStoryboard vcWithId:@"CouponDetailsVC" inStoryboard:@"Mine"];
        HKCoupon *hkcoupon = [[self.loadingModel.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
        vc.couponId = hkcoupon.couponId;
        vc.isShareble = hkcoupon.isshareble;
        vc.oldType = hkcoupon.conponType;
        vc.newType = self.couponNewType;
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

//图片灰度处理
-(UIImage*)getGrayImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}



@end
