//
//  RescueCouponViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "RescueCouponViewController.h"
#import "JTTableView.h"
#import "HKCoupon.h"
#import "GetUserCouponByTypeOp.h"
#import "HKLoadingModel.h"
#import "CouponDetailsVC.h"
#import "DetailWebVC.h"

@interface RescueCouponViewController ()<HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic,strong) HKLoadingModel *loadingModel;

@end

@implementation RescueCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    [self.loadingModel loadDataForTheFirstTime];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.frame = CGRectMake(0, 0, 60, 44);
    [btn setTitle:@"省钱攻略" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rescueHistory) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}



//省钱攻略
- (void)rescueHistory {
    /**
     *  省钱攻略点击事件
     */
    [MobClick event:@"rp708-1"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"省钱攻略";
    vc.url = kMoneySavingStrategiesUrl;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescueCouponViewController dealloc!");
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无救援券";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    GetUserCouponByTypeOp * op = [GetUserCouponByTypeOp operation];
    op.type = CouponTypeRescue;
    if (CouponTypeRescue == 5) {
        op.rescueId = self.type;
    }
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
        vc.rgbStr = hkcoupon.rgbColor;
        vc.isShareble = hkcoupon.isshareble;
        vc.oldType = hkcoupon.conponType;
        vc.newType = CouponNewTypeOthers;
        vc.numberType = self.type;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
