//
//  MutualInsGrouponSubVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponSubVC.h"
#import "CKDatasource.h"
#import "MutualInsConstants.h"

#import "MutualInsGrouponCarsCell.h"
#import "HKProgressView.h"
#import "PullDownAnimationButton.h"
#import "WaterWaveProgressView.h"
#import "MutualInsAlertVC.h"

@interface MutualInsGrouponSubVC ()
@property (nonatomic, strong) CKList *allItems;
@property (nonatomic, strong) CKList *datasource;

@property (nonatomic, assign) MutInsStatus *status;
@property (nonatomic, assign) BOOL isExpanded;
@end

@implementation MutualInsGrouponSubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupItems];
    self.isExpanded = YES;
    [self reloadDataWithStatus:MutInsStatusToBePaid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupItems
{
    self.allItems = $([self carsItem], [self splitLine1Item], [self splitLine2Item], [self arrowItem],
                      [self waterWaveItem], [self descItem], [self timeItem], [self ButtonItem], [self bottomItem]);
}

#pragma mark - Reload
- (void)reloadDataWithStatus:(MutInsStatus)status
{
    CKList *items = self.allItems;
    CKList *datasource;
    if (status == MutInsStatusNeedDriveLicense || status == MutInsStatusNeedInsList) {
        datasource = $(items[@"Cars"],items[@"Line1"],items[@"Arrow"],items[@"Desc"],items[@"Time"],items[@"Button"],items[@"Bottom"]);
    }
    else if (status == MutInsStatusUnderReview || status == MutInsStatusReviewFailed || status == MutInsStatusNeedQuote) {
        datasource = $(items[@"Cars"],items[@"Line1"],items[@"Arrow"],items[@"Desc"],items[@"Time"],items[@"Bottom"]);
    }
    else if (status == MutInsStatusNeedReviewAgain || status == MutInsStatusAccountingPrice) {
        datasource = $(items[@"Cars"],items[@"Line1"],items[@"Arrow"],items[@"Desc"],items[@"Time"],items[@"Button"],items[@"Bottom"]);
    }
    else if (status == MutInsStatusToBePaid) {
        datasource = $(items[@"Cars"],items[@"Line2"],items[@"Arrow"],items[@"Wave"],
                       items[@"Desc"],items[@"Time"],items[@"Button"],items[@"Bottom"]);
    }
    else if (status == MutInsStatusPaidForSelf) {
        datasource = $(items[@"Cars"],items[@"Line2"],items[@"Wave"],items[@"Desc"],items[@"Time"],items[@"Bottom"]);
    }
    else {
        datasource = $(items[@"Cars"],items[@"Line2"],items[@"Wave"],items[@"Desc"],items[@"Bottom"]);
    }
    
    if (!self.isExpanded) {
        NSInteger i = [datasource indexOfObjectForKey:@"Desc"];
        CKList *trimedDatasource = [CKList list];
        for (; i < [datasource count]; i++) {
            [trimedDatasource addObject:datasource[i] forKey:nil];
        }
        self.datasource = trimedDatasource;
    }
    else {
        self.datasource = datasource;
    }

    [self.tableView reloadData];
}

#pragma mark - CellItem
- (CKDict *)carsItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Cars"}];
    @weakify(self);
    item[@"cars"] = @[@{@"title":@"浙A12345",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S117.png"},
                      @{@"title":@"浙A54892",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S119.png"},
                      @{@"title":@"浙A54892",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S119.png"},
                      @{@"title":@"浙A54892",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S119.png"},
                      @{@"title":@"浙A54892",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S119.png"},
                      @{@"title":@"浙A54892",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S119.png"},
                      @{@"title":@"浙A54892",@"img":@"http://7xjclc.com2.z0.glb.qiniucdn.com/S119.png"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 72;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        MutualInsGrouponCarsCell *cardsCell = (MutualInsGrouponCarsCell *)cell;
        [cardsCell setupWithCellBounds:CGRectMake(0, 0, self.tableView.frame.size.width, 72)];
        [cardsCell setCars:data[@"cars"]];
        [cardsCell setCarDidSelectedBlock:^(NSDictionary *info) {
            MutualInsAlertVC *alert = [[MutualInsAlertVC alloc] init];
            alert.topTitle = info[@"title"];
            alert.actionTitles = @[@"确定"];
            alert.items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:@"150****2977" detailColor:MutInsTextDarkGrayColor],
                            [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:@"奥迪A4L" detailColor:MutInsTextDarkGrayColor],
                            [MutualInsAlertVCItem itemWithTitle:@"互助资金" detailTitle:@"6800.00" detailColor:MutInsOrangeColor],
                            [MutualInsAlertVCItem itemWithTitle:@"所占比例" detailTitle:@"7.59%" detailColor:MutInsTextDarkGrayColor],
                            [MutualInsAlertVCItem itemWithTitle:@"目前可返" detailTitle:@"5688.00" detailColor:MutInsOrangeColor],
                            [MutualInsAlertVCItem itemWithTitle:@"出现次数" detailTitle:@"2次" detailColor:MutInsTextDarkGrayColor],
                            [MutualInsAlertVCItem itemWithTitle:@"理赔金额" detailTitle:@"2255.55" detailColor:MutInsOrangeColor]];
            [alert showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
                [alertView dismiss];
            }];
            
        }];
    });
    return item;
}

- (CKDict *)splitLine1Item
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Line1",@"amount":@"共25车"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 28;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        CKLine *lineV = [cell viewWithTag:1001];
        UIButton *amountB = [cell viewWithTag:1002];
        
        lineV.lineColor = MutInsLineColor;
        [amountB setTitle:[@" " append:item[@"amount"]] forState:UIControlStateNormal];
    });
    return item;
}

