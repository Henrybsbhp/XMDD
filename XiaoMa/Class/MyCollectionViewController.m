//
//  MyCollectionViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "JTTableView.h"
#import "FavoriteModel.h"
#import "JTShop.h"
#import "JTRatingView.h"
#import "ShopDetailVC.h"
#import "DeleteUserFavoriteOp.h"
#import "UIView+Layer.h"
#import "PhoneHelper.h"
#import "DistanceCalcHelper.h"


@interface MyCollectionViewController ()

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *allSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic) BOOL  isEditing;

/// 已选中的index
@property (nonatomic,strong)NSMutableIndexSet * selectSet;

@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (gAppMgr.myUser.favorites.favoritesArray.count > 0)
    {
        [self setupNavigationBar];
    }
    [self setupRAC];
    [self initUI];
    [self refreshBottomView];
    
    self.selectSet = [[NSMutableIndexSet alloc] init];
//    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"rp316"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [gAppMgr.myUser.favorites updateModelIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp316"];
    [gToast dismiss];
}

- (void)dealloc
{
    DebugLog(@"MyCollectionViewController dealloc");
}

- (void)reloadData
{
    [self.tableView reloadData];
    if (gAppMgr.myUser.favorites.favoritesArray.count == 0) {
        [self.tableView showDefaultEmptyViewWithText:@"您暂未收藏商户"];
    }
    else {
        [self.tableView hideDefaultEmptyView];
    }
}
#pragma mark - SetupUI
- (void)initUI
{
    self.isEditing = NO;
    
    [gAppMgr.myUser.favorites.dataSignal subscribeNext:^(id x) {
        if (gAppMgr.myUser.favorites.favoritesArray.count == 0)
        {
            
        }
        else
        {
            
        }
    } error:^(NSError *error) {
        
        
    }];
}

- (void)setupNavigationBar
{
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editActions:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)refreshBottomView
{
    CGFloat offsetY = 0;
    if (self.isEditing)
    {
        offsetY = -45;
    }
    else
    {
        offsetY = 0;
    }
    [UIView animateWithDuration:0.5f animations:^{
        
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.view.mas_bottom).offset(offsetY);
            make.height.mas_equalTo(45);
        }];
    }];
}

- (void)refreshCheckBox
{
    if(self.selectSet.count == gAppMgr.myUser.favorites.favoritesArray.count)
    {
        [self.allSelectBtn setSelected:YES];
    }
    else
    {
        [self.allSelectBtn setSelected:NO];
    }
}

- (void)setupRAC
{
    @weakify(self)
    [[self.allSelectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp316-8"];
        @strongify(self)
        if (self.selectSet.count == gAppMgr.myUser.favorites.favoritesArray.count)
        {
            [self.selectSet removeAllIndexes];
            [self.tableView reloadData];
            [self refreshCheckBox];
            return;
        }
        [self.selectSet removeAllIndexes];
        for (NSInteger i = 0 ; i < gAppMgr.myUser.favorites.favoritesArray.count ; i++)
        {
            [self.selectSet addIndex:i];
        }
        [self reloadData];
        [self refreshCheckBox];
    }];
    
    
    [[self.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp316-9"];
        @strongify(self)
        if (self.selectSet.count)
        {
            [self requestDeleteFavorites];
        }
        else
        {
            [gToast showError:@"请选择一家商户进行删除"];
        }
    }];
}


