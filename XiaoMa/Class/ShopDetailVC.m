//
//  ShopDetailVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ShopDetailVC.h"
#import "JTShop.h"
#import "XiaoMa.h"
#import <Masonry.h>
#import "JTRatingView.h"
#import "PayForWashCarVC.h"
#import "DistanceCalcHelper.h"
#import "NSDate+DateForText.h"
#import "GetShopRatesOp.h"
#import "CarWashNavigationViewController.h"
#import "NearbyShopsViewController.h"
#import "CommentListViewController.h"
#import "EditMyCarVC.h"
#import "AddUserFavoriteOp.h"
#import "SDPhotoBrowser.h"
#import "UIView+Layer.h"
#import "MyCarStore.h"
#import "CBAutoScrollLabel.h"
#import "NSString+RectSize.h"

#define kDefaultServieCount     2

@interface ShopDetailVC () <UIScrollViewDelegate, SDPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *roundLb;
@property (weak, nonatomic) IBOutlet UIView *roundBgView;
@property (weak, nonatomic) IBOutlet UIImageView *maskView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *greenBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *whiteBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *greenStarBtn;
@property (weak, nonatomic) IBOutlet UIButton *whiteStarBtn;
- (IBAction)collectionAction:(id)sender;
/// 服务列表展开
@property (nonatomic, assign) BOOL serviceExpanded;
/// 是否已收藏标签
@property (nonatomic)BOOL favorite;
/// 是否显示标题栏
@property (nonatomic)BOOL titleShow;

@end

