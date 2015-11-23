//
//  OthersOrderViewModel.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/13.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "OthersOrderViewModel.h"
#import "GetOtherOrderListOp.h"
#import "NSDate+DateForText.h"
#import "DetailWebVC.h"


@interface OthersOrderViewModel ()<HKLoadingModelDelegate>

@property (nonatomic, assign) long long curPayedtime;

@end

@implementation OthersOrderViewModel

- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showBottomLoadingView = YES;
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    }
    return self;
}

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无其他订单";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取其他订单失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        self.curPayedtime = 0;
    }
    
    GetOtherOrderListOp * op = [GetOtherOrderListOp operation];
    op.req_payedtime = self.curPayedtime;
    return [[op rac_postRequest] map:^id(GetOtherOrderListOp *rspOp) {
        return rspOp.rsp_orders;
    }];
    return nil;
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    HKOtherOrder * hkmodel = [model.datasource lastObject];
    self.curPayedtime = hkmodel.payedTime;
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
    return 195;
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
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
    UILabel *nameL = (UILabel *)[cell.contentView viewWithTag:1001];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:2001];
    UILabel *descL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *originPriceL = (UILabel *)[cell.contentView viewWithTag:3001];
    UILabel *couponPriceL = (UILabel *)[cell.contentView viewWithTag:3002];
    UILabel *feeL = (UILabel *)[cell.contentView viewWithTag:3003];
    UILabel *payedTimeL = (UILabel *)[cell.contentView viewWithTag:4001];
    UILabel *tradeTypeL = (UILabel *)[cell.contentView viewWithTag:4002];
    
    HKOtherOrder * order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    nameL.text = order.prodName;
    [iconV setImageByUrl:order.prodLogo withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    descL.text = order.prodDesc;
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:order.originPrice];
    [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, order.originPrice.length)];
    originPriceL.text = nil;
    originPriceL.attributedText = attributedString;
    couponPriceL.text = order.couponPrice;
    
    NSDictionary * attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont boldSystemFontOfSize:14.0], NSFontAttributeName,
                                   [UIColor colorWithHex:@"#353535" alpha:1.0f], NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attriFee = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"实付￥%@", order.fee ? [NSString formatForPrice:order.fee] : @"-"]];
    [attriFee addAttributes:attributeDic range:NSMakeRange(0, 2)];
    feeL.text = nil;
    feeL.attributedText = attriFee;
    
    payedTimeL.text = [[NSDate dateWithTimeIntervalSince1970:order.payedTime/1000] dateFormatForYYYYMMddHHmm2];
    
    tradeTypeL.text = order.payDesc;
    
    cell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKOtherOrder * order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"订单详情";
    vc.url = [OrderDetailsUrl stringByAppendingString:[NSString stringWithFormat:@"?token=%@&oid=%ld&tradetype=%@",gNetworkMgr.token ,(long)order.oId, order.tradeType]];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
