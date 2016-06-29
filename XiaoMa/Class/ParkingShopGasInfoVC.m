//
//  ParkingShopGasInfoVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 6/28/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "ParkingShopGasInfoVC.h"
#import "NSString+RectSize.h"
#import "GetParkingShopGasInfoOp.h"

@interface ParkingShopGasInfoVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *fetchedDataArray;
@property (nonatomic, strong) CKList *dataSource;

@property (nonatomic, strong) NSNumber *pageNo;

@end

@implementation ParkingShopGasInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Obtain data
- (void)setDataSource
{
    self.dataSource = [CKList list];
    NSMutableArray *dataArray = [NSMutableArray new];
    for (NSDictionary *dict in self.fetchedDataArray) {
        
        CKList *dataList = [CKList list];
        
        NSString *nameString = dict[@"name"];
        if (nameString.length > 0) {
            CKDict *titleCell = [self setupTitleCellCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[titleCell]];
        }
        
        NSString *carBrandString = dict[@"carrefname"];
        if (carBrandString.length > 0) {
            CKDict *carBrandCell = [self setupCarBrandCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[carBrandCell]];
        }
        
        NSString *addressString = dict[@"address"];
        if (addressString.length > 0) {
            CKDict *addressCell = [self setupAddressInfoCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[addressCell]];
        }
        
        NSString *callNumberString = dict[@"contactphones"];
        if (callNumberString.length > 0) {
            CKDict *callNumberCell = [self setupCallNumberCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[callNumberCell]];
        }
        
        if (self.searchType.integerValue == 2 || self.searchType.integerValue == 3) {
            CKDict *navigationCallCell = [self setupNavigationCallCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[navigationCallCell]];
        } else {
            CKDict *navigationCell = [self setupNavigationCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[navigationCell]];
        }
        
        [dataArray addObject:dataList];
    }
    self.dataSource = [CKList listWithArray:dataArray];
}

#pragma mark - The settings of cells
- (CKDict *)setupTitleCellCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *titleCell = [CKDict dictWith:@{kCKItemKey:@"titleCell", kCKCellID:@"TitleCell"}];
    
    titleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    
    titleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        
        titleLabel.text = @"浙江五菱汽车销售服务有限公司";
    });
    
    return titleCell;
}

- (CKDict *)setupCarBrandCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *detailInfoCell = [CKDict dictWith:@{kCKItemKey:@"detailInfoCell", kCKCellID:@"DetailInfoCell"}];
    
    detailInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *string = @"你们不要搞个大新闻，再把我批判一番，说我钦点。我作为一个长者要教你们一点人生的经验，我那是见多识广，西方什么国家我没去过啊？美国的那个记者，华莱士，那比你们可高明多了，我和他谈笑风生。";
        CGSize size = [string labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 126 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 28);
        return height;
    });
    
    detailInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        infoLabel.text = @"你们不要搞个大新闻，再把我批判一番，说我钦点。我作为一个长者要教你们一点人生的经验，我那是见多识广，西方什么国家我没去过啊？美国的那个记者，华莱士，那比你们可高明多了，我和他谈笑风生。";
    });
    
    return detailInfoCell;
}

- (CKDict *)setupAddressInfoCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *detailInfoCell = [CKDict dictWith:@{kCKItemKey:@"detailInfoCell", kCKCellID:@"DetailInfoCell"}];
    
    detailInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *string = @"你们不要搞个大新闻，再把我批判一番，说我钦点。我作为一个长者要教你们一点人生的经验，我那是见多识广，西方什么国家我没去过啊？美国的那个记者，华莱士，那比你们可高明多了，我和他谈笑风生。";
        CGSize size = [string labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 126 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 28);
        return height;
    });
    
    detailInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        infoLabel.text = @"你们不要搞个大新闻，再把我批判一番，说我钦点。我作为一个长者要教你们一点人生的经验，我那是见多识广，西方什么国家我没去过啊？美国的那个记者，华莱士，那比你们可高明多了，我和他谈笑风生。";
    });
    
    return detailInfoCell;
}

- (CKDict *)setupCallNumberCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *detailInfoCell = [CKDict dictWith:@{kCKItemKey:@"detailInfoCell", kCKCellID:@"DetailInfoCell"}];
    
    detailInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *string = @"你们不要搞个大新闻，再把我批判一番，说我钦点。我作为一个长者要教你们一点人生的经验，我那是见多识广，西方什么国家我没去过啊？美国的那个记者，华莱士，那比你们可高明多了，我和他谈笑风生。";
        CGSize size = [string labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 126 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 28);
        return height;
    });
    
    detailInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        infoLabel.text = @"你们不要搞个大新闻，再把我批判一番，说我钦点。我作为一个长者要教你们一点人生的经验，我那是见多识广，西方什么国家我没去过啊？美国的那个记者，华莱士，那比你们可高明多了，我和他谈笑风生。";
    });
    
    return detailInfoCell;
}

- (CKDict *)setupNavigationCallCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *navigationCallCell = [CKDict dictWith:@{kCKItemKey:@"navigationCallCell", kCKCellID:@"NavigationCallCell"}];
    
    navigationCallCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 59;
    });
    
    navigationCallCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *navigationButton = (UIButton *)[cell.contentView viewWithTag:100];
        UIButton *callButton = (UIButton *)[cell.contentView viewWithTag:101];
    });
    
    return navigationCallCell;
}

- (CKDict *)setupNavigationCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *navigationCell = [CKDict dictWith:@{kCKItemKey:@"navigationCell", kCKCellID:@"NavigationCell"}];
    
    navigationCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 59;
    });
    
    navigationCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *navigationButton = (UIButton *)[cell.contentView viewWithTag:100];
    });
    
    return navigationCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

@end
