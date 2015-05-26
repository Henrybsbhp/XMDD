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
        [payVc setCouponId:self.couponId];
        if (self.couponId)
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
    
    if ([self.couponId isEqualToNumber:coupon.couponId])
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
    self.couponId = [self.couponId isEqualToNumber:coupon.couponId] ? nil : coupon.couponId;
    [self.tableView reloadData];
    
    if (self.couponId)
    {
        [self actionBack];
    }
}




@end