@implementation ShopDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 44;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    if (IOSVersionGreaterThanOrEqualTo(@"7.0")) {
        [self.tableView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
    }
    
    [[self.whiteBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [[self.greenBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self headImageView];
    [self requestShopComments];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.roundLb refreshLabels];
    
    [MobClick beginLogPageView:@"rp105"];
    if([gAppMgr.myUser.favorites getFavoriteWithID:self.shop.shopID] == nil){
        self.favorite = NO;
        [self.greenStarBtn setImage:[UIImage imageNamed:@"shop_green_star"] forState:UIControlStateNormal];
        [self.whiteStarBtn setImage:[UIImage imageNamed:@"shop_white_star"] forState:UIControlStateNormal];
    }
    else {
        self.favorite = YES;
        [self.greenStarBtn setImage:[UIImage imageNamed:@"shop_green_fillstar"] forState:UIControlStateNormal];
        [self.whiteStarBtn setImage:[UIImage imageNamed:@"shop_white_fillstar"] forState:UIControlStateNormal];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp105"];
}
- (void)dealloc
{
    DebugLog(@"ShopDetailVC Dealloc");
}

#pragma mark - SetupUI
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return  self.titleShow ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.titleView.alpha = MAX(0, (scrollView.contentOffset.y - 80)) * 0.02;
    self.titleLabel.alpha = MAX(0, (scrollView.contentOffset.y - 80)) * 0.02;
    self.greenBackBtn.alpha = MAX(0, (scrollView.contentOffset.y - 80)) * 0.02;
    self.greenStarBtn.alpha = MAX(0, (scrollView.contentOffset.y - 80)) * 0.02;
    if (scrollView.contentOffset.y > 80) {
        self.titleShow = YES;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
    else {
        self.titleShow = NO;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)setupMyCarList
{
    [[[[MyCarStore fetchExistsStore] getAllCarsIfNeeded] signal] subscribeNext:^(id x) {}];
}

#pragma mark - Action
- (IBAction)collectionAction:(id)sender {
    [MobClick event:@"rp105-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        if (self.favorite)
        {
            @weakify(self);
            [[[gAppMgr.myUser.favorites rac_removeFavorite:@[self.shop.shopID]] initially:^{

                [gToast showingWithText:@"移除中…"];
            }] subscribeNext:^(id x) {

                @strongify(self);
                [gToast dismiss];
                self.favorite = NO;
                [self.whiteStarBtn setImage:[UIImage imageNamed:@"shop_white_star"] forState:UIControlStateNormal];
                [self.greenStarBtn setImage:[UIImage imageNamed:@"shop_green_star"] forState:UIControlStateNormal];
                
                NSArray * array = self.navigationController.viewControllers;
                UIViewController * vc = [array safetyObjectAtIndex:array.count - 2];
                if (vc && [vc isKindOfClass:[NearbyShopsViewController class]])
                {
                    NearbyShopsViewController * nearbyVC = (NearbyShopsViewController *)vc;
                    [nearbyVC reloadBottomView];
                }
            } error:^(NSError *error) {

                [gToast showError:error.domain];
            }];
        }
        else
        {
            @weakify(self);
            [[[gAppMgr.myUser.favorites rac_addFavorite:self.shop] initially:^{

                [gToast showingWithText:@"添加中…"];
            }] subscribeNext:^(id x) {

                @strongify(self);
                [gToast dismiss];
                self.favorite = YES;
                [self.whiteStarBtn setImage:[UIImage imageNamed:@"shop_white_fillstar"] forState:UIControlStateNormal];
                [self.greenStarBtn setImage:[UIImage imageNamed:@"shop_green_fillstar"] forState:UIControlStateNormal];
                NSArray * array = self.navigationController.viewControllers;
                UIViewController * vc = [array safetyObjectAtIndex:array.count - 2];
                if (vc && [vc isKindOfClass:[NearbyShopsViewController class]])
                {
                    NearbyShopsViewController * nearbyVC = (NearbyShopsViewController *)vc;
                    [nearbyVC reloadBottomView];
                }
            } error:^(NSError *error) {

                @strongify(self);
                if (error.code == 7002)
                {
                    self.favorite = YES;
                    [self.whiteStarBtn setImage:[UIImage imageNamed:@"shop_white_star"] forState:UIControlStateNormal];
                    [self.greenStarBtn setImage:[UIImage imageNamed:@"shop_green_star"] forState:UIControlStateNormal];
                    [gToast dismiss];
                }
                else {
                    [gToast showError:error.domain];
                }
            }];
        }
    }
}

- (void)requestShopComments
{
    GetShopRatesOp * op = [GetShopRatesOp operation];
    op.shopId = self.shop.shopID;
    op.pageno = 1;
    [[op rac_postRequest] subscribeNext:^(GetShopRatesOp * op) {
        
        self.shop.shopCommentArray = op.rsp_shopCommentArray;
        self.shop.commentNumber = op.rsp_totalNum;
        
        NSIndexSet *indexSet= [[NSIndexSet alloc] initWithIndex:1];
        
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)requestAddUserFavorite:(UIButton *)btn
{
    AddUserFavoriteOp * op = [AddUserFavoriteOp operation];
    op.shopid = self.shop.shopID;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"收藏中…"];
    }] subscribeNext:^(AddUserFavoriteOp * op) {
        
        [gToast dismiss];
        self.favorite = YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } error:^(NSError *error) {
        
        self.favorite = NO;
        [gToast showError:error.domain];
    }];
}

- (IBAction)actionMap:(id)sender
{
    [MobClick event:@"rp105-4"];
    CarWashNavigationViewController * vc = [[CarWashNavigationViewController alloc] init];
    vc.shop = self.shop;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionShowPhotos:(UITapGestureRecognizer *)tap
{
    [MobClick event:@"rp105-2"];
    if (self.shop.picArray.count > 0)
    {
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        UIView *sourceImgV1 = self.headImgView;
        UIView *sourceImgV2 = self.imageCountLabel;
        browser.sourceImageViews = @[sourceImgV1, sourceImgV2]; // 原图的容器
        browser.imageCount = self.shop.picArray.count; // 图片总数
        browser.currentImageIndex = 0;
        browser.delegate = self;
        [browser show];
    }
}

- (void)gotoPaymentVCWithService:(JTShopService *)service
{
    if (service.shopServiceType == ShopServiceCarWash) {
        [MobClick event:@"rp105-6_1"];
    }
    else {
        [MobClick event:@"rp105-6_2"];
    }
    [[[[[MyCarStore fetchExistsStore] getDefaultCar] signal] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal return:nil];
    }] subscribeNext:^(HKMyCar *car) {
        
        PayForWashCarVC *vc = [UIStoryboard vcWithId:@"PayForWashCarVC" inStoryboard:@"Carwash"];
        if (self.couponFordetailsDic.conponType == CouponTypeCarWash || self.couponFordetailsDic.conponType == CouponTypeCZBankCarWash) {
            
            vc.selectCarwashCoupouArray = vc.selectCarwashCoupouArray ? vc.selectCarwashCoupouArray : [NSMutableArray array];
            [vc.selectCarwashCoupouArray addObject:self.couponFordetailsDic];
            vc.couponType = CouponTypeCarWash;
            vc.isAutoCouponSelect = YES;
        }
        else if (self.couponFordetailsDic.conponType == CouponTypeCash) {
            
            vc.selectCashCoupouArray = vc.selectCashCoupouArray ? vc.selectCashCoupouArray : [NSMutableArray array];
            [vc.selectCashCoupouArray addObject:self.couponFordetailsDic];
            vc.couponType = CouponTypeCash;
            vc.isAutoCouponSelect = YES;
        }
        vc.originVC = self;
        vc.shop = self.shop;
        vc.service = service;
        vc.defaultCar = [car isCarInfoCompleted] ? car : nil;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - TableView data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 84;
        }
        else if (indexPath.row == 2) {
            height = 44;
        }
        else if (indexPath.row == 1 || indexPath.row < 3 + self.shop.shopServiceArray.count) {
            if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
            {
                return UITableViewAutomaticDimension;
            }
            
            UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
            [cell layoutIfNeeded];
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
            height = ceil(size.height+1);
        }
        else {
            height = 44;
        }
    }
    else {
        if (indexPath.row == 0) {
            height = 36;
        }
        else {
            if (self.shop.shopCommentArray.count)
            {
                if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
                {
                    return UITableViewAutomaticDimension;
                }
                
                UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                [cell layoutIfNeeded];
                [cell setNeedsUpdateConstraints];
                [cell updateConstraintsIfNeeded];
                CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
                height = ceil(size.height+1);
            }
            else
            {
                height = 45;
            }
        }
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    if (section == 0) {
        count = self.serviceExpanded ? 3 + self.shop.shopServiceArray.count : ((3+MIN(kDefaultServieCount, self.shop.shopServiceArray.count)) + (self.shop.shopServiceArray.count > kDefaultServieCount ? 1 : 0));
    }
    else if (section == 1){
        count = 1 + (self.shop.shopCommentArray.count ? MIN(self.shop.shopCommentArray.count,5) : 1);
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? CGFLOAT_MIN : 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self shopTitleCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == 1) {
            cell = [self shopAddrCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == 2) {
            cell = [self shopPhoneNumberCellAtIndexPath:indexPath];
        }
        else
        {
            if (self.serviceExpanded)
            {
                cell = [self shopServiceCellAtIndexPath:indexPath];
            }
            else
            {
                if (indexPath.row < 3 + kDefaultServieCount ) {
                    cell = [self shopServiceCellAtIndexPath:indexPath];
                }
                else {
                    cell = [self shopMoreServiceCellAtIndexPath:indexPath];
                }
            }
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [self shopCommentTitleCellAtIndexPath:indexPath];
        }
        else {
            if (self.shop.shopCommentArray.count)
            {
                cell = [self shopCommentCellAtIndexPath:indexPath];
            }
            else
            {
                cell = [self shopNoCommentCellAtIndexPath:indexPath];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [MobClick event:@"rp105-9"];
        }
        if (indexPath.row == 1)
        {
//            [gPhoneHelper navigationRedirectThirdMap:self.shop andUserLocation:gMapHelper.coordinate andView:self.view];
            
            [MobClick event:@"rp105-3"];
            CarWashNavigationViewController * vc = [[CarWashNavigationViewController alloc] init];
            vc.shop = self.shop;
            vc.favorite = self.favorite;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp105-5"];
            if (self.shop.shopPhone.length == 0)
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:@"该店铺没有电话~" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
                [av show];
                return ;
            }
            
            NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopPhone];
            [gPhoneHelper makePhone:self.shop.shopPhone andInfo:info];
        }
    }
    else
    {
        if (self.shop.shopCommentArray.count)
        {
            [MobClick event:@"rp105-8"];
            CommentListViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
            vc.shopid = self.shop.shopID;
            vc.commentArray = self.shop.shopCommentArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopTitleCell"];
    JTShop *shop = self.shop;
    
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *businessHoursLb = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UIButton *collectBtn = (UIButton *)[cell.contentView viewWithTag:1007];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1008];
    
    @weakify(self)
    [[[collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        [self requestAddUserFavorite:collectBtn];
    }];

    titleL.text = shop.shopName;
    ratingV.ratingValue = shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%0.1f分", shop.shopRate];
    businessHoursLb.text = [NSString stringWithFormat:@"营业时间：%@ - %@",self.shop.openHour,self.shop.closeHour];
    
    [statusL makeCornerRadius:3];
    statusL.font = [UIFont boldSystemFontOfSize:11]; //ios6字体大小有问题
    if ([self isBetween:shop.openHour and:shop.closeHour]) {
        statusL.text = @"营业中";
        statusL.backgroundColor = HEXCOLOR(@"#1bb745");
    }
    else {
        statusL.text = @"已休息";
        statusL.backgroundColor = HEXCOLOR(@"#b6b6b6");
    }
    
    double myLat = gMapHelper.coordinate.latitude;
    double myLng = gMapHelper.coordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;
    
    return cell;
}

- (UITableViewCell *)shopAddrCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddrCell"];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:1001];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:1002];
    
    @weakify(self)
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp105-4"];
        @strongify(self)
        CarWashNavigationViewController * vc = [[CarWashNavigationViewController alloc] init];
        vc.shop = self.shop;
        vc.favorite = self.favorite;
        [self.navigationController pushViewController:vc animated:YES];

    }];
    
    label.text = self.shop.shopAddress;
    return cell;
}