- (CKDict *)splitLine2Item
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Line2",@"time":@"2015.02.03-2016.07.03",@"amount":@"共25车"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 36;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        CKLine *lineV = [cell viewWithTag:1001];
        UIButton *timeB = [cell viewWithTag:1002];
        UIButton *amountB = [cell viewWithTag:1003];
        
        lineV.lineColor = MutInsLineColor;
        
        timeB.hidden = [item[@"time"] length] == 0;
        [timeB setTitle:[@" " append:item[@"time"]] forState:UIControlStateNormal];
        [amountB setTitle:[@" " append:item[@"amount"]] forState:UIControlStateNormal];
    });
    return item;
}

- (CKDict *)arrowItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Arrow"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *arrowV = [cell viewWithTag:1001];
        arrowV.normalTextColor = MutInsTextLightGrayColor;
        arrowV.normalColor = MutInsBgColor;
        arrowV.titleArray = @[@"上传",@"审核",@"报价",@"支付"];
        arrowV.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    });
    return item;
}

- (CKDict *)waterWaveItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Wave"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 168;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        WaterWaveProgressView *waveV = [cell viewWithTag:1001];
        
        waveV.titleLable.text = @"资金池";
        waveV.subTitleLabel.text = @"7865.85/12500.45";
        [waveV startWave];
        [waveV showArcLightOnce];
        [waveV setProgress:0.8 withAnimation:YES];
        //cell被重用的时候停止动画
        [[cell rac_prepareForReuseSignal] subscribeNext:^(id x) {
            [waveV stopWave];
        }];
    });
    return item;
}

- (CKDict *)descItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Desc",@"text":@"全部团员支付成功，组团结束。\n协议将于2016年3月1日生效"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return UITableViewAutomaticDimension;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *label = [cell viewWithTag:1001];
        label.text = data[@"text"];
    });
    return item;
}

- (CKDict *)timeItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Time",@"text":@" 组团剩余时间：21小时15分"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 26;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *timeB = [cell viewWithTag:1001];
        CKLine *leftL = [cell viewWithTag:1002];
        CKLine *rightL = [cell viewWithTag:1003];
        
        leftL.lineColor = MutInsGreenColor;
        rightL.lineColor = MutInsGreenColor;
        [timeB setTitle:data[@"text"] forState:UIControlStateNormal];
    });
    return item;
}

- (CKDict *)ButtonItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Button"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    return item;
}

- (CKDict *)bottomItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Bottom"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    item[kCKCellPrepare]= CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        PullDownAnimationButton *arrowV = [cell viewWithTag:1001];
        UIImageView *edgeV = [cell viewWithTag:1002];
        [arrowV setPulled:YES withAnimation:YES];
        if (!edgeV.image) {
            edgeV.image = [[UIImage imageNamed:@"mins_edge"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 8, 1)];
        }
    });
    return item;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [self.datasource objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight]) {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [self.datasource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKItemKey]];
    if (item[kCKCellPrepare]) {
        ((CKCellPrepareBlock)item[kCKCellPrepare])(item, cell, indexPath);
    }
    if ([cell isKindOfClass:[HKTableViewCell class]]) {
        HKTableViewCell *hkcell = (HKTableViewCell *)cell;
        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentVerticalLeft insets:UIEdgeInsetsZero];
        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentVerticalRight insets:UIEdgeInsetsZero];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [self.datasource objectAtIndex:indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}
@end
