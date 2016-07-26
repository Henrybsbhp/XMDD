//
//  CarwashOrderDetailVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarwashOrderDetailVC.h"
#import "XiaoMa.h"
#import "UIView+Layer.h"
#import "ShopDetailVC.h"
#import "NSString+RectSize.h"
#import "JTRatingView.h"
#import "HKLoadingModel.h"
#import "GetCarwashOrderV2Op.h"
#import "ShopDetailVC.h"
#import "PaymentSuccessVC.h"
#import "GetShareButtonOpV2.h"
#import "ShareResponeManager.h"
#import "SocialShareViewController.h"

@interface CarwashOrderDetailVC ()<UITableViewDelegate, UITableViewDataSource, HKLoadingModelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *detailItems;
@property (nonatomic, strong) HKLoadingModel *loadingModel;

@property (nonatomic,strong)UIButton * commentBtn;
@property (nonatomic,strong)UIButton * shareBtn;
@end

@implementation CarwashOrderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationBar];
    
    CKAsyncMainQueue(^{
        
        [self loadOrderInfo];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CarwashOrderDetailVC dealloc");
}

#pragma mark - Setup
- (void)setupNavigationBar
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"联系客服" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionCallService:)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupTableViewFootView
{
    [self.tableView.tableFooterView removeSubviews];
    self.tableView.tableFooterView.backgroundColor = kBackgroundColor;
    self.tableView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 86);
    if (self.order.ratetime)
    {
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.backgroundColor = kOrangeColor;
        self.shareBtn.cornerRadius = 5.0f;
        [self.shareBtn setTitle:@"晒单炫耀" forState:UIControlStateNormal];
        [self.tableView.tableFooterView addSubview:self.shareBtn];
        
        @weakify(self)
        [[self.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            @strongify(self)
            [self actionShare];
        }];
        
        
        [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self)
            make.height.mas_equalTo(50);
            make.top.equalTo(self.tableView.tableFooterView).offset(8);
            make.leading.equalTo(self.tableView.tableFooterView).offset(18);
            make.trailing.equalTo(self.tableView.tableFooterView).offset(-18);
        }];

    }
    else
    {
        self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.commentBtn.backgroundColor = kDefTintColor;
        self.commentBtn.cornerRadius = 5.0f;
        [self.commentBtn setTitle:@"去评价" forState:UIControlStateNormal];
        [self.tableView.tableFooterView addSubview:self.commentBtn];
        @weakify(self)
        [[self.commentBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
           
            @strongify(self)
            [self actionComment];
        }];
        
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.backgroundColor = kOrangeColor;
        self.shareBtn.cornerRadius = 5.0f;
        [self.shareBtn setTitle:@"晒单炫耀" forState:UIControlStateNormal];
        [self.tableView.tableFooterView addSubview:self.shareBtn];
        [[self.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            @strongify(self)
            [self actionShare];
        }];
        
    
        [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self)
            make.height.mas_equalTo(50);
            make.top.equalTo(self.tableView.tableFooterView).offset(8);
            make.leading.equalTo(self.tableView.tableFooterView).offset(18);
            
        }];
        
        [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self)
            make.height.mas_equalTo(50);
            make.top.equalTo(self.tableView.tableFooterView).offset(8);
            make.trailing.equalTo(self.tableView.tableFooterView).offset(-18);
            make.left.equalTo(self.commentBtn.mas_right).offset(18);
            make.width.equalTo(self.commentBtn);
        }];
    }
}

#pragma mark - Utilitly
- (void)loadOrderInfo
{
    if (self.order) {
        [self reloadTableView];
    }
    else {
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
        [self.loadingModel loadDataForTheFirstTime];
    }
}

- (void)reloadTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setupTableViewFootView];
    
    //这一行必须加，否则第一行的section的高度不起作用。
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, CGFLOAT_MIN)];
    NSString *strpirce = [NSString stringWithFormat:@"%.2f", self.order.serviceprice];
    self.detailItems = @[RACTuplePack(@"我的车辆：", self.order.licencenumber),
                         RACTuplePack(@"服务项目：", self.order.servicename),
                         RACTuplePack(@"项目价格：", strpirce),
                         RACTuplePack(@"支付方式：", self.order.paydesc),
                         RACTuplePack(@"支付时间：", [self.order.txtime dateFormatForYYYYMMddHHmm2])];
    [self.tableView reloadData];
}

