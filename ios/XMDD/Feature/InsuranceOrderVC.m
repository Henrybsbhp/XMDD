//
//  InsuranceOrderVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKImageAlertVC.h"
#import "InsuranceOrderVC.h"
#import "UIView+Layer.h"
#import "BorderLineLabel.h"
#import "InsuranceOrderPayOp.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "InsuranceStore.h"
#import "InsuranceVM.h"
#import "HKProgressView.h"
#import "PayForInsuranceVC.h"
#import "HKArrowView.h"
#import "NSString+RectSize.h"
#import "GetShareButtonOpV2.h"
#import "SocialShareViewController.h"

@interface InsuranceOrderVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *coverages;
@property (nonatomic, strong) InsuranceStore *insStore;
@property (strong, nonatomic) HKImageAlertVC *alert;
@property (nonatomic, strong) CKList *dataSource;

@end

@implementation InsuranceOrderVC
- (void)awakeFromNib
{
    if (!self.insModel) {
        self.insModel = [[InsuranceVM alloc] init];
        self.insModel.originVC = self;
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsuranceOrderVC dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.insModel.orderVC = self;
    if (self.order) {
        self.orderID = self.order.orderid;
        [self setupRefreshView];
        [self reloadWithOrderStatus:self.order.status];
        [self setupInsuranceStore];
    }
    else {
        [self setupInsuranceStore];
        CKAsyncMainQueue(^{
            [[self.insStore getInsOrderByID:self.orderID] send];
        });
    }
}


- (void)setupRefreshView
{
    [self.tableView.refreshView addTarget:self action:@selector(actionRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)resetBottomButton
{
    SEL action;
    NSString *title;
    if (self.order.status == InsuranceOrderStatusUnpaid)
    {
        title = @"去支付";
        action = @selector(actionPay:);
    }
    else
    {
        title = @"晒单炫耀";
        action = @selector(actionShare:);
    }
    [self.bottomButton setBackgroundColor:kOrangeColor];
    self.bottomButton.layer.cornerRadius = 5.0;
    self.bottomButton.layer.masksToBounds = YES;
    [self.bottomButton setTitle:title forState:UIControlStateNormal];
    [self.bottomButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.bottomButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupInsuranceStore
{
    self.insStore = [InsuranceStore fetchOrCreateStore];
    @weakify(self);
    [self.insStore subscribeWithTarget:self domain:@"insOrder" receiver:^(CKStore *store, CKEvent *evt) {
        
        @strongify(self);
        if (evt.object && [evt.object isEqual:self.orderID]) {
            [self reloadWithEvent:evt];
        }
    }];
}

- (void)reloadWithEvent:(CKEvent *)event
{
    @weakify(self);
    [[[event signal] initially:^{
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            self.containerView.hidden = YES;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            self.containerView.hidden = NO;
            [self.view stopActivityAnimation];
            [self setupRefreshView];
        }
        self.order = x;
        [self reloadWithOrderStatus:self.order.status];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取订单详情失败，点击重试" tapBlock:^{
                @strongify(self);
                [[self.insStore getInsOrderByID:self.orderID] send];
            }];
        }
    }];
}
#pragma mark - Load
- (void)reloadNavBarWithOrderStatus:(InsuranceOrderStatus)status
{
    if (status == InsuranceOrderStatusUnpaid) {
        UIBarButtonItem *cancel = [UIBarButtonItem barButtonItemWithTitle:@"取消订单" target:self
                                                                   action:@selector(actionCancelOrder:)];
        self.navigationItem.rightBarButtonItem = cancel;
    }
    else {
        UIBarButtonItem *call = [UIBarButtonItem barButtonItemWithTitle:@"联系客服" target:self
                                                                 action:@selector(actionMakeCall:)];

        self.navigationItem.rightBarButtonItem = call;
    }
}

- (void)reloadWithOrderStatus:(InsuranceOrderStatus)status
{
    [self reloadNavBarWithOrderStatus:status];
    
    self.order.status = status;
    //总计保费
    CGFloat total = self.order.totoalpay+self.order.forcetaxfee;
    //优惠后的价格
    CGFloat discountedPrice = total - self.order.activityAmount;
    id amount;
    id remark;
    //优惠额度
    int activityAmount = floor(self.order.activityAmount);
    if (activityAmount > 0)
    {
        remark = [NSString stringWithFormat:@"原价￥%.2f 优惠￥%.2f",total,self.order.activityAmount];
        amount = [NSString stringWithFormat:@"￥%.2f",discountedPrice];
    }
    else
    {
        amount = [NSString stringWithFormat:@"￥%.2f", total];
    }
    
    NSArray *array = @[RACTuplePack(@"被保险人",_order.policyholder),
                       RACTuplePack(@"保险公司",_order.inscomp),
                       RACTuplePack(@"证件号码",_order.idcard),
                       RACTuplePack(@"投保车辆",_order.licencenumber),
                       RACTuplePack(@"共计保费",amount,remark)];
    NSMutableArray *titles = [NSMutableArray arrayWithArray:array];
    if (_order.validperiod.length > 0){
        [titles safetyAddObject:RACTuplePack(@"商业险期限",_order.validperiod)];
    }
    if (_order.insordernumber.length > 0) {
        [titles safetyInsertObject:RACTuplePack(@"保单编号",_order.insordernumber) atIndex:0];
    }
    if (_order.fvalidperiod.length > 0) {
        [titles safetyAddObject:RACTuplePack(@"交强险期限",_order.fvalidperiod)];
    }
    self.titles = titles;
    self.coverages = self.order.policy.subInsuranceArray;
    [self resetBottomButton];
    [self reloadData];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1012_1"];
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionShare:(id)sender {
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneInsurance;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneInsurance;    //页面位置
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

- (void)actionPay:(id)sender {
    [MobClick event:@"rp1012_2"];
    PayForInsuranceVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"PayForInsuranceVC"];
    vc.insModel = self.insModel;
    vc.insOrder = self.order;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCancelOrder:(id)sender {
    [MobClick event:@"rp1012_4"];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"算了吧" color:kGrayTextColor clickBlock:^(id alertVC) {
        [MobClick event:@"rp1012_5"];
    }];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定取消" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [MobClick event:@"rp1012_6"];
        [self requestCancelInsOrder];
    }];
    HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"取消订单后，订单将关闭且无法继续支付您确定现在取消订单？" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (void)actionMakeCall:(id)sender {
    [MobClick event:@"rp1012_3"];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"咨询电话：4007-111-111，是否立即拨打？" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (void)actionRefresh {
    [[self.insStore getInsOrderByID:self.orderID] send];
}

#pragma mark - Request
- (void)requestCancelInsOrder
{
    @weakify(self);
    [[[[self.insStore cancelInsOrderByID:self.orderID] sendAndIgnoreError] initially:^{
        
        [gToast showingWithText:@"正在取消订单"];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        [[self.insStore getInsSimpleCars] sendAndIgnoreError];
        [self actionBack:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block)
    {
        return block(data,indexPath);
    }
    else
    {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID]];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block)
    {
        block(data,cell,indexPath);
    }
    return cell;
}

#pragma mark - About Cell

// 进度条cell
-(CKDict *)progressCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"ProgressCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    @weakify(self)
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self)
        HKProgressView *progressView = [cell viewWithTag:101];
        progressView.titleArray = @[@"待支付",@"已支付",@"保单已出"];
        progressView.selectedIndexSet = [self selectedIndexSet];
    });
    return data;
}

