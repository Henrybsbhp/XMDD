//
//  InsranceOrderViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsranceOrderViewModel.h"
#import "Xmdd.h"
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
        self.loadingModel.isSectionLoadMore = YES;
        [self setupInsStore];
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
    [[self.insStore getAllInsOrders] send];
}

#pragma mark - Action
- (void)actionMakeCall:(id)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"咨询电话：4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无保险订单",@"image":@"def_withoutOrder"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取保险订单失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    return [RACSignal empty];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
}

- (void)loadingModel:(HKLoadingModel *)model didTappedForBlankPrompting:(NSString *)prompting type:(HKLoadingTypeMask)type
{
    [[self.insStore getAllInsOrders] send];
}

- (void)loadingModel:(HKLoadingModel *)model didTappedForErrorPrompting:(NSString *)prompting type:(HKLoadingTypeMask)type
{
    [[self.insStore getAllInsOrders] send];
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
    return 180;
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
    
    HKInsuranceOrder *order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    [imgView setImageByUrl:order.picUrl withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
    nameL.text = order.inscomp;
    
    contentL.adjustsFontSizeToFitWidth = YES;
    contentL.text = order.serviceName;
    
    stateL.text = [order descForCurrentStatus]; //老方式，已经用新字段替换
    timeL.text = [order.lstupdatetime dateFormatForYYYYMMddHHmm2];
    priceL.text = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:order.fee]];
    
    BOOL unpaid = order.status == InsuranceOrderStatusUnpaid;
    [bottomB setTitle:unpaid ? @"买了" : @"联系客服" forState:UIControlStateNormal];
    
    bottomB.layer.borderColor = kDefTintColor.CGColor;
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
