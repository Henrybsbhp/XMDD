//
//  MyOrderListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyOrderListVC.h"
#import "XiaoMa.h"
#import "GetCarwashOrderListOp.h"
#import "CarwashOrderDetailVC.h"
#import "CarwashOrderCommentVC.h"
#import "CarwashOrderViewModel.h"
#import "InsranceOrderViewModel.h"
#import "HKLoadingModel.h"

@interface MyOrderListVC ()

@property (weak, nonatomic) IBOutlet UIButton *washBtn;
@property (weak, nonatomic) IBOutlet UIButton *insranceBtn;
@property (weak, nonatomic) IBOutlet UIView *underLineView;
@property (weak, nonatomic) IBOutlet UIView *underLineView2;
@property (weak, nonatomic) IBOutlet JTTableView *carwashTableView;
@property (weak, nonatomic) IBOutlet JTTableView *insranceTableView;
@property (nonatomic, strong) CarwashOrderViewModel *carwashModel;
@property (nonatomic, strong) InsranceOrderViewModel *insuranceModel;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, assign) long long curTradetime;
@end

@implementation MyOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.carwashModel = [[CarwashOrderViewModel alloc] initWithTableView:self.carwashTableView];
    self.insuranceModel = [[InsranceOrderViewModel alloc] initWithTableView:self.insranceTableView];
    [self.carwashModel resetWithTargetVC:self];
    [self.insuranceModel resetWithTargetVC:self];
    [self.carwashModel.loadingModel loadDataForTheFirstTime];
    [self.insuranceModel.loadingModel loadDataForTheFirstTime];
    
    [[self.washBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.washBtn setTitleColor:[UIColor colorWithHex:@"#20ab2a" alpha:1.0f] forState:UIControlStateNormal];
        [self.insranceBtn setTitleColor:[UIColor colorWithHex:@"#4f5051" alpha:1.0f] forState:UIControlStateNormal];
        self.carwashTableView.hidden = NO;
        self.insranceTableView.hidden = YES;
        self.underLineView.backgroundColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
        self.underLineView2.backgroundColor = [UIColor whiteColor];
    }];
    [[self.insranceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.washBtn setTitleColor:[UIColor colorWithHex:@"#4f5051" alpha:1.0f] forState:UIControlStateNormal];
        [self.insranceBtn setTitleColor:[UIColor colorWithHex:@"#20ab2a" alpha:1.0f] forState:UIControlStateNormal];
        self.carwashTableView.hidden = YES;
        self.insranceTableView.hidden = NO;
        self.underLineView.backgroundColor = [UIColor whiteColor];
        self.underLineView2.backgroundColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp318"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"rp318"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

//#pragma mark - Action
//- (void)actionCommentForOrder:(HKServiceOrder *)order
//{
//    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
//    vc.order = order;
//    [vc setCustomActionBlock:^{
//        [self.loadingModel reloadData];
//    }];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//#pragma mark - HKLoadingModelDelegate
//- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
//{
//    return @"暂无订单";
//}
//
//- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
//{
//    return @"获取洗车订单失败，点击重试";
//}
//
//- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
//{
//    GetCarwashOrderListOp *op = [GetCarwashOrderListOp new];
//    long long tradetime = type == HKDatasourceLoadingTypeReloadData ? 0 : self.curTradetime;
//    op.req_tradetime = tradetime;
//    return [[op rac_postRequest] map:^id(GetCarwashOrderListOp *rspOp) {
//        return rspOp.rsp_orders;
//    }];
//}
//
//- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
//{
//    self.curTradetime = [[model.datasource lastObject] tradetime];
//    [self.tableView reloadData];
//}
//
//#pragma mark - UITableViewDelegate and UITableViewDatasource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return self.loadingModel.datasource.count;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 162;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 8;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CarwashCell" forIndexPath:indexPath];
//    UILabel *nameL = (UILabel *)[cell.contentView viewWithTag:1001];
//    UILabel *stateL = (UILabel *)[cell.contentView viewWithTag:1002];
//    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:2001];
//    UILabel *serviceL = (UILabel *)[cell.contentView viewWithTag:2002];
//    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:2003];
//    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:3002];
//    UILabel *paymentL = (UILabel *)[cell.contentView viewWithTag:3003];
//    UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:4001];
//    
//    HKServiceOrder *order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
//    
//    nameL.text = order.shop.shopName;
//    stateL.text = @"交易成功";
//    [[[gAppMgr.mediaMgr rac_getPictureForUrl:[order.shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defaultPic:@"cm_shop" errorPic:@"cm_shop"] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
//        iconV.image = x;
//    }];
//    
//    serviceL.text = order.servicename;
//    timeL.text = [order.txtime dateFormatForYYYYMMddHHmm];
//    priceL.text = [NSString stringWithFormat:@"￥%.2f", order.fee];
//    paymentL.text = [order paymentForCurrentChannel];
//    [[RACObserve(order, ratetime) takeUntilForCell:cell] subscribeNext:^(id x) {
//        [bottomB setTitle:order.ratetime ? @"已评价" : @"去评价" forState:UIControlStateNormal];
//        bottomB.enabled = !order.ratetime;
//    }];
//    @weakify(self);
//    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
//        
//        @strongify(self);
//        [self actionCommentForOrder:order];
//    }];
//    
//    cell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell isKindOfClass:[JTTableViewCell class]]) {
//        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
//    }
//    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
//    vc.order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
//    [self.navigationController pushViewController:vc animated:YES];
//}


@end