// 保单状态cell
-(CKDict *)headCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"HeadCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    @weakify(self)
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self)
        UILabel * headLabel = [cell viewWithTag:100];
        headLabel.text = [self.order detailDescForCurrentStatus];
    });
    return data;
}

// 用户信息cell
-(CKList *)infoCellData
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(RACTuple *item in self.titles)
    {
        CKDict *data = [CKDict dictWith:@{kCKCellID:@"InfoCell"}];
        data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 25;
        });
        data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            UILabel *titleLabel = [cell viewWithTag:101];
            UILabel *detailLabel = [cell viewWithTag:102];
            HKArrowView * arrowView = [cell viewWithTag:103];
            UILabel *remarkLabel = [cell viewWithTag:20301];
            titleLabel.text = item.first;
            detailLabel.text = item.second;
            
            arrowView.hidden = YES;
            BOOL show = item.third;
            if (show)
            {
                arrowView.bgColor = kOrangeColor;
                arrowView.hidden = NO;
                remarkLabel.text = (NSString *)item.third;
            }
        });
        [array addObject:data];
    }
    return [CKList listWithArray:array];
}

// 服务项目标题cell
-(CKDict *)itemHeaderCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"ItemHeaderCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString * title = @"承保险种";
        NSString * detail = @"保险金额/责任限额（元）";
        CGFloat width = gAppMgr.deviceInfo.screenSize.width / 2 - 40;
        CGSize size1 = [title labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
        CGSize size2 = [detail labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
        // 20 = 10 + 10 文字和上下边界的距离
        CGFloat height = MAX(size1.height + 10, size2.height + 10);
        return height + 8;
    });
    return data;
}

