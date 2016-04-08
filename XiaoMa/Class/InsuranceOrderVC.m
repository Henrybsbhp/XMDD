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
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
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
    UIColor *bgColor;
    SEL action;
    NSString *title;
    if (self.order.status == InsuranceOrderStatusUnpaid)
    {
        bgColor = HEXCOLOR(@"#ff7428");
        title = @"去支付";
        action = @selector(actionPay:);
    }
    else
    {
        bgColor = HEXCOLOR(@"#18d06a");
        title = @"联系客服";
        action = @selector(actionMakeCall:);
    }
    [self.bottomButton setBackgroundColor:bgColor];
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
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消订单" style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(actionCancelOrder:)];
        self.navigationItem.rightBarButtonItem = cancel;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
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
                       RACTuplePack(@"共计保费",amount,remark),
                       RACTuplePack(@"商业险期限",_order.validperiod)];
    NSMutableArray *titles = [NSMutableArray arrayWithArray:array];
    if (_order.insordernumber.length > 0) {
        [titles safetyInsertObject:RACTuplePack(@"保单编号",_order.insordernumber) atIndex:0];
    }
    if (_order.fvalidperiod.length > 0) {
        [titles safetyAddObject:RACTuplePack(@"交强险期限",_order.fvalidperiod)];
    }
    self.titles = titles;
    self.coverages = self.order.policy.subInsuranceArray;
    [self resetBottomButton];
    [self.tableView reloadData];
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

- (void)actionPay:(id)sender {
    [MobClick event:@"rp1012_2"];
    PayForInsuranceVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"PayForInsuranceVC"];
    vc.insModel = self.insModel;
    vc.insOrder = self.order;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCancelOrder:(id)sender {
    [MobClick event:@"rp1012_4"];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"算了吧" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
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
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
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

-(CKDict *)progressCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"ProgressCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 54;
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

-(CKDict *)headCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"HeadCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
    });
    @weakify(self)
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self)
        UILabel * headLabel = [cell viewWithTag:100];
        headLabel.text = [self.order detailDescForCurrentStatus];
    });
    return data;
}

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
                arrowView.bgColor = HEXCOLOR(@"#ff7428");
                arrowView.hidden = NO;
                remarkLabel.text = (NSString *)item.third;
            }
        });
        [array addObject:data];
    }
    return [CKList listWithArray:array];
}

-(CKDict *)itemHeaderCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"ItemHeaderCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString * title = @"服务项目";
        NSString * detail = @"保险金额/责任限额（元）";
        CGFloat width = gAppMgr.deviceInfo.screenSize.width / 2 - 40;
        CGSize size1 = [title labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
        CGSize size2 = [detail labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
        // 20 = 10 + 10 文字和上下边界的距离
        CGFloat height = MAX(size1.height + 10, size2.height + 10);
        return height;
    });
    return data;
}

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

-(CKDict *)sawtoothCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"SawtoothCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    return data;
}

#pragma mark LazyLoad

-(CKList *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [CKList list];
        CKDict *progressData = [self progressCellData];
        CKDict *headerData = [self headCellData];
        CKList *infoData = [self infoCellData];
        CKDict *itemHeaderData = [self itemHeaderCellData];
        CKList *itemData = [self itemCellData];
        CKDict *sawtoothData = [self sawtoothCellData];
        [_dataSource addObject:progressData forKey:@"progressData"];
        [_dataSource addObject:headerData forKey:@"headerData"];
        [_dataSource addObjectsFromQueue:infoData];
        [_dataSource addObject:itemHeaderData forKey:@"itemHeaderData"];
        [_dataSource addObjectsFromQueue:itemData];
        [_dataSource addObject:sawtoothData forKey:@"sawtoothData"];
    }
    return _dataSource;
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