- (UITableViewCell *)shopPhoneNumberCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhoneNumberCell"];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:1001];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:1002];
    
    @weakify(self)
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        if (self.shop.shopPhone.length == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:@"该店铺没有电话~" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
            [av show];
            return ;
        }
        
        NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopPhone];
        [gPhoneHelper makePhone:self.shop.shopPhone andInfo:info];
    }];
    
    label.text = [NSString stringWithFormat:@"联系电话：%@", self.shop.shopPhone];
    return cell;
}

- (UITableViewCell *)shopServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    UILabel *titleL = (UILabel*)[cell.contentView viewWithTag:1001];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1002];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *introL = (UILabel *)[cell.contentView viewWithTag:1005];
    UIButton *payB = (UIButton*)[cell.contentView viewWithTag:1006];
    
    JTShopService *service = [self.shop.shopServiceArray safetyObjectAtIndex:indexPath.row - 3];
    ///暂无银行
    //    [priceL mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(cc ? iconV : titleL);
    //    }];
    titleL.text = service.serviceName;
    priceL.attributedText = [self priceStringWithOldPrice:nil curPrice:@(service.origprice)];
    introL.text = service.serviceDescription;
    
    @weakify(self);
    [[[payB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        if([LoginViewModel loginIfNeededForTargetViewController:self]) {
            [self gotoPaymentVCWithService:service];
        }
    }];
    
    return cell;
}

