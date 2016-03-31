//
//  InsranceOrderViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsranceOrderViewModel.h"
#import "XiaoMa.h"
#import "GetInsuranceOrderListOp.h"
#import "InsuranceOrderVC.h"
#import "PayForInsuranceVC.h"
#import "InsuranceStore.h"

@interface InsranceOrderViewModel ()<HKLoadingModelDelegate>
@property (nonatomic, strong) InsuranceStore *insStore;
@end

@implementation InsranceOrderViewModel 
- (void)dealloc
{
}

- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showBottomLoadingView = YES;
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
        [self setupInsStore];
        self.loadingModel.isSectionLoadMore = YES;
    }
    return self;
}

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
}

- (void)setupInsStore
{
    self.insStore = [InsuranceStore fetchOrCreateStore];
    @weakify(self);
    [self.insStore subscribeWithTarget:self domain:@"insOrders" receiver:^(CKStore *store, CKEvent *evt) {
        
        @strongify(self);
        RACSignal *sig = [[evt signal] map:^id(id value) {
            @strongify(self);
            return [self.insStore.insOrders allObjects];
        }];
        [self.loadingModel autoLoadDataFromSignal:sig];
    }];
}

#pragma mark - Action
- (void)actionMakeCall:(id)sender
{
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"咨询电话：4007-111-111"];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无保险订单";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取保险订单失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    [[[InsuranceStore fetchExistsStore] getAllInsOrders] send];
    return [RACSignal empty];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.loadingModel.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 178;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InsuranceCell" forIndexPath:indexPath];
    UILabel *nameL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *stateL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:2003];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:3002];
    UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:4001];
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:4000];
    
    imgView.layer.borderWidth = 0.5;
    imgView.layer.borderColor = HEXCOLOR(@"#888888").CGColor;
    HKInsuranceOrder *order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    nameL.text = order.inscomp;
//    nameL.text = [order descForCurrentInstype];
    contentL.text = order.serviceName;
//    contentL.text = [order generateContent];
    
    stateL.text = [order descForCurrentStatus]; //老方式，已经用新字段替换
    timeL.text = [order.lstupdatetime dateFormatForYYYYMMddHHmm2];
    priceL.text = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:order.fee]];
    
    BOOL unpaid = order.status == InsuranceOrderStatusUnpaid;
    [bottomB setTitle:unpaid ? @"买了" : @"联系客服" forState:UIControlStateNormal];
    
    bottomB.layer.borderColor = HEXCOLOR(@"#18d06a").CGColor;
    bottomB.layer.borderWidth = 0.5;
    
    
     @weakify(self);
    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
        @strongify(self);
         if (unpaid) {
             [MobClick event:@"rp318_6"];
             PayForInsuranceVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"PayForInsuranceVC"];
             vc.insOrder = order;
             vc.insModel = [[InsuranceVM alloc] init];
             vc.insModel.originVC = self.targetVC;
             [self.targetVC.navigationController pushViewController:vc animated:YES];
         }
         else {
             [MobClick event:@"rp318_5"];
             [self actionMakeCall:x];
         }
    }];
    cell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKInsuranceOrder * order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
    vc.order = order;
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