// 服务项目cell
-(CKList *)itemCellData
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (SubInsurance *item in self.coverages)
    {
        CKDict *data = [CKDict dictWith:@{kCKCellID:@"ItemCell"}];
        data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            NSString * title = item.coveragerName;
            NSString * detail = item.coveragerValue;
            CGFloat width = gAppMgr.deviceInfo.screenSize.width / 2 - 40;
            CGSize size1 = [title labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
            CGSize size2 = [detail labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
            // 20 = 10 + 10 文字和上下边界的距离
            CGFloat height = MAX(MAX(size1.height + 20, size2.height + 20),30);
            return height;
            });
        data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            UILabel *titleLabel = [cell viewWithTag:102];
            UILabel *detailLabel = [cell viewWithTag:103];
            titleLabel.text = item.coveragerName;
            if ([item.coveragerValue isKindOfClass:[NSNumber class]])
            {
                detailLabel.text = [item.coveragerValue description];
            }
            else
            {
                detailLabel.text = item.coveragerValue;
            }
        });
        [array addObject:data];
    }
    return [CKList listWithArray:array];
}

// 锯齿cell
-(CKDict *)sawtoothCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"SawtoothCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    return data;
}

#pragma mark LazyLoad

-(void)reloadData
{
    self.dataSource = [CKList list];
    CKDict *progressData = [self progressCellData];
    CKDict *headerData = [self headCellData];
    CKList *infoData = [self infoCellData];
    CKDict *itemHeaderData = [self itemHeaderCellData];
    CKList *itemData = [self itemCellData];
    CKDict *sawtoothData = [self sawtoothCellData];
    [self.dataSource addObject:progressData forKey:@"progressData"];
    [self.dataSource addObject:headerData forKey:@"headerData"];
    [self.dataSource addObjectsFromQueue:infoData];
    [self.dataSource addObject:itemHeaderData forKey:@"itemHeaderData"];
    [self.dataSource addObjectsFromQueue:itemData];
    [self.dataSource addObject:sawtoothData forKey:@"sawtoothData"];
    [self.tableView reloadData];
}


#pragma mark Utility

-(NSIndexSet *)selectedIndexSet
{
    if (self.order.status == InsuranceOrderStatusComplete)
    {
        return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    }
    else if (self.order.status == InsuranceOrderStatusPaid)
    {
        return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    }
    else
    {
        return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    }
}

-(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    if (!_alert)
    {
        _alert = [[HKImageAlertVC alloc]init];
    }
    _alert.topTitle = topTitle;
    _alert.imageName = imageName;
    _alert.message = message;
    _alert.actionItems = actionItems;
    return _alert;
}


@end

