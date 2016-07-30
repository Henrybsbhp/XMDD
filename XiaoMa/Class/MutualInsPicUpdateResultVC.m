//
//  MutualInsPicUpdateResultVC.m
//  XiaoMa
//
//  Created by fuqi on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPicUpdateResultVC.h"
#import "NSString+RectSize.h"
#import "MutualInsGroupDetailVC.h"

#define KUpdateSuccessSubTitle @"我们会尽快审核，审核通过且成功支付后，将获得如下权益"

@interface MutualInsPicUpdateResultVC()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)CKList * datasource;

@end

@implementation MutualInsPicUpdateResultVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsPicUpdateResultVC dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"提交成功";
    self.tableView.backgroundColor = kBackgroundColor;
    [self setupNavigationBar];
    
    [self setupDatasource];
    [self.tableView reloadData];
}

#pragma mark - Setup
- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupDatasource
{
    CKDict * cell0 = [CKDict dictWith:@{kCKCellID:@"TitleCell"}];
    cell0[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        CGSize size = [KUpdateSuccessSubTitle labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 40 font:[UIFont systemFontOfSize:14]];
        CGFloat height = 27 + 20 + 27 + size.height + 27;
        return height;
    });
    cell0[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * lb = [cell viewWithTag:102];
        lb.text = KUpdateSuccessSubTitle;
        
        CGSize size = [KUpdateSuccessSubTitle labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 40 font:[UIFont systemFontOfSize:14]];
        CGSize singleSize = [@"我" labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 40 font:[UIFont systemFontOfSize:14]];
        
        if (size.height > singleSize.height)
        {
            lb.textAlignment = NSTextAlignmentLeft;
        }
        else
        {
            lb.textAlignment = NSTextAlignmentCenter;
        }
    });
    
    CKList * tipList = [self getTipsInfoWithData:self.tipsDict];
    
    
    self.datasource = $($(cell0));
    [self.datasource addObject:tipList forKey:nil];
}

- (CKDict *)setupTipsHeaderCell
{
    CKDict *tipsHeaderCell = [CKDict dictWith:@{kCKItemKey: @"tipsHeaderCell", kCKCellID: @"TipsHeaderCell"}];
    tipsHeaderCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    
    tipsHeaderCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return tipsHeaderCell;
}

- (CKDict *)setupTipsTitleCellWithText:(NSString *)title
{
    CKDict *tipsTitleCell = [CKDict dictWith:@{kCKItemKey: @"tipsTitleCell", kCKCellID: @"TipsTitleCell"}];
    tipsTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
    });
    
    tipsTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        if ([title isEqualToString:@"保障"]) {
            UIImage *image = [UIImage imageNamed:@"mins_ensure"];
            imageView.image = image;
        } else if ([title isEqualToString:@"福利"]) {
            UIImage *image = [UIImage imageNamed:@"mins_benefit"];
            imageView.image = image;
        } else {
            UIImage *image = [UIImage imageNamed:@"mins_activity"];
            imageView.image = image;
        }
        
        titleLabel.text = title;
    });
    
    return tipsTitleCell;
}

- (CKDict *)setupTipsCellWithCouponList:(NSArray *)couponList
{
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 22;
    });
    
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *firstImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UIImageView *secondImageView = (UIImageView *)[cell.contentView viewWithTag:103];
        UILabel *firstTipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *secondTipsLabel = (UILabel *)[cell.contentView viewWithTag:104];
        NSString *firstString = couponList[0];
        if (firstString.length > 0) {
            firstImageView.hidden = NO;
            firstTipsLabel.text = firstString;
        }
        
        if (couponList.count > 1) {
            NSString *secondString = couponList[1];
            secondImageView.hidden = NO;
            secondTipsLabel.text = secondString;
        } else {
            secondImageView.hidden = YES;
            secondTipsLabel.text = @"";
        }
    });
    
    return tipsCell;
}

- (CKDict *)setupSingleTipsCellWithCouponString:(NSString *)couponString
{
    CKDict *singleTipsCell = [CKDict dictWith:@{kCKItemKey: @"singleTipsCell", kCKCellID: @"SingleTipsCell"}];
    singleTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [couponString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 93 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 22);
        
        return height;
    });
    
    singleTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        tipsLabel.text = couponString;
    });
    
    return singleTipsCell;
}

- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"blankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 15;
    });
    
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"tijiaochenggong" attributes:@{@"tijiaochenggong":@"tijiaochenggong1"}];
    
    if (self.router.userInfo[kOriginRoute]) {
        UIViewController *vc = [self.router.userInfo[kOriginRoute] targetViewController];
        [self.router.navigationController popToViewController:vc animated:YES];
    }
    else {
        NSInteger rootIndex = [self.router.navigationController.routerList indexOfObjectForKey:@"MutualInsVC"];
        rootIndex = rootIndex == NSNotFound ? 0 : rootIndex;
        //如果有成员id，需要返回到团详情（新建一个团详情并插入）
        if ([self.router.userInfo[kMutInsMemberID] integerValue] > 0 &&
            [self.router.userInfo[kMutInsGroupID] integerValue] > 0) {
            MutualInsGroupDetailVC *vc = [[MutualInsGroupDetailVC alloc] init];
            vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
            [self.router.navigationController.routerList insertObject:vc.router withKey:vc.router.key atIndex:rootIndex+1];
            [self.router.navigationController updateViewControllersByRouterList];
            [self.router.navigationController popToViewController:vc animated:YES];
        }
        else {
            [self.router.navigationController popToViewControllerAtIndex:rootIndex animated:YES];
        }
    }
}

#pragma mark - Utilitly
- (CKList *)getTipsInfoWithData:(NSDictionary *)data
{
    CKList * list = [CKList list];
    NSArray *insuranceList = data[@"insurancelist"];
    if (insuranceList.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:insuranceList];
        CKDict *tipsHeaderCell = [self setupTipsHeaderCell];
        CKDict *insuranceTitleCell = [self setupTipsTitleCellWithText:@"保障"];
        [list addObject:tipsHeaderCell forKey:nil];
        [list addObject:insuranceTitleCell forKey:nil];
        for (NSArray *array in newArray) {
            
            CKDict * couponCell;
            if (array.count == 2)
            {
                couponCell = [self setupTipsCellWithCouponList:array];
            }
            else
            {
                couponCell = [self setupSingleTipsCellWithCouponString:array.firstObject];
            }
            
            [list addObject:couponCell forKey:nil];
        }
    }
    
    NSArray *couponList = data[@"couponlist"];
    if (data.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:couponList];
        CKDict *couponTitleCell = [self setupTipsTitleCellWithText:@"福利"];
        [list addObject:couponTitleCell forKey:nil];
        for (NSArray *array in newArray) {
            
            CKDict * couponCell;
            if (array.count == 2)
            {
                couponCell = [self setupTipsCellWithCouponList:array];
            }
            else
            {
                couponCell = [self setupSingleTipsCellWithCouponString:array.firstObject];
            }
            
            [list addObject:couponCell forKey:nil];
        }
    }
    
    NSArray *activityList = data[@"activitylist"];
    if (activityList.count > 0) {
        CKDict *activityCell = [self setupTipsTitleCellWithText:@"活动"];
        [list addObject:activityCell forKey:nil];
        for (NSString *string in activityList) {
            
            CKDict *activityCell = [self setupSingleTipsCellWithCouponString:string];
            [list addObject:activityCell forKey:nil];
        }
    }
    
    return list;
}


- (NSMutableArray *)splitArrayIntoDoubleNewArray:(NSArray *)array
{
    // Create our array of arrays
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    // Loop through all of the elements using a for loop
    for (int a = 0; a < array.count / 2 + 1; a++) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (a * 2 < array.count) {
            id obj = [array objectAtIndex:a * 2];
            [tempArray addObject:obj];
        }
        
        if (a * 2 + 1 < array.count) {
            id obj2 = [array objectAtIndex:a * 2 + 1];
            [tempArray addObject:obj2];
        }
        
        [newArray addObject:tempArray];
    }
    
    return newArray;
}




#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource objectAtIndex:section] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        block(data, indexPath);
    }
}


@end
