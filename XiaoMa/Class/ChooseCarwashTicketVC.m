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
#import "PayForInsuranceVC.h"
#import "PayForGasViewController.h"

@interface ChooseCarwashTicketVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)getMoreAction:(id)sender;

@end

@implementation ChooseCarwashTicketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick beginLogPageView:@"rp109"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"rp109"];
}

- (void)dealloc
{
    DebugLog(@"ChooseCarwashTicketVC dealloc");
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)reloadData
{
    [self.tableView reloadData];
    if (self.couponArray.count == 0) {
        [self.tableView showDefaultEmptyViewWithText:@"暂无优惠券"];
    }
    else {
        [self.tableView hideDefaultEmptyView];
    }
}

- (IBAction)getMoreAction:(id)sender {
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.url = kGetMoreCouponUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionBack
{
    NSArray * viewcontroller = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
    if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
    {
        PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
        
        if (self.selectedCouponArray.count)
        {
            HKCoupon * c = [self.selectedCouponArray safetyObjectAtIndex:0];
            self.type = c.conponType;
            if (self.type == CouponTypeCZBankCarWash)
            {
                [payVc autoSelectBankCard];
                [payVc setPaymentChannel:PaymentChannelCZBCreditCard];
                [payVc setSelectCarwashCoupouArray:self.selectedCouponArray];
            }
            else if (self.type == CouponTypeCarWash)
            {
                [payVc setSelectCarwashCoupouArray:self.selectedCouponArray];
            }
            else if (self.type == CouponTypeCash)
            {
                [payVc setSelectCashCoupouArray:self.selectedCouponArray];
            }
            [payVc setCouponType:self.type];
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
    
    if (vc && [vc isKindOfClass:[PayForInsuranceVC class]])
    {
        PayForInsuranceVC * payVc = (PayForInsuranceVC *)vc;
        if (self.selectedCouponArray.count)
        {
            HKCoupon * c = [self.selectedCouponArray safetyObjectAtIndex:0];
            self.type = c.conponType;
            if (self.type == CouponTypeInsurance)
            {
                [payVc setSelectInsuranceCoupouArray:self.selectedCouponArray];
            }
            [payVc setCouponType:self.type];
            payVc.isSelectActivity = NO;
        }
        else
        {
            if (payVc.couponType == self.type)
            {
                [payVc setCouponType:0];
            }
        }
        [payVc tableViewReloadData];
    }
    if (vc && [vc isKindOfClass:[PayForGasViewController class]])
    {
        PayForGasViewController * pay4GasVC = (PayForGasViewController *)vc;
        if (self.selectedCouponArray.count)
        {
            pay4GasVC.couponType = CouponTypeGas;
            pay4GasVC.selectGasCoupouArray = self.selectedCouponArray;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.couponArray.count;
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
    //选中的遮罩
    UIImageView * shadowView = (UIImageView *)[cell searchViewWithTag:1006];
    //选中的勾
    UIImageView * selectedView = (UIImageView *)[cell searchViewWithTag:1007];
    
    HKCoupon * couponDic = [self.couponArray safetyObjectAtIndex:indexPath.row];
    
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
    
    UIImage * shadowImg = [[UIImage imageNamed:@"coupon_background"] imageByFilledWithColor:[UIColor colorWithHex:@"#000000" alpha:0.4f]];
    shadowView.image = shadowImg;
    
    BOOL flag  = NO;
    for (HKCoupon * c in self.selectedCouponArray)
    {
        if ([c.couponId isEqualToNumber:couponDic.couponId])
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
        self.type = coupon.conponType;
        
        [self.selectedCouponArray removeAllObjects];
        [self.selectedCouponArray addObject:coupon];
        
        [self actionBack];
    }
    else if (self.type == CouponTypeCZBankCarWash)
    {
        self.type = coupon.conponType;
        
        [self.selectedCouponArray removeAllObjects];
        [self.selectedCouponArray addObject:coupon];
        
        [self actionBack];
    }
    
    else if (self.type == CouponTypeCash)
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
        if (amount + coupon.couponAmount < self.upperLimit)
        {
            [MobClick event:@"rp109-1"];
            [self.selectedCouponArray addObject:coupon];
            [self.tableView reloadData];
        }
        else
        {
            [gToast showError:@"代金券金额大于支付金额，无法使用"];
        }
    }
    else if (self.type == CouponTypeInsurance)
    {
        if (coupon.couponAmount < self.upperLimit)
        {
            self.type = coupon.conponType;
            
            [MobClick event:@"rp109-1"];
            [self.selectedCouponArray removeAllObjects];
            [self.selectedCouponArray addObject:coupon];
            
            [self actionBack];
        }
        else
        {
            [gToast showError:@"代金券金额大于支付金额，无法使用"];
        }
    }
    else if (self.type == CouponTypeGas)
    {
        if (coupon.lowerLimit <= self.payAmount)
        {
            self.type = coupon.conponType;
        
            [self.selectedCouponArray removeAllObjects];
            [self.selectedCouponArray addObject:coupon];
        
            [self actionBack];
        }
        else
        {
            NSString * str = [NSString stringWithFormat:@"该加油券需充值满%.0f元方可使用",coupon.lowerLimit];
            [gToast showError:str];
        }
    }
//    else
//    {
//        CGFloat amount = 0;
//        for (HKCoupon * c in self.selectedCouponArray)
//        {
//            if ([c.couponId isEqualToNumber:coupon.couponId])
//            {
//                [self.selectedCouponArray safetyRemoveObject:c];
//                [self.tableView reloadData];
//                return;
//            }
//            amount = amount + c.couponAmount;
//        }
//        if (amount + coupon.couponAmount < self.upperLimit &&
//            self.selectedCouponArray.count < self.numberLimit)
//        {
//            [MobClick event:@"rp109-1"];
//            [self.selectedCouponArray addObject:coupon];
//            [self.tableView reloadData];
//        }
//    }
}

@end
