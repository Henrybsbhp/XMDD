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
#import "ShopDetailViewController.h"
#import "DeleteUserFavoriteOp.h"
#import "UIView+Layer.h"
#import "PhoneHelper.h"
#import "DistanceCalcHelper.h"
#import "ShopDetailStore.h"
#import "ShopListStore.h"
#import "UILabel+MarkupExtensions.h"


@interface MyCollectionViewController ()

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *allSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) CKList *datasource;
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
    
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(id x) {
        
        @strongify(self);
        [self getData];
    }];
    
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [gToast dismiss];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MyCollectionViewController dealloc");
}

- (void)reloadDatasource {
    
    CKList *datasource = [CKList list];
    for (JTShop *shop in gAppMgr.myUser.favorites.favoritesArray) {
        CKDict *dict = [CKDict dictWith:@{kCKItemKey: shop.shopID, @"shop": shop}];
        NSMutableArray *serviceItems = [NSMutableArray array];
        if (shop.shopServiceArray.count > 0) {
            [serviceItems addObjectsFromArray:shop.shopServiceArray];
        }
        if (shop.beautyServiceArray.count > 0) {
            [serviceItems addObject:shop.beautyServiceArray[0]];
        }
        if (shop.maintenanceServiceArray.count > 0) {
            [serviceItems addObject:shop.maintenanceServiceArray[0]];
        }
        dict[@"serviceItems"] = serviceItems;
        [datasource addObject:dict forKey:nil];
    }
    self.datasource = datasource;
    [self.tableView reloadData];
}

- (void)refreshViews {
    
    [self.tableView reloadData];
    if (self.datasource.count == 0) {
        [self.view showImageEmptyViewWithImageName:@"def_withoutCollection" text:@"您暂未收藏商户"];
    }
    else {
        [self.view hideDefaultEmptyView];
    }
}

-(void)getData
{
    @weakify(self);
    [[gAppMgr.myUser.favorites rac_requestData]subscribeNext:^(id x) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self reloadDatasource];
    }];
}

#pragma mark - SetupUI
- (void)initUI
{
    self.isEditing = NO;
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
        @weakify(self);
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self);
            make.top.mas_equalTo(self.view.mas_bottom).offset(offsetY);
            make.height.mas_equalTo(45);
        }];
    }];
}

