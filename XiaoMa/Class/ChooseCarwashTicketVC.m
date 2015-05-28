//
//  ChooseWashCarTicketVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ChooseCarwashTicketVC.h"
#import "XiaoMa.h"
#import "PaymentSuccessVC.h"
#import "HKCoupon.h"
#import "PayForWashCarVC.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "WebVC.h"

@interface ChooseCarwashTicketVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseCarwashTicketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    [self.tableView reloadData];
    
    [self setupGetMoreBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupGetMoreBtn
{
    UIView *bottomView = [UIView new];
    UIButton *getMoreBtn = [UIButton new];
    [getMoreBtn setBackgroundColor:[UIColor colorWithHex:@"#ffb20c" alpha:1.0f]];
    [getMoreBtn setTitle:@"如何获取更多优惠劵" forState:UIControlStateNormal];
    [getMoreBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    getMoreBtn.cornerRadius = 5.0f;
    [getMoreBtn.layer setMasksToBounds:YES];
    [[getMoreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
        vc.title = @"获取更多";
        vc.url = @"";
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [bottomView addSubview:getMoreBtn];
    [self.tableView addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.tableView.mas_centerX);
        make.bottom.equalTo(self.tableView.tableFooterView.mas_bottom).offset(-10).priorityMedium();
        make.bottom.greaterThanOrEqualTo(self.view).offset(-10).priorityHigh();
    }];
    
    [getMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
}

- (void)actionBack
{
    NSArray * viewcontroller = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
    if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
    {
        PayForWashCarVC  * payVc = (PayForWashCarVC *)vc;
        
        if (self.selectedCouponArray.count)
        {
            [payVc setPaymentType:PaymentChannelCoupon];
            if (self.type == CouponTypeCarWash)
            {
                [payVc setSelectCarwashCoupouArray:self.selectedCouponArray];
                [payVc setCouponType:CouponTypeCarWash];
            }
            else if (self.type == CouponTypeCash)
            {
                [payVc setSelectCashCoupouArray:self.selectedCouponArray];
                [payVc setCouponType:CouponTypeCash];
            }
        }
        else
        {
            if (payVc.couponType  == self.type)
            {
                [payVc setCouponType:0];
            }
        }
        [payVc tableViewReloadData];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    return @"使用优惠券支付";
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.couponArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    
    //背景图片
    UIImage * carWashImage = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#00BFFF" alpha:1.0f]];
    UIImage * cashImage = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#0ACDC0" alpha:1.0f]];
    
    UIImageView * ticketBgView = (UIImageView *)[cell searchViewWithTag:101];
    //优惠名称
    UILabel *name = (UILabel *)[cell.contentView viewWithTag:103];
    //优惠描述
    UILabel *description = (UILabel *)[cell.contentView viewWithTag:106];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell.contentView viewWithTag:105];
    //状态
    UILabel *status = (UILabel *)[cell.contentView viewWithTag:104];
    
    UIImageView * shadowView = (UIImageView *)[cell searchViewWithTag:107];
    UIImageView * selectedView = (UIImageView *)[cell searchViewWithTag:108];
    
    UIImage * image = [[UIImage imageNamed:@"me_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#000000" alpha:0.6f]];
    UIImage * couponGg = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    shadowView.image = image;
    
    status.text = @"有效";
    
    HKCoupon * coupon = [self.couponArray safetyObjectAtIndex:indexPath.row];
    if (coupon.conponType == CouponTypeCarWash)
    {
        ticketBgView.image = carWashImage;
    }
    else
    {
        ticketBgView.image = cashImage;
    }
    name.text = coupon.couponName;
    description.text = [NSString stringWithFormat:@"使用说明：%@",coupon.couponDescription];
    // @LYW 时间显示有误
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[coupon.validsince dateFormatForYYMMdd2],[coupon.validthrough dateFormatForYYMMdd2]];
    
    BOOL flag  = NO;
    for (HKCoupon * c in self.selectedCouponArray)
    {
        if ([c.couponId isEqualToNumber:coupon.couponId])
        {
            flag = YES;
            break;
        }
    }
    
    if (flag)
    {
        shadowView.hidden = NO;
        selectedView.hidden = NO;
    }
    else
    {
        shadowView.hidden = YES;
        selectedView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCoupon * coupon = [self.couponArray safetyObjectAtIndex:indexPath.row];
    if (self.type == CouponTypeCarWash)
    {
        HKCoupon * c = [self.selectedCouponArray safetyObjectAtIndex:0];
        if ([c.couponId isEqualToNumber:coupon.couponId])
        {
            [self.selectedCouponArray removeAllObjects];
        }
        else
        {
            [self.selectedCouponArray removeAllObjects];
            [self.selectedCouponArray addObject:coupon];
        }
         [self.tableView reloadData];
    }
    else
    {
        CGFloat amount = 0;
        for (HKCoupon * c in self.selectedCouponArray)
        {
            if ([c.couponId isEqualToNumber:coupon.couponId])
            {
                [self.selectedCouponArray safetyRemoveObject:c];
                [self.tableView reloadData];
                return;
            }
            amount = amount + c.couponAmount;
        }
        if (amount + coupon.couponAmount <= self.upperLimit)
        {
        [self.selectedCouponArray addObject:coupon];
        [self.tableView reloadData];
        }
    }
    
}




@end
