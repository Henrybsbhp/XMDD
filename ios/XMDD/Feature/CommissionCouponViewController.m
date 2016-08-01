//
//  CommissionCouponViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionCouponViewController.h"
#import "GetUserCouponByTypeOp.h"
#import "HKLoadingModel.h"
#import "CouponDetailsVC.h"

@interface CommissionCouponViewController ()<HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@end

@implementation CommissionCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    [self.loadingModel loadDataForTheFirstTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissionCouponViewController");
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无协办券",@"image":@"def_withoutCoupon"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    GetUserCouponByTypeOp * op = [GetUserCouponByTypeOp operation];
    op.type = CouponTypeAgency;
    return [[op rac_postRequest] map:^id(GetUserCouponByTypeOp *rspOp) {
        return rspOp.rsp_couponsArray;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell searchViewWithTag:1001];
    
    //优惠名称
    UILabel *name = (UILabel *)[cell searchViewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell searchViewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell searchViewWithTag:1004];
    //logo
    UIImageView *logoV = (UIImageView *)[cell searchViewWithTag:1005];
    
    HKCoupon * couponDic = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    
    UIImage *bgImg = [UIImage imageNamed:@"coupon_background"];
    if (couponDic.rgbColor.length > 0) {
        NSString *strColor = [NSString stringWithFormat:@"#%@", couponDic.rgbColor];
        UIColor *color = HEXCOLOR(strColor);
        bgImg = [bgImg imageByFilledWithColor:color];
    }
    backgroundImg.image = bgImg;
    
    [logoV setImageByUrl:couponDic.logo
                withType:ImageURLTypeThumbnail defImage:@"coupon_logo" errorImage:@"coupon_logo"];
    
    logoV.layer.cornerRadius = 22.0F;
    [logoV.layer setMasksToBounds:YES];
    name.text = couponDic.couponName;
    description.text = [NSString stringWithFormat:@"%@", couponDic.subname];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        CouponDetailsVC *vc = [UIStoryboard vcWithId:@"CouponDetailsVC" inStoryboard:@"Mine"];
        HKCoupon *hkcoupon = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
        vc.couponId = hkcoupon.couponId;
        vc.isShareble = hkcoupon.isshareble;
        vc.oldType = hkcoupon.conponType;
        vc.newType = CouponNewTypeOthers;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
