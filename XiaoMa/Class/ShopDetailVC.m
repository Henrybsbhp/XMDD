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


#define kDefaultServieCount     2

@interface ShopDetailVC ()

/// 服务列表展开
@property (nonatomic, assign) BOOL serviceExpanded;
/// 是否已收藏标签
@property (nonatomic)BOOL favorite;

@end

@implementation ShopDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([gAppMgr.myUser.favorites getFavoriteWithID:self.shop.shopID] == nil){
        self.favorite = NO;
    }
    else {
        self.favorite = YES;
    }
    
    [self setupNavigationBar];
    [self requestShopComments];
}


- (void)dealloc
{
    DebugLog(@"ShopDetailVC Dealloc");
}

#pragma mark - SetupUI
- (void)setupNavigationBar
{
    UIButton * collectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 22)];
    UIImage * image = [UIImage imageNamed:self.favorite ? @"collected" : @"collect"];
    [collectBtn setImage:image forState:UIControlStateNormal];
    
    @weakify(self)
    [[collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        
        if ([LoginViewModel loginIfNeededForTargetViewController:self])
        {
            NSObject * obk = gAppMgr.myUser.favorites;
            if (self.favorite)
            {
                [[[gAppMgr.myUser.favorites rac_removeFavorite:self.shop.shopID] initially:^{
                    
                    [SVProgressHUD showWithStatus:@"移除中..."];
                }]  subscribeNext:^(id x) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"移除成功"];
                    
                    self.favorite = NO;
                    [collectBtn setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
                } error:^(NSError *error) {
                    
                    [SVProgressHUD showErrorWithStatus:error.domain];
                }];
            }
            else
            {
                [[[gAppMgr.myUser.favorites rac_addFavorite:self.shop] initially:^{
                    
                    [SVProgressHUD showWithStatus:@"添加中..."];
                }]  subscribeNext:^(id x) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                    
                    self.favorite = YES;
                    [collectBtn setImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                } error:^(NSError *error) {
                    
                    if (error.code == 7002)
                    {
                        [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                        self.favorite = YES;
                        [collectBtn setImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:error.domain];
                    }
                }];
            }
        }
    }];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:collectBtn];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Action