- (UITableViewCell *)shopMoreServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MoreServiceCell"];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1001];
    @weakify(self);
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp105-7"];
        @strongify(self);
        
        self.serviceExpanded = YES;
        [self.tableView reloadData];
    }];
    return cell;
}

- (UITableViewCell *)shopCommentTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentTitleCell"];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    label.text = [NSString stringWithFormat:@"商户评价 ( %d )", (int)self.shop.commentNumber];
    return cell;
}

- (UITableViewCell *)shopCommentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    UIImageView *avatarV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *nameL = (UILabel*)[cell.contentView viewWithTag:1002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:1003];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1004];
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *serviceL = (UILabel *)[cell.contentView viewWithTag:1006];
    avatarV.cornerRadius = 17.5f;
    avatarV.layer.masksToBounds = YES;
    
    JTShopComment *comment = [self.shop.shopCommentArray safetyObjectAtIndex:indexPath.row - 1];
    nameL.text = comment.nickname.length ? comment.nickname : @"无昵称用户";
    timeL.text = [comment.time dateFormatForYYMMdd2];
    ratingV.ratingValue = comment.rate;
    contentL.text = comment.comment;
    serviceL.text = comment.serviceName;
    [avatarV setImageByUrl:comment.avatarUrl withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
    
    return cell;
}

