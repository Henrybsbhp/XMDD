//
//  GasPaymentResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPaymentResultVC.h"
#import "NSString+RectSize.h"
#import "NSString+Split.h"
#import "NSString+Format.h"
#import "SocialShareViewController.h"
#import "GetShareButtonOpV2.h"
#import "ShareResponeManager.h"

#import "ADViewController.h"

@interface GasPaymentResultVC()

@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,strong) ADViewController * adctrl;

@end

@implementation GasPaymentResultVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"GasPaymentResultVC dealloc ~");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.detailText) {
        self.detailText = @"您充值的金额将在1个工作日内到账，到账后可以前往加油站圈存使用。勾选“我要开发票”的用户可在圈存时向加油站工作人员索取发票。";
    }
    
    [self setupTableView];
    [self setupADView];
}

#pragma mark - Setup
- (void)setupTableView {
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CGFLOAT_MIN)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setupADView {
    if (!self.adctrl) {
        self.adctrl = [ADViewController vcWithADType:AdvertisementGasSuccess boundsWidth:self.view.bounds.size.width
                                            targetVC:self mobBaseEvent:@"jiayouzhifujieguo" mobBaseKey:@"guanggao"];
    }
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        UIView *header = self.headerView;
        if (ads.count == 0 || [self.headerView.subviews containsObject:ctrl.adView]) {
            return;
        }
        CGFloat height = 75;
        header.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        [header addSubview:ctrl.adView];
        [ctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (header)
            {
                make.left.equalTo(header);
                make.right.equalTo(header);
                make.top.equalTo(header);
                make.height.mas_equalTo(height);
            }
        }];
        self.tableView.tableHeaderView = header;
    }];
}
#pragma mark - ReloadData
- (void)reloadData {
    
}


#pragma mark - Action
- (IBAction)actionShare:(id)sender
{
    [MobClick event:@"jiayouzhifujieguo" attributes:@{@"fenxiang":@"fenxiang"}];
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneGas;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneGas;    //页面位置
        NSString * paidStr = [NSString stringWithFormat:@"%ld", (long)self.chargeMoney];
        NSString * chargeStr = [NSString stringWithFormat:@"%@", [NSString formatForPrice:self.couponMoney]];
        NSMutableDictionary * otherDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:paidStr, @"gasCharge", chargeStr, @"spareCharge", nil];
        vc.otherInfo = otherDic;
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        vc.mobBaseValue = @"jiayouzhifujieguo";
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        [MobClick event:@"fenxiangyemian" attributes:@{@"chuxian":@"jiayouzhifujieguo"}];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"fenxiangyemian" attributes:@{@"chuxian":@"jiayouzhifujieguo"}];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"jiayouzhifujieguo" attributes:@{@"navi":@"back"}];
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if (self.dismissBlock) {
        self.dismissBlock(self.drawingStatus);
    }
}

#pragma mark - UITableViewDelegate And Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 54 + (self.isNeedUppayIcon ? 28 : 0) + (self.uppayCouponInfo.length > 0 ? 57 :0);
    }
    if (indexPath.row == 2) {
        CGSize lbsize = [self.detailText labelSizeWithWidth:tableView.frame.size.width - 32 font:[UIFont systemFontOfSize:13]];
        return MAX(90, lbsize.height + 24);
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.drawingStatus == DrawingBoardViewStatusSuccess) {
        return 4;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self setupHeaderCell:cell];
    }
    else if (indexPath.row == 1) {
        [self setupPaymentInfoCell:cell];
    }
    else if (indexPath.row == 2) {
        [self setupDetailTextCell:cell];
    }
}

- (void)setupHeaderCell:(UITableViewCell *)cell
{
    UIImageView *iconV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UIImageView *uppayIcon = [cell viewWithTag:1003];
    UIView * uppayCouponView = [cell viewWithTag:1004];
    UILabel *uppayInfoLb = [cell viewWithTag:1005];
    if (self.drawingStatus == DrawingBoardViewStatusSuccess) {
        iconV.image = [UIImage imageNamed:@"round_tick"];
        titleL.text = @"恭喜，支付成功";
        titleL.textColor = kDefTintColor;
    }
    else {
        iconV.image = [UIImage imageNamed:@"gas_icon_fail"];
        titleL.text = @"支付失败";
        titleL.textColor = HEXCOLOR(@"#de1322");
    }
    uppayIcon.hidden = !self.isNeedUppayIcon;
    uppayCouponView.hidden = !self.uppayCouponInfo.length;
    uppayInfoLb.text = self.uppayCouponInfo;
}

- (void)setupPaymentInfoCell:(UITableViewCell *)cell
{
    UIImageView *iconV = (UIImageView *)[cell viewWithTag:1001];
    UILabel *cardnoL = [cell viewWithTag:1002];
    UILabel *chargeMoneyL = [cell viewWithTag:1004];
    UILabel *paidMoneyL = [cell viewWithTag:1005];

    NSString *iconname = self.gasCard.cardtype == 1 ? @"gas_icon_snpn" : @"gas_icon_cnpc";
    iconV.image = [UIImage imageNamed:iconname];

    cardnoL.text = [self.gasCard.gascardno splitByStep:4 replacement:@" "];
    chargeMoneyL.text = [NSString stringWithFormat:@"￥%@", [NSString formatForRoundPrice:self.chargeMoney]];
    paidMoneyL.text = [NSString stringWithFormat:@"￥%@", [NSString formatForRoundPrice:self.paidMoney]];
}

- (void)setupDetailTextCell:(UITableViewCell *)cell
{
    UILabel *textL = (UILabel *)[cell.contentView viewWithTag:1001];
    textL.textColor = self.drawingStatus == DrawingBoardViewStatusSuccess ? kDefTintColor : kGrayTextColor;
    textL.text = self.detailText;
    textL.numberOfLines = 0;
}

@end