- (void)requestShopComments
{
    GetShopRatesOp * op = [GetShopRatesOp operation];
    op.shopId = self.shop.shopID;
    op.pageno = 1;
    [[op rac_postRequest] subscribeNext:^(GetShopRatesOp * op) {
        
        self.shop.shopCommentArray = op.rsp_shopCommentArray;
        
        NSIndexSet *indexSet= [[NSIndexSet alloc] initWithIndex:1];
        
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)requestAddUserFavorite:(UIButton *)btn
{
    AddUserFavoriteOp * op = [AddUserFavoriteOp operation];
    op.shopid = self.shop.shopID;
    [[[op rac_postRequest] initially:^{
        
        [SVProgressHUD showWithStatus:@"add..."];
    }] subscribeNext:^(AddUserFavoriteOp * op) {
        
        [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
        self.favorite = YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } error:^(NSError *error) {
        
        self.favorite = NO;
        if (error.code == 7001)
        {
            [SVProgressHUD  showErrorWithStatus:@"该店铺不存在"];
        }
        else if (error.code == 7002)
        {
            [SVProgressHUD  showErrorWithStatus:@"该店铺已收藏"];
        }
        else
        {
            [SVProgressHUD  showErrorWithStatus:@"收藏失败"];
        }
    }];
}


- (IBAction)actionMap:(id)sender
{
    CarWashNavigationViewController * vc = [[CarWashNavigationViewController alloc] init];
    vc.shop = self.shop;
    [self.navigationController pushViewController:vc animated:YES];
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
        count = 1 + (self.shop.shopCommentArray.count ? self.shop.shopCommentArray.count : 1);
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
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
        if (indexPath.row == 1)
        {
            [gPhoneHelper navigationRedirectThireMap:self.shop andUserLocation:gMapHelper.coordinate andView:self.view];
        }
        else if (indexPath.row == 2)
        {
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
        CommentListViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
        vc.shopid = self.shop.shopID;
        vc.commentArray = self.shop.shopCommentArray;
        [self.navigationController pushViewController:vc animated:YES];
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
    }
    gesture = logoV.customObject;
    [[[gesture rac_gestureSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        if (self.shop.picArray.count)
        {
            [self showImages:0];
        }
    }];
    
    @weakify(self)
    [[[collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        [self requestAddUserFavorite:collectBtn];
    }];
    
    
    [[gMediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0]
                      withDefaultPic:@"shop_default"] subscribeNext:^(UIImage * img) {
        
        logoV.image = img;
    }];
    titleL.text = shop.shopName;
    ratingV.ratingValue = (NSInteger)shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%0.2f分", shop.shopRate];
    businessHoursLb.text = [NSString stringWithFormat:@"营业时间：%@ - %@",self.shop.openHour,self.shop.closeHour];
    
    double myLat = gMapHelper.coordinate.latitude;
    double myLng = gMapHelper.coordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;
    
    NSString * btnImageName = self.favorite ? @"collected" : @"collect";
    [collectBtn setImage:[UIImage imageNamed: btnImageName]
                forState:UIControlStateNormal];
    
    return cell;
}

- (UITableViewCell *)shopAddrCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddrCell"];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:1001];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:1002];
    
    @weakify(self)
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [gPhoneHelper navigationRedirectThireMap:self.shop andUserLocation:gMapHelper.coordinate andView:self.view];
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
    priceL.attributedText = [self priceStringWithOldPrice:@(service.origprice) curPrice:@(service.contractprice)];
    introL.text = service.serviceDescription;
    
    @weakify(self);
    [[[payB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        if([LoginViewModel loginIfNeededForTargetViewController:self]) {
            
            if (gAppMgr.myUser.carArray == nil || gAppMgr.myUser.carArray.count > 0)
            {
                PayForWashCarVC *vc = [UIStoryboard vcWithId:@"PayForWashCarVC" inStoryboard:@"Carwash"];
                vc.originVC = self;
                vc.shop = self.shop;
                vc.service = service;
                vc.defaultCar = [gAppMgr.myUser getDefaultCar];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您尚未添加车辆，请添加一辆" delegate:nil cancelButtonTitle:@"残忍拒绝" otherButtonTitles:@"前往添加", nil];
                [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                    
                    NSInteger index = [num integerValue];
                    if (index == 1)
                    {
                        EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
                        [self.navigationController pushViewController:vc animated:YES];
                        [vc reloadWithOriginCar:nil];
                    }
                }];
                [av show];
            }
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
    label.text = [NSString stringWithFormat:@"商户评价 ( %d )", (int)self.shop.shopCommentArray.count];
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
    
    JTShopComment *comment = [self.shop.shopCommentArray safetyObjectAtIndex:indexPath.row - 1];
    avatarV.image = [UIImage imageNamed:@"tmp_a1"];
    nameL.text = comment.nickname.length ? comment.nickname : @"无昵称用户";
    timeL.text = [comment.time dateFormatForYYMMdd];
    ratingV.ratingValue = comment.rate;
    contentL.text = comment.comment;
    [[gMediaMgr rac_getPictureForUrl:comment.avatarUrl withDefaultPic:@
      "avatar_default"] subscribeNext:^(id x) {
        
        avatarV.image = x;
    }];
    
    return cell;
}

- (UITableViewCell *)shopNoCommentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoCommentCell"];
    
    return cell;
}

#pragma mark - Utility
- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    if (price1) {
        NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
        NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", price1] attributes:attr1];
        [str appendAttributedString:attrStr1];
    }
    if (price2) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" ￥%@", price2] attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}

- (void)showImages:(NSInteger)rotationIndex
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIScrollView * backgroundView= [[UIScrollView alloc]
                                    initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    backgroundView.showsHorizontalScrollIndicator = NO;
    backgroundView.backgroundColor = [UIColor colorWithHex:@"#0000000" alpha:0.6f];
    backgroundView.alpha = 0;
    [backgroundView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * self.shop.picArray.count, [UIScreen mainScreen].bounds.size.height)];
    backgroundView.pagingEnabled = YES;
    
    CGRect frame = backgroundView.frame;
    frame.origin.x = frame.size.width * rotationIndex;
    frame.origin.y = 0;
    [backgroundView scrollRectToVisible:frame animated:YES];
    
    for (NSInteger i = 0;i < self.shop.picArray.count;i++)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        NSString * imageUrl = [self.shop.picArray safetyObjectAtIndex:i];
        [[gMediaMgr rac_getPictureForUrl:imageUrl withDefaultPic:@"shop_default"] subscribeNext:^(UIImage * image) {
            
            CGRect frame = CGRectMake(i*[UIScreen mainScreen].bounds.size.width,
                                      ([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2,
                                      [UIScreen mainScreen].bounds.size.width,
                                      image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
            imageView.frame = frame;
            [imageView setImage:image];
        } error:^(NSError *error) {
            
            [imageView setImage:[UIImage imageNamed:@"tmp_ad"]];
        }];
        
        imageView.tag = i;
        [backgroundView addSubview:imageView];
    }
    
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}
@end
