//
//  ChooseWashCarTicketVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ChooseCouponVC.h"
#import "Xmdd.h"
#import "HKCoupon.h"
#import "PayForWashCarVC.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "DetailWebVC.h"
#import "PayForInsuranceVC.h"
#import "PayForGasViewController.h"
#import "MutualInsPayViewController.h"

@interface ChooseCouponVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *askMoreAction;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)getMoreAction:(id)sender;

@end

@implementation ChooseCouponVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ChooseCarwashTicketVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SetupUI
- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Utilitly
- (void)reloadData
{
    [self.tableView reloadData];
    if (self.couponArray.count == 0)
    {
        self.tableView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_withoutCoupon" text:@"暂无优惠券"];
        [self.view bringSubviewToFront:self.askMoreAction];
    }
    else
    {
        self.tableView.hidden = NO;
        [self.view hideDefaultEmptyView];
    }
}

- (IBAction)getMoreAction:(id)sender {
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = ADDEFINEWEB;
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
                payVc.selectCarwashCoupouArray = self.selectedCouponArray;
                [payVc.selectCashCoupouArray removeAllObjects];
            }
            else if (self.type == CouponTypeCarWash)
            {
                payVc.selectCarwashCoupouArray = self.selectedCouponArray;
                [payVc.selectCashCoupouArray removeAllObjects];
            }
            else if (self.type == CouponTypeCash ||
                     self.type == CouponTypeBeauty ||
                     self.type == CouponTypeMaintenance)
            {
                payVc.selectCashCoupouArray = self.selectedCouponArray;
                [payVc.selectCarwashCoupouArray removeAllObjects];
            }
            [payVc setCouponType:self.type];
        }
        else
        {
            if (self.type == CouponTypeCarWash && payVc.couponType == CouponTypeCash)
            {
                
            }
            else if (self.type == CouponTypeCash && (payVc.couponType == CouponTypeCarWash || payVc.couponType == CouponTypeCZBankCarWash))
            {
                
            }
            else
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
            HKCoupon * coupon = [self.selectedCouponArray safetyObjectAtIndex:0];
            pay4GasVC.selectGasCoupouArray = self.selectedCouponArray;
            pay4GasVC.couponType = coupon.conponType;
        }
    }
    if (vc && [vc isKindOfClass:[MutualInsPayViewController class]])
    {
        MutualInsPayViewController * mutualInsPayVC = (MutualInsPayViewController *)vc;
        [mutualInsPayVC tableViewReloadData];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.couponArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell"];
    
    //backgroundViwe
    UIView *backgroundView = [cell viewWithTag:100];
    backgroundView.layer.cornerRadius = 5;
    backgroundView.layer.masksToBounds = YES;
    
    //背景图片
    UIImageView *backgroundImg = (UIImageView *)[cell searchViewWithTag:1001];
    
    UIImageView *imgView = [cell viewWithTag:10101];
    imgView.image = [[UIImage imageNamed:@"coupon_sawtooth"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, -1, -0.5, 0) resizingMode:UIImageResizingModeTile];
    
    //优惠名称
    UILabel *name = (UILabel *)[cell searchViewWithTag:1002];
    //优惠描述
    UILabel *description = (UILabel *)[cell searchViewWithTag:1003];
    //优惠有效期
    UILabel *validDate = (UILabel *)[cell searchViewWithTag:1004];
    //logo
    UIImageView *logoV = (UIImageView *)[cell searchViewWithTag:1005];
    //选中的遮罩
    UIView * shadowView = (UIView *)[cell searchViewWithTag:1006];
    shadowView.layer.cornerRadius = 5;
    shadowView.layer.masksToBounds = YES;
    //选中的勾
    UIImageView * selectedView = (UIImageView *)[cell searchViewWithTag:1007];
    
    UIImageView *sawtoothImg = [cell viewWithTag:10101];
    UIImage *img = [[UIImage imageNamed:@"coupon_sawtooth"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, -1, -0.5, 0) resizingMode:UIImageResizingModeTile];
    sawtoothImg.image = img;
    
    HKCoupon * couponDic = [self.couponArray safetyObjectAtIndex:indexPath.section];
    
    UIImage *bgImg = [UIImage imageNamed:@"coupon_background"];
    backgroundImg.image = bgImg;
    
    [logoV setImageByUrl:couponDic.logo
                withType:ImageURLTypeThumbnail defImage:@"coupon_logo" errorImage:@"coupon_logo"];
    
    logoV.layer.cornerRadius = 22.0F;
    [logoV.layer setMasksToBounds:YES];
    name.text = couponDic.couponName;
    
    description.text = [NSString stringWithFormat:@"%@", couponDic.subname];
    validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@",[couponDic.validsince dateFormatForYYMMdd2],[couponDic.validthrough dateFormatForYYMMdd2]];
    
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
    [MobClick event:@"rp109_1"];
    HKCoupon * coupon = [self.couponArray safetyObjectAtIndex:indexPath.section];
    if (self.type == CouponTypeCarWash)
    {
        // 洗车券只会出现1张
        for (HKCoupon * c in self.selectedCouponArray)
        {
            if ([c.couponId isEqualToNumber:coupon.couponId])
            {
                [self.selectedCouponArray safetyRemoveObject:c];
                [self.tableView reloadData];
                return;
            }
        }
        
        self.type = coupon.conponType;
        [self.selectedCouponArray removeAllObjects];
        [self.selectedCouponArray addObject:coupon];
        
        [self actionBack];
    }
    else if (self.type == CouponTypeCZBankCarWash)
    {
        // 浙商洗车券只会出现1张
        for (HKCoupon * c in self.selectedCouponArray)
        {
            if ([c.couponId isEqualToNumber:coupon.couponId])
            {
                [self.selectedCouponArray safetyRemoveObject:c];
                [self.tableView reloadData];
                return;
            }
        }
        self.type = coupon.conponType;
        
        [self.selectedCouponArray removeAllObjects];
        [self.selectedCouponArray addObject:coupon];
        
        [self actionBack];
    }
    
    else if (self.type == CouponTypeCash)
    {
        CGFloat totalCoupon = 0.0;
        for (HKCoupon * c in self.selectedCouponArray)
        {
            totalCoupon = totalCoupon + c.couponAmount;
            if ([c.couponId isEqualToNumber:coupon.couponId])
            {
                [self.selectedCouponArray safetyRemoveObject:c];
                [self.tableView reloadData];
                return;
            }
        }
        
        if (totalCoupon >= self.couponLimit && self.couponLimit > 0)
        {
            NSString * str = [NSString stringWithFormat:@"选中的代金券总额已达最高优惠上限：%@元",[NSString formatForPrice:self.couponLimit]];
            [gToast showError:str];
            return;
        }
        
        [self.selectedCouponArray addObject:coupon];
        [self.tableView reloadData];
    }
    else if (self.type == CouponTypeInsurance)
    {
        if (coupon.couponAmount < self.upperLimit)
        {
            HKCoupon * originCoupon = [self.selectedCouponArray safetyObjectAtIndex:0];
            if (originCoupon && [coupon.couponId isEqualToNumber:originCoupon.couponId])
            {
                [self.selectedCouponArray removeAllObjects];
            }
            else
            {
                self.type = coupon.conponType;
                
                [self.selectedCouponArray removeAllObjects];
                [self.selectedCouponArray addObject:coupon];
            }
            
            [self actionBack];
        }
        else
        {
            [gToast showError:@"代金券金额大于支付金额，无法使用"];
        }
    }
    else if (self.type == CouponTypeGasNormal ||
             self.type == CouponTypeGasReduceWithThreshold ||
             self.type == CouponTypeGasDiscount)
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
    else if (self.type == CouponTypeXMHZ)
    {
        CGFloat totalCoupon = 0.0;
        for (HKCoupon * c in self.selectedCouponArray)
        {
            totalCoupon = totalCoupon + c.couponAmount;
            if ([c.couponId isEqualToNumber:coupon.couponId])
            {
                [self.selectedCouponArray safetyRemoveObject:c];
                [self.tableView reloadData];
                return;
            }
        }

        if (totalCoupon >= self.couponLimit)
        {
            NSString * str = [NSString stringWithFormat:@"您选择的优惠券已满最大优惠额度：%@元",[NSString formatForPrice:self.couponLimit]];
            [gToast showError:str];
            return;
        }
        [self.selectedCouponArray addObject:coupon];
        [self.tableView reloadData];
    }
    else if (self.type == CouponTypeViolation)
    {   
        HKCoupon * originCoupon = [self.selectedCouponArray safetyObjectAtIndex:0];
        if (originCoupon && [coupon.couponId isEqualToNumber:originCoupon.couponId])
        {
            [self.selectedCouponArray removeAllObjects];
        }
        else
        {
            self.type = coupon.conponType;
            
            [self.selectedCouponArray removeAllObjects];
            [self.selectedCouponArray addObject:coupon];
        }
        
        [self actionBack];
        [self.tableView reloadData];
    }
    else if (self.type == CouponTypeBeauty ||
             self.type == CouponTypeMaintenance)
    {
        // 美容，保养只能选1张
        for (HKCoupon * c in self.selectedCouponArray)
        {
            if ([c.couponId isEqualToNumber:coupon.couponId])
            {
                [self.selectedCouponArray safetyRemoveObject:c];
                [self.tableView reloadData];
                return;
            }
        }
        
        self.type = coupon.conponType;
        [self.selectedCouponArray removeAllObjects];
        [self.selectedCouponArray addObject:coupon];
        
        [self actionBack];
    }
}


@end