- (UITableViewCell *)shopNoCommentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoCommentCell"];
    
    return cell;
}

#pragma mark - SDPhotoBrowserDelegate
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    if (index == 0) {
        NSString *strurl = [gMediaMgr urlWith:[self.shop.picArray safetyObjectAtIndex:0] imageType:ImageURLTypeMedium];
        UIImage *cachedImg = [gMediaMgr imageFromMemoryCacheForUrl:strurl];
        return cachedImg ? cachedImg : [UIImage imageNamed:@"cm_shop"];
    }
    return [UIImage imageNamed:@"cm_shop"];
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:[gMediaMgr urlWith:[self.shop.picArray safetyObjectAtIndex:index] imageType:ImageURLTypeMedium]];
}
#pragma mark - Utility
-(void) headImageView
{
    @weakify(self);
    [self.headImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view.mas_top).offset(0);
    }];
    [self.maskView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view.mas_top).offset(0);
    }];
    
    JTShop *shop = self.shop;
    [self.headImgView setImageByUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeMedium defImage:@"cm_shop" errorImage:@"cm_shop"];
    UITapGestureRecognizer * gesture = self.headImgView.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [self.headImgView addGestureRecognizer:ge];
        self.headImgView.userInteractionEnabled = YES;
        self.headImgView.customObject = ge;
        [ge addTarget:self action:@selector(actionShowPhotos:)];
    }
    gesture = self.headImgView.customObject;
    
    self.imageCountLabel.text = [NSString stringWithFormat:@"%d张", (int)shop.picArray.count];
    
    self.roundLb.textColor = [UIColor colorWithHex:@"#22b7b5" alpha:1.0f];
    self.roundLb.font = [UIFont systemFontOfSize:14];
    self.roundLb.backgroundColor = [UIColor clearColor];
    self.roundBgView.backgroundColor = self.imageCountLabel.backgroundColor;
    self.roundLb.labelSpacing = 30;
    self.roundLb.scrollSpeed = 30;
    self.roundLb.fadeLength = 5.f;
    [self.roundLb observeApplicationNotifications];
    
    
    NSString * note = self.shop.announcement;
    
    CGSize size = [note sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];
    CGFloat width = MIN(size.width, self.view.frame.size.width - 90);
    [self.roundLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(width);
    }];
    self.roundLb.text = note;
    
    self.roundLb.hidden = !self.shop.announcement.length;
    self.roundBgView.hidden = !self.shop.announcement.length;
}

-(BOOL)isBetween:(NSString *)openHourStr and:(NSString *)closeHourStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate * nowDate = [NSDate date];
    NSString * transStr = [formatter stringFromDate:nowDate];
    NSDate * transDate = [formatter dateFromString:transStr];
    
    NSDate * beginDate = [formatter dateFromString:openHourStr];
    NSDate * endDate = [formatter dateFromString:closeHourStr];
    
    return (transDate == [transDate earlierDate:beginDate]) || (transDate == [transDate laterDate:endDate]) ? NO : YES;
}

- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    if (price1) {
        NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
        NSString * p = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:[price1 floatValue]]];
        NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:p attributes:attr1];
        [str appendAttributedString:attrStr1];
    }
    
    if (price2) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
        NSString * p = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:[price2 floatValue]]];
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:p attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}

@end