- (void)refreshCheckBox
{
    if(self.selectSet.count == self.datasource.count)
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
        
        [MobClick event:@"rp316_8"];
        @strongify(self)
        if (self.selectSet.count == self.datasource.count)
        {
            [self.selectSet removeAllIndexes];
            [self.tableView reloadData];
            [self refreshCheckBox];
            return;
        }
        [self.selectSet removeAllIndexes];
        for (NSInteger i = 0 ; i < self.datasource.count ; i++)
        {
            [self.selectSet addIndex:i];
        }
        [self refreshViews];
        [self refreshCheckBox];
    }];
    
    
    [[self.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp316_9"];
        @strongify(self)
        if (self.selectSet.count)
        {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                [self requestDeleteFavorites];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您确定删除收藏的店铺?" ActionItems:@[cancel,confirm]];
            [alert show];
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
        [MobClick event:@"rp316_5"];
    if (!self.isEditing)
        [MobClick event:@"rp316_1"];
    self.isEditing = !self.isEditing;
    
    [self refreshBottomView];

    [self.navigationItem.rightBarButtonItem setTitle:(self.isEditing ? @"完成":@"编辑")];
    if (self.datasource.count == 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self refreshViews];
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
        
        JTShop * shop = self.datasource[idx][@"shop"];
        [array addObject:shop.shopID];
    }];
    
    @weakify(self)
    [[[gAppMgr.myUser.favorites rac_removeFavorite:array] initially:^{
        
        [gToast showingWithText:@"移除中..."];
    }] subscribeNext:^(id x) {
        @strongify(self)
        [gToast showText:@"移除成功！"];
        
        [self.selectSet removeAllIndexes];
        [self editActions:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}


#pragma mark - Table view data source 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *serviceItems = self.datasource[section][@"serviceItems"];
    return serviceItems.count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    NSArray *serivceItems = self.datasource[indexPath.section][@"serviceItems"];
    NSInteger serviceAmount = serivceItems.count;
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
    
    NSArray *serviceItems = self.datasource[indexPath.section][@"serviceItems"];
    NSInteger serviceAmount = serviceItems.count;
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
        [MobClick event:@"rp316_2"];
        ShopDetailViewController *vc = [[ShopDetailViewController alloc] init];
        vc.shop = self.datasource[indexPath.section][@"shop"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger mask = indexPath.row == 0 ? CKViewBorderDirectionBottom : CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    [cell.contentView setBorderLineColor:kDarkLineColor forDirectionMask:mask];
    [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(0, 0, 8, 0) forDirectionMask:mask];
    [cell.contentView showBorderLineWithDirectionMask:mask];
}


#pragma mark - Utility
- (UITableViewCell *)tableView:(UITableView *)tableView shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    
    JTShop *shop = self.datasource[indexPath.section][@"shop"];
    
    //row 0  缩略图、名称、评分、地址、距离、营业状况等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1007];
    UIImageView *statusImg=(UIImageView *)[cell.contentView viewWithTag:1009];
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0]
                withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    titleL.text = shop.shopName;
    addrL.text = shop.shopAddress;
    
    [statusL makeCornerRadius:3];
    statusL.font = [UIFont boldSystemFontOfSize:11];
    if([shop.isVacation integerValue] == ShopVacationTypeVacation)//isVacation==1表示正在休假
    {
        statusL.hidden = YES;
        statusImg.hidden = NO;
    }
    else
    {
        statusL.hidden = NO;
        statusImg.hidden = YES ;
        
        if ([self isBetween:shop.openHour and:shop.closeHour]) {
            statusL.text = @"营业中";
            statusL.backgroundColor = kDefTintColor;
        }
        else {
            statusL.text = @"已休息";
            statusL.backgroundColor = HEXCOLOR(@"#cfdbd3");
        }
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
    
    JTShop *shop = self.datasource[indexPath.section][@"shop"];
    
    //row 0  缩略图、名称、评分、地址、距离、营业状况等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1007];
    UIImageView *statusImg=(UIImageView *)[cell.contentView viewWithTag:1009];
    
    UIButton * checkBtn = (UIButton *)[cell searchViewWithTag:3003];
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0]
                withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    titleL.text = shop.shopName;
    addrL.text = shop.shopAddress;
    [statusL makeCornerRadius:3];
    statusL.font = [UIFont boldSystemFontOfSize:11];
    
    if([shop.isVacation integerValue] == ShopVacationTypeVacation)//isVacation==1表示正在休假
    {
        statusL.hidden = YES;
        statusImg.hidden = YES;//编辑状态不显示
        
    }
    else
    {
        statusL.hidden = NO;
        statusImg.hidden = YES ;
        
        if ([self isBetween:shop.openHour and:shop.closeHour]) {
            statusL.text = @"营业中";
            statusL.backgroundColor = kDefTintColor;
        }
        else {
            statusL.text = @"已休息";
            statusL.backgroundColor = HEXCOLOR(@"#cfdbd3");
        }
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
    @weakify(self);
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp316_7"];
        @strongify(checkBtn)
        @strongify(self);
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
    
    NSArray *serviceItems = self.datasource[indexPath.section][@"serviceItems"];
    JTShopService *service = serviceItems[indexPath.row - 1];
    //row 1 洗车服务与价格
    UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
    
    washTypeL.text = [ShopDetailStore serviceGroupDescForServiceType:service.shopServiceType];
    [priceL setMarkup:[ShopListStore markupForShopServicePrice:service]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopNavigationCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationCell" forIndexPath:indexPath];
    
    JTShop *shop = self.datasource[indexPath.section][@"shop"];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    @weakify(self);
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:gMapHelper.coordinate andView:self.tabBarController.view];
    }];
    
    [[[phoneB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        if (shop.shopPhone.length == 0)
        {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该店铺没有电话~" ActionItems:@[cancel]];
            [alert show];
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
