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
    
    [self setupNavigationBar];
    [self setupRAC];
    [self initUI];
    [self refreshBottomView];
    
    self.selectSet = [[NSMutableIndexSet alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [gAppMgr.myUser.favorites updateModelIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [gToast dismiss];
}

- (void)dealloc
{
    DebugLog(@"MyCollectionViewController dealloc");
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
        
        @strongify(self)
        [self.selectSet removeAllIndexes];
        if (self.selectSet.count == gAppMgr.myUser.favorites.favoritesArray.count)
        {
            return;
        }
        for (NSInteger i = 0 ; i < gAppMgr.myUser.favorites.favoritesArray.count ; i++)
        {
            [self.selectSet addIndex:i];
        }
        [self.tableView reloadData];
        [self refreshCheckBox];
    }];
    
    
    [[self.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
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
    self.isEditing = !self.isEditing;
    
    [self refreshBottomView];
    
    [self.navigationItem.rightBarButtonItem setTitle:(self.isEditing ? @"完成":@"编辑")];
    [self.tableView reloadData];
}


#pragma mark - Utility
- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName:[UIColor lightGrayColor],
                            NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", price1] attributes:attr1];
    
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                            NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" ￥%@", price2] attributes:attr2];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    [str appendAttributedString:attrStr1];
    [str appendAttributedString:attrStr2];
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
        
        [gToast showText:@"移除中..."];
    }] subscribeNext:^(id x) {
        
        [gToast showText:@"移除成功！"];
        
        [self.selectSet removeAllIndexes];
        [self editActions:nil];
    } error:^(NSError *error) {
        
        [gToast showError:@"移除失败！"];
    }];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [gAppMgr.myUser.favorites.favoritesArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 185.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isEditing)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
        JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray  safetyObjectAtIndex:indexPath.row];
        //row 0
        UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
        JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
        UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
        UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
        
        
        [[gMediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defaultPic:@"cm_shop" errorPic:@"cm_shop"] subscribeNext:^(UIImage * image) {
            logoV.image = image;
        }];;
        titleL.text = shop.shopName;
        ratingV.ratingValue = (NSInteger)shop.shopRate;
        ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
        addrL.text = shop.shopAddress;
        
        //row 1
        UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
        UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
        UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
        
        JTShopService * service;
        for (JTShopService * s in shop.shopServiceArray)
        {
            if (s.shopServiceType == ShopServiceCarWash)
            {
                service = s;
                break;
            }
        }
        
        
        washTypeL.text = service.serviceName;
        NSArray * rates = service.chargeArray;
        ChargeContent * cc;
        for (ChargeContent * tcc in rates)
        {
            if (tcc.paymentChannelType == PaymentChannelABCIntegral )
            {
                cc = tcc;
                break;
            }
        }
        
        integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
        priceL.attributedText = [self priceStringWithOldPrice:@(service.origprice) curPrice:@(service.contractprice)];
        
        //row 2
        UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
        UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
        
        @weakify(self)
        [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:gMapHelper.coordinate andView:self.view];
            
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
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditShopCell" forIndexPath:indexPath];
        JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.row];
        //row 0
        UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
        JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
        UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
        UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
        UIButton * checkBtn = (UIButton *)[cell searchViewWithTag:3003];
        
        [[gMediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defaultPic:@"cm_shop" errorPic:@"cm_shop"] subscribeNext:^(UIImage * image) {
            logoV.image = image;
        }];;
        titleL.text = shop.shopName;
        ratingV.ratingValue = (NSInteger)shop.shopRate;
        ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
        addrL.text = shop.shopAddress;
        
        //row 1
        UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
        UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
        UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
        
        JTShopService * service;
        for (JTShopService * s in shop.shopServiceArray)
        {
            if (s.shopServiceType == ShopServiceCarWash)
            {
                service = s;
                break;
            }
        }
        
        
        washTypeL.text = service.serviceName;
        NSArray * rates = service.chargeArray;
        ChargeContent * cc;
        for (ChargeContent * tcc in rates)
        {
            if (tcc.paymentChannelType == PaymentChannelABCIntegral )
            {
                cc = tcc;
                break;
            }
        }
        
        integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
        priceL.attributedText = [self priceStringWithOldPrice:@(service.origprice) curPrice:@(service.contractprice)];
        
        //row 2
        UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
        UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
        
        @weakify(self)
        [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:gMapHelper.coordinate andView:self.view];
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
        
        [checkBtn setSelected:[self.selectSet containsIndex:indexPath.row]];
        @weakify(checkBtn)
        [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(checkBtn)
            if ([self.selectSet containsIndex:indexPath.row])
            {
                [self.selectSet removeIndex:indexPath.row];
                [checkBtn setSelected:NO];
            }
            else
            {
                [self.selectSet addIndex:indexPath.row];
                [checkBtn setSelected:YES];
            }
            [self refreshCheckBox];
        }];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isEditing)
    {
        JTShop *shop = [gAppMgr.myUser.favorites.favoritesArray safetyObjectAtIndex:indexPath.row];
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


@end