#pragma mark - Action
/**
 *  开始评价
 *
 *  @param sender 按钮
 */
- (void)actionComment
{
    [MobClick event:@"rp320_1"];
    
    PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
    vc.order = self.order;
    vc.originVC = self.originVC;
    [vc setCommentSuccess:^{
        [self reloadTableView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionShare
{
//    [MobClick event:@"rp320_1"]; @fq
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneCarwash;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"分享信息拉取中..."];
    }] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneCarwash;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)actionCallService:(id)sender {
    
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"对订单有疑问？\n请拨打客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}


#pragma mark - UITableViewDelegate and UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /**
     *  YES 已评价 NO 未评价
     */
    return self.order.ratetime ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.detailItems.count + 1;
    }
    else
    {
        // 第二section
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 )
    {
        if (indexPath.row == 0)
        {
            CGSize size = [self.order.shop.shopName labelSizeWithWidth:self.tableView.frame.size.width - 80 font:[UIFont systemFontOfSize:14]];
            return size.height + 70;
        }
        else if (indexPath.row <= self.detailItems.count)
        {
            return 40;
        }
        else
        {
            return 60;
        }
    }
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        if (self.order.comment.length == 0)
        {
            return 90;
        }
        else
        {
        CGFloat width = CGRectGetWidth(self.tableView.frame) - 70;
        CGSize size = [self.order.comment labelSizeWithWidth:width font:[UIFont systemFontOfSize:14]];
        return ceil(size.height+90);
        }
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    view.backgroundColor = kBackgroundColor;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell = [self shopCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self detailCellAtIndexPath:indexPath];
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell = [self commentTitleCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self commentCellAtIndexPath:indexPath];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0 )
    {
        ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
        vc.shop = self.order.shop;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [MobClick event:@"rp320_2"];
}

#pragma mark - Cell
- (UITableViewCell *)shopCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    addrL.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 120;
    
    JTShop *shop = self.order.shop;
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    titleL.text = shop.shopName;
    addrL.text = shop.shopAddress;
    
    return cell;
}

- (UITableViewCell *)detailCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *detailL = (UILabel *)[cell.contentView viewWithTag:1002];
    RACTuple *item = [self.detailItems safetyObjectAtIndex:(indexPath.row - 1)];
    titleL.text = item.first;
    detailL.text = item.second;
    int lineMask = CKViewBorderDirectionNone;
    if (indexPath.row == 0)
    {
        lineMask |= CKViewBorderDirectionTop;
    }
    else if (indexPath.row >= self.detailItems.count-1)
    {
        lineMask |= CKViewBorderDirectionBottom;
    }
    [cell setBorderLineColor:kDefLineColor forDirectionMask:lineMask];
    [cell showBorderLineWithDirectionMask:lineMask];
    
    return cell;
}


- (UITableViewCell *)commentTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentTitleCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)commentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    UIImageView *avatarV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *nameL = (UILabel*)[cell.contentView viewWithTag:1002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:1003];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1004];
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *server = [cell viewWithTag:1006];
    avatarV.cornerRadius = 17.5f;
    avatarV.layer.masksToBounds = YES;
    
    nameL.text = self.order.nickName;
    nameL.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 100;
    timeL.text = [self.order.ratetime dateFormatForYYMMdd2];
    ratingV.ratingValue = self.order.rating;
    contentL.text = self.order.comment;
    server.text = [NSString stringWithFormat:@"服务项目：%@",self.order.servicename];
    
    [avatarV setImageByUrl:self.order.orderPic withType:ImageURLTypeThumbnail defImage:@"avatar_default" errorImage:@"avatar_default"];
    
    return cell;
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    //保证动画停止
    [self.view stopActivityAnimation];
    return @{@"title":@"获取订单信息失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    GetCarwashOrderV2Op *op = [GetCarwashOrderV2Op operation];
    op.req_orderid = self.orderID;
    @weakify(self);
    return [[op rac_postRequest] map:^id(GetCarwashOrderV2Op *op) {
        @strongify(self);
        self.order = op.rsp_order;
        return op.rsp_order;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
}

@end
