//
//  CarwashOrderDetailVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarwashOrderDetailVC.h"
#import "UIView+Layer.h"
#import "ShopDetailVC.h"
#import "CarwashOrderCommentVC.h"
#import "XiaoMa.h"

@interface CarwashOrderDetailVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *detailItems;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@end

@implementation CarwashOrderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadDatasource];
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

- (void)reloadDatasource
{
    self.commentBtn.hidden = (BOOL)self.order.ratetime;
    NSString *strpirce = [NSString stringWithFormat:@"%.2f", self.order.serviceprice];
    self.detailItems = @[RACTuplePack(@"服务项目：", self.order.servicename),
                         RACTuplePack(@"项目价格：", strpirce),
                         RACTuplePack(@"我的车辆：", self.order.licencenumber),
                         RACTuplePack(@"支付方式：", [self.order paymentForCurrentChannel]),
                         RACTuplePack(@"支付时间：", [self.order.txtime dateFormatForYYYYMMddHHmm])];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionComment:(id)sender
{
    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
    vc.order = self.order;
    [vc setCommentSuccess:^{
        [self reloadDatasource];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UITableViewDelegate and UITableViewDatasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.detailItems.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return indexPath.row == 0 ? 26 : 30;
    }
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
    else {
        [cell layoutBorderLineIfNeeded];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self shopCellAtIndexPath:indexPath];
    }
    else {
        cell = [self detailCellAtIndexPath:indexPath];
    }
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        ((JTTableViewCell *)cell).customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    }
    return cell;
}

#pragma mark - Cell
- (UITableViewCell *)shopCellAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
    JTShop *shop = self.order.shop;
    [[[gAppMgr.mediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defaultPic:@"cm_shop" errorPic:@"cm_shop"] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        logoV.image = x;
    }];
    titleL.text = shop.shopName;
    addrL.text = shop.shopAddress;

    return cell;
}

- (UITableViewCell *)detailCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *detailL = (UILabel *)[cell.contentView viewWithTag:1002];
    RACTuple *item = [self.detailItems safetyObjectAtIndex:indexPath.row];
    titleL.text = item.first;
    detailL.text = item.second;
    
    int lineMask = CKViewBorderDirectionNone;
    if (indexPath.row == 0) {
        lineMask |= CKViewBorderDirectionTop;
    }
    else if (indexPath.row >= self.detailItems.count-1) {
        lineMask |= CKViewBorderDirectionBottom;
    }
    [cell setBorderLineColor:kDefLineColor forDirectionMask:lineMask];
    [cell showBorderLineWithDirectionMask:lineMask];
    
    return cell;
}


@end
