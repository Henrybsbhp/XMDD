//
//  CouponDetailsVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CouponDetailsVC.h"
#import "GetCouponDetailsOp.h"
#import "SocialShareViewController.h"
#import "ShareUserCouponOp.h"
#import "CarWashTableVC.h"
#import "InsuranceVC.h"
#import "UIView+DefaultEmptyView.h"
#import "RescueDetailsVC.h"
#import "GetShareButtonOpV2.h"
#import "ShareResponeManager.h"
#import "CommissionOrderVC.h"
#import "RescueHomeViewController.h"
#import "GasVC.h"
#import "MutualInsHomeVC.h"

@interface CouponDetailsVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic) HKCoupon * couponDic;
@property (weak, nonatomic) IBOutlet UIView *navigationView;

@end

@implementation CouponDetailsVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CouponDetailsVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44;
    }
    [self requestData];
}

- (void)goToUse:(CouponNewType)newType
{
    if (newType == CouponNewTypeCarWash) {
        CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
        vc.couponForWashDic = self.couponDic;
        vc.serviceType = self.oldType == CouponTypeWithHeartCarwash ? ShopServiceCarwashWithHeart : ShopServiceCarWash;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (newType == CouponNewTypeGas) {
        GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (newType == CouponNewTypeOthers) {
        //其他券使用老板优惠券类型判断跳转
        if (self.oldType == CouponTypeAgency) {
            CommissionOrderVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionOrderVC"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (self.oldType == CouponTypeRescue) {
            RescueHomeViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueHomeViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (self.oldType == CouponTypeXMHZ) {
            MutualInsHomeVC * vc = [UIStoryboard vcWithId:@"MutualInsHomeVC" inStoryboard:@"MutualInsJoin"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)requestData {
    GetCouponDetailsOp * op = [GetCouponDetailsOp operation];
    op.req_cid = self.couponId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        self.tableView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        self.navigationView.backgroundColor = [UIColor colorWithHex:@"#18d06a" alpha:1];
    }] subscribeNext:^(GetCouponDetailsOp * op) {
        @strongify(self);
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        self.couponDic = op.rsp_couponDetails;
        self.navigationView.backgroundColor = [UIColor colorWithHex:@"#18d06a" alpha:0];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        [gToast showError:error.domain];
        self.tableView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"优惠券详情获取失败,点击重试" tapBlock:^{
            [self requestData];
        }];
        self.navigationView.backgroundColor = [UIColor colorWithHex:@"#18d06a" alpha:1];
        [self.view bringSubviewToFront:self.navigationView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Share

-(void)share
{
    [self goToUse:self.newType];
}

- (void)requestShareCoupon:(NSNumber *)cid
{
    ShareUserCouponOp * op = [ShareUserCouponOp operation];
    op.cid = cid;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"分享信息获取中..."];
    }] subscribeNext:^(ShareUserCouponOp * sop) {
        
        [gToast dismiss];
        [self shareAction:sop andImage:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)shareAction:(NSNumber *)cid
{
    [MobClick event:@"rp304_3"];
    
    [self requestShareCoupon:cid];
}

- (void)shareAction:(ShareUserCouponOp *)op andImage:(UIImage *)image
{
    GetShareButtonOpV2 * getBtnOp = [GetShareButtonOpV2 operation];
    getBtnOp.pagePosition = ShareSceneCoupon;
    [[getBtnOp rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * getBtnOp) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneCoupon;
        vc.btnTypeArr = getBtnOp.rsp_shareBtns;
        vc.tt = op.rsp_title;
        vc.subtitle = op.rsp_content;
        vc.urlStr = op.rsp_linkUrl;
        
        [[gMediaMgr rac_getImageByUrl:op.rsp_wechatUrl withType:ImageURLTypeMedium defaultPic:@"wechat_share_coupon" errorPic:@"wechat_share_coupon"] subscribeNext:^(UIImage * x) {
            vc.image = x;
        }];
        [[gMediaMgr rac_getImageByUrl:op.rsp_weiboUrl withType:ImageURLTypeMedium defaultPic:@"weibo_share_carwash2" errorPic:@"weibo_share_carwash2"] subscribeNext:^(UIImage * x) {
            vc.webimage = x;
        }];
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110_7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
    
}

#pragma mark - TableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.newType == CouponNewTypeInsurance ? 2 : 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1)
    {
        return (self.couponDic.useguide.count + 1);
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [self headCellForRowAtIndexPath:indexPath];
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
        }
        else
        {
            cell = [self guideCellForRowAtIndexPath:indexPath];
        }
    }
    else
    {
        if (self.isShareble)
        {
            cell = [self buttonTwoCellForRowAtIndexPath:indexPath];
        }
        else
        {
            cell = [self buttonOneCellForRowAtIndexPath:indexPath];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)buttonOneCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"buttonOneCell"];
    UIButton *btn = [cell viewWithTag:100];
    [self setButton:btn];
    
    @weakify(self)
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
        @strongify(self)
        [self goToUse:self.newType];
    }];
    
    return cell;
}

- (UITableViewCell *)buttonTwoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"buttonTwoCell"];
    
    UIButton *shareBtn = [cell viewWithTag:100];
    UIButton *userBtn = [cell viewWithTag:200];
    [self setButton:shareBtn];
    [self setButton:userBtn];
    
    if (self.newType == CouponNewTypeInsurance)
    {
        shareBtn.hidden = YES;
    }
    else
    {
        shareBtn.hidden = NO;
    }
    
    @weakify(self)
    [[[shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
        @strongify(self);
        [self shareAction:self.couponId];
    }];
    
    [[[userBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
        @strongify(self)
        [gToast showingWithoutText];
        //去使用之前判断是否被领取
        GetCouponDetailsOp * op = [GetCouponDetailsOp operation];
        op.req_cid = self.couponId;
        [[op rac_postRequest] subscribeNext:^(id x) {
            
            [gToast dismiss];
            [self goToUse:self.newType];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }];
    return cell;
}

- (UITableViewCell *)headCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeadCell"];
    //背景图片
    UIImageView * logo = (UIImageView *)[cell viewWithTag:1006];
    logo.layer.cornerRadius = 22;
    logo.layer.masksToBounds = YES;
    logo.image = [UIImage imageNamed:@"coupon_logo"];
    UILabel * nameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel * subnameLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel * describeLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel * validDate = (UILabel *)[cell.contentView viewWithTag:1004];
    
    UIImageView *imgView = [cell viewWithTag:1005];
    UIImage *img = [[UIImage imageNamed:@"coupon_detailsawtooth"]resizableImageWithCapInsets:UIEdgeInsetsMake(1, -0.5, 1, -0.5) resizingMode:UIImageResizingModeTile];
    imgView.image = img;
    
    nameLabel.text = self.couponDic.couponName;
    subnameLabel.text = [NSString stringWithFormat:@"%@", self.couponDic.subname];
    if (self.couponDic.couponDescription.length > 0)
    {
        describeLabel.hidden = NO;
        describeLabel.text = [NSString stringWithFormat:@"使用说明：%@", self.couponDic.couponDescription];
    }
    else
    {
        describeLabel.hidden = YES;
    }
    if (self.couponDic.validsince && self.couponDic.validthrough)
    {
        validDate.hidden = NO;
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@", [self.couponDic.validsince dateFormatForYYMMdd2], [self.couponDic.validthrough dateFormatForYYMMdd2]];
    }
    else
    {
        validDate.hidden = YES;
    }
    return cell;
}

- (UITableViewCell *)guideCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GuideCell"];
    UILabel * nolabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel * contentlabel = (UILabel *)[cell.contentView viewWithTag:1002];
    
    nolabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    nolabel.layer.cornerRadius = 8.0f;
    
    nolabel.backgroundColor = [UIColor colorWithHex:@"#18d06a" alpha:1.0f];
    
    [nolabel.layer setMasksToBounds:YES];
    
    contentlabel.text = [self.couponDic.useguide safetyObjectAtIndex:indexPath.row - 1];
    if (!IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        contentlabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 44;
    }
    return cell;
}

#pragma mark TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 120;
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        return 50;
    }
    else if (indexPath.section == 2)
    {
        return 65;
    }
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        return UITableViewAutomaticDimension;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height+1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = CGFLOAT_MIN;
    if (section == 1)
    {
        height = 10;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 10)];
    view.backgroundColor = kBackgroundColor;
    return view;
}

#pragma mark Utility


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setButton:(UIButton *)button
{
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