#pragma mark - Action
- (void)editActions:(id)sender
{
    if (self.isEditing && sender)
        [MobClick event:@"rp316-5"];
    if (!self.isEditing)
        [MobClick event:@"rp316-1"];
    self.isEditing = !self.isEditing;
    
    [self refreshBottomView];

    [self.navigationItem.rightBarButtonItem setTitle:(self.isEditing ? @"完成":@"编辑")];
    if (gAppMgr.myUser.favorites.favoritesArray.count == 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self reloadData];
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

- (void)requestDeleteFavorites
{
    NSMutableArray * array = [NSMutableArray array];
    [self.selectSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        JTShop * shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:idx];
        [array addObject:shop.shopID];
    }];
    
    [[[gAppMgr.myUser.favorites rac_removeFavorite:array] initially:^{
        
        [gToast showingWithText:@"移除中..."];
    }] subscribeNext:^(id x) {
        
        [gToast showText:@"移除成功！"];
        
        [self.selectSet removeAllIndexes];
        [self editActions:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
//        [gToast showError:@"移除失败！"];
    }];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return gAppMgr.myUser.favorites.favoritesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger num = 0;
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:section];
    num = 1 + shop.shopServiceArray.count + 1;
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
    NSInteger serviceAmount = shop.shopServiceArray.count;
    NSInteger sectionAmount = 1 + serviceAmount + 1;
    
    if(indexPath.row == 0)
    {
        height = 84.0f;
    }
    else if (indexPath.row == sectionAmount - 1)
    {
        height = 42.0f;
    }
    else
    {
        height = 42.0f;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell;
    
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
    NSInteger serviceAmount = shop.shopServiceArray.count;
    NSInteger rowAmount = 1 + serviceAmount + 1;
    
    if(indexPath.row == 0)
    {
        if (!self.isEditing)
        {
            cell = [self tableView:tableView shopTitleCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self tableView:tableView editShopTitleCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.row == rowAmount - 1)
    {
        cell = [self tableView:tableView shopNavigationCellAtIndexPath:indexPath];
    }
    else
    {
        cell = [self tableView:tableView shopServiceCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isEditing)
    {
        [MobClick event:@"rp316-2"];
        JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
        ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.shop = shop;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger mask = indexPath.row == 0 ? CKViewBorderDirectionBottom : CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:mask];
    [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(0, 0, 8, 0) forDirectionMask:mask];
    [cell.contentView showBorderLineWithDirectionMask:mask];
}


#pragma mark - Utility
- (UITableViewCell *)tableView:(UITableView *)tableView shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
    
    //row 0  缩略图、名称、评分、地址、距离、营业状况等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1007];
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0]
                withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    titleL.text = shop.shopName;
    ratingV.ratingValue = shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
    addrL.text = shop.shopAddress;
    
    [statusL makeCornerRadius:3];
    statusL.font = [UIFont boldSystemFontOfSize:11];
    if ([self isBetween:shop.openHour and:shop.closeHour]) {
        statusL.text = @"营业中";
        statusL.backgroundColor = [UIColor colorWithHex:@"#1bb745" alpha:1.0f];
    }
    else {
        statusL.text = @"已休息";
        statusL.backgroundColor = [UIColor colorWithHex:@"#b6b6b6" alpha:1.0f];
    }
    
    double myLat = gMapHelper.coordinate.latitude;
    double myLng = gMapHelper.coordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    if (myLat == 0 || myLng == 0)
    {
        distantL.hidden = YES;
    }
    else
    {
        distantL.hidden = NO;
        NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
        distantL.text = disStr;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView editShopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EditShopCell" forIndexPath:indexPath];
    
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
    
    //row 0  缩略图、名称、评分、地址、距离、营业状况等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1007];
    
    UIButton * checkBtn = (UIButton *)[cell searchViewWithTag:3003];
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0]
                withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    titleL.text = shop.shopName;
    ratingV.ratingValue = shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
    addrL.text = shop.shopAddress;
    
    [statusL makeCornerRadius:3];
    statusL.font = [UIFont boldSystemFontOfSize:11];
    if ([self isBetween:shop.openHour and:shop.closeHour]) {
        statusL.text = @"营业中";
        statusL.backgroundColor = [UIColor colorWithHex:@"#1bb745" alpha:1.0f];
    }
    else {
        statusL.text = @"已休息";
        statusL.backgroundColor = [UIColor colorWithHex:@"#b6b6b6" alpha:1.0f];
    }
    
    double myLat = gMapHelper.coordinate.latitude;
    double myLng = gMapHelper.coordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    
    if (myLat == 0 || myLng == 0)
    {
        distantL.hidden = YES;
    }
    else
    {
        distantL.hidden = NO;
        NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
        distantL.text = disStr;
    }
    
    [checkBtn setSelected:[self.selectSet containsIndex:indexPath.section]];
    @weakify(checkBtn)
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp316-7"];
        @strongify(checkBtn)
        if ([self.selectSet containsIndex:indexPath.section])
        {
            [self.selectSet removeIndex:indexPath.section];
            [checkBtn setSelected:NO];
        }
        else
        {
            [self.selectSet addIndex:indexPath.section];
            [checkBtn setSelected:YES];
        }
        [self refreshCheckBox];
    }];

    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView shopServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
    
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
    
    //row 1 洗车服务与价格
    UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
    
    JTShopService * service = [shop.shopServiceArray safetyObjectAtIndex:indexPath.row - 1];
    
    washTypeL.text = service.serviceName;
    
    ChargeContent * cc = [service.chargeArray firstObjectByFilteringOperator:^BOOL(ChargeContent * tcc) {
        return tcc.paymentChannelType == PaymentChannelABCIntegral;
    }];
    
    integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
    priceL.attributedText = [self priceStringWithOldPrice:nil curPrice:@(service.origprice)];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopNavigationCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationCell" forIndexPath:indexPath];
    
    JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.section];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:gMapHelper.coordinate andView:self.tabBarController.view];
    }];
    
    [[[phoneB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        if (shop.shopPhone.length == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:@"该店铺没有电话~" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
            [av show];
            return ;
        }
        
        NSString * info = [NSString stringWithFormat:@"%@",shop.shopPhone];
        [gPhoneHelper makePhone:shop.shopPhone andInfo:info];
    }];
    
    return cell;
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



@end
