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

#define kDefaultServieCount     2

@interface ShopDetailVC ()<SDPhotoBrowserDelegate>

/// 服务列表展开
@property (nonatomic, assign) BOOL serviceExpanded;
/// 是否已收藏标签
@property (nonatomic)BOOL favorite;

@end

@implementation ShopDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
//    [self setupMyCarList];
    [self requestShopComments];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"rp105"];
    if([gAppMgr.myUser.favorites getFavoriteWithID:self.shop.shopID] == nil){
        self.favorite = NO;
    }
    else {
        self.favorite = YES;
    }
    
    [self setupNavigationBar];
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
- (void)setupNavigationBar
{
    UIButton * collectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 23)];
    UIImage * image = [UIImage imageNamed:self.favorite ? @"collected" : @"collect"];
    
    [collectBtn setImage:image forState:UIControlStateNormal];

    @weakify(self);
    [[collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp105-1"];
        @strongify(self);
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
                    [collectBtn setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
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
                    [collectBtn setImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
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
                        [collectBtn setImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                        [gToast dismiss];
                    }
                    else {
                        [gToast showError:error.domain];
                    }
                }];
            }
        }
    }];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:collectBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)setupMyCarList
{
    [[gAppMgr.myUser.carModel rac_fetchDataIfNeeded] subscribeNext:^(id x) {
        
    }];
}

#pragma mark - Action
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
        browser.sourceImagesContainerView = tap.view.superview; // 原图的父控件
        browser.imageCount = self.shop.picArray.count; // 图片总数
        browser.currentImageIndex = 0;
        browser.delegate = self;
        [browser show];
    }
}

- (void)gotoPaymentVCWithService:(JTShopService *)service
{
    [[[gAppMgr.myUser.carModel rac_getDefaultCar] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal return:nil];
    }] subscribeNext:^(HKMyCar *car) {

        if (car && [car isCarInfoCompleted])
        {
            PayForWashCarVC *vc = [UIStoryboard vcWithId:@"PayForWashCarVC" inStoryboard:@"Carwash"];
            vc.originVC = self;
            vc.shop = self.shop;
            vc.service = service;
            vc.defaultCar = car;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (car) {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的爱车信息不完善，请先完善" delegate:nil
                                                cancelButtonTitle:@"前往完善" otherButtonTitles: nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                [MobClick event:@"rp104-9"];
                EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
                vc.originCar = car;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [av show];
        }
        else
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您尚未添加车辆，请添加一辆" delegate:nil cancelButtonTitle:@"前往添加" otherButtonTitles: nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                [MobClick event:@"rp104-9"];
                EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [av show];
        }
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
        else if (indexPath.row == 1 || indexPath.row == 2) {
            height = 44;
        }
        else if (indexPath.row < 3 + self.shop.shopServiceArray.count) {
            height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
                height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
    return 9;
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
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *businessHoursLb = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UIButton *collectBtn = (UIButton *)[cell.contentView viewWithTag:1007];
    
    
    UITapGestureRecognizer * gesture = logoV.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [logoV addGestureRecognizer:ge];
        logoV.userInteractionEnabled = YES;
        logoV.customObject = ge;
        [ge addTarget:self action:@selector(actionShowPhotos:)];
    }
    gesture = logoV.customObject;
    
    @weakify(self);
    [[[collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        [self requestAddUserFavorite:collectBtn];
    }];
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    titleL.text = shop.shopName;
    ratingV.ratingValue = shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%0.1f分", shop.shopRate];
    businessHoursLb.text = [NSString stringWithFormat:@"营业时间：%@ - %@",self.shop.openHour,self.shop.closeHour];
    
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
//        [gPhoneHelper navigationRedirectThirdMap:self.shop andUserLocation:gMapHelper.coordinate andView:self.view];
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
        [MobClick event:@"rp105-6"];
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
    avatarV.cornerRadius = 17.5f;
    avatarV.layer.masksToBounds = YES;
    
    JTShopComment *comment = [self.shop.shopCommentArray safetyObjectAtIndex:indexPath.row - 1];
    nameL.text = comment.nickname.length ? comment.nickname : @"无昵称用户";
    timeL.text = [comment.time dateFormatForYYMMdd2];
    ratingV.ratingValue = comment.rate;
    contentL.text = comment.comment;
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
        NSString *strurl = [gMediaMgr urlWith:[self.shop.picArray safetyObjectAtIndex:0] imageType:ImageURLTypeThumbnail];
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
- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    if (price1) {
        NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
        NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:
                                        [NSString stringWithFormat:@"￥%.2f", [price1 floatValue]] attributes:attr1];
        [str appendAttributedString:attrStr1];
    }
    
    if (price2) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:
                                        [NSString stringWithFormat:@" ￥%.2f", [price2 floatValue]] attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}

@end
