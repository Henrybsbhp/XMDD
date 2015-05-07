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

@interface ChooseCarwashTicketVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *couponArray;

@end

@implementation ChooseCarwashTicketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadDatasource];
    [self setupNavigationBar];
    
    
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

- (void)actionBack
{
    NSArray * viewcontroller = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
    if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
    {
        PayForWashCarVC  * payVc = (PayForWashCarVC *)vc;
        [payVc setCouponId:self.couponId];
        if (self.couponId.length)
        {
            [payVc setPaymentType:PaymentChannelCoupon];
        }
        else
        {
            [payVc setPaymentType:PaymentChannelAlipay];
        }
        [payVc tableViewReloadData];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadDatasource
{
    HKCoupon * coupon = [[HKCoupon alloc] init];
    coupon.couponId = @"c1235756475";
    coupon.couponName = @"达达洗车店洗车卷";
    coupon.couponAmount = 1;
    coupon.couponDescription = @"免费洗车一次";
    coupon.used = NO;
    coupon.valid = YES;
    coupon.validsince = [NSDate date];
    coupon.validthrough = [NSDate date];
    coupon.conponType = CouponTypeCarWash;
    
    HKCoupon * coupon2 = [[HKCoupon alloc] init];
    coupon2.couponId = @"c1235756478";
    coupon2.couponName = @"哈哈洗车店洗车卷";
    coupon2.couponAmount = 1;
    coupon2.couponDescription = @"免费洗车一次";
    coupon2.used = NO;
    coupon2.valid = YES;
    coupon2.validsince = [NSDate date];
    coupon2.validthrough = [NSDate date];
    coupon2.conponType = CouponTypeCarWash;
    self.couponArray = @[coupon, coupon2];
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"使用优惠券支付";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.couponArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    
//    UIImageView * ticketBgView = (UIImageView *)[cell searchViewWithTag:101];
    UILabel * nameLb = (UILabel *)[cell searchViewWithTag:103];
    UILabel * statusLb = (UILabel *)[cell searchViewWithTag:104];
    UILabel * vaildTimeLb = (UILabel *)[cell searchViewWithTag:105];
    UILabel * noteLb = (UILabel *)[cell searchViewWithTag:106];
    UIImageView * shadowView = (UIImageView *)[cell searchViewWithTag:107];
    UIImageView * selectedView = (UIImageView *)[cell searchViewWithTag:108];
    
//    UIImage * image = [shadowView.image imageByFilledWithColor:[UIColor colorWithHex:@"#000000" alpha:0.6f]];
//    shadowView.image = image;
    
//    UIImage * couponGg = [[UIImage imageNamed:@"cw_ticket_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage * image = [[UIImage imageNamed:@"cw_ticket_bg"] imageByFilledWithColor:[UIColor colorWithHex:@"#000000" alpha:0.6f]];
    UIImage * couponGg = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    shadowView.image = couponGg;
    
    HKCoupon * coupon = [self.couponArray safetyObjectAtIndex:indexPath.row];
    nameLb.text = coupon.couponName;
    statusLb.text = @"有效";
    vaildTimeLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",[coupon.validsince dateFormatForYYMMdd2],[coupon.validthrough dateFormatForYYMMdd2]];
    noteLb.text = [NSString stringWithFormat:@"使用说明：%@", coupon.couponDescription];
    
    if ([self.couponId isEqualToString:coupon.couponId])
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
    self.couponId = [self.couponId isEqualToString:coupon.couponId] ? nil : coupon.couponId;
    [self.tableView reloadData];
}


@end
