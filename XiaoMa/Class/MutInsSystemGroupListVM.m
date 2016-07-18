//
//  MutInsSystemGroupListVM.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsSystemGroupListVM.h"
#import "GetCooperationGroupOp.h"
#import "NSString+RectSize.h"
#import "MutualInsConstants.h"

@interface MutInsSystemGroupListVM()<UITableViewDelegate,UITableViewDataSource>

@property (assign, nonatomic) GroupStatusType status;
@property (weak, nonatomic) MutInsSystemGroupListVC *targetVC;

@property (strong, nonatomic) CKList *dataSource;
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic)BOOL isShowdetailflag;

@end

@implementation MutInsSystemGroupListVM

-(void)dealloc
{
    DebugLog(@"MutInsSystemGroupListVM dealloc");
}

-(id)initWithTableView:(UITableView *)tableView andType:(GroupStatusType)groupStatusType andTargetVC:(MutInsSystemGroupListVC *)groupListVC
{
    if (self = [super init])
    {
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.tableView = tableView;
        self.status = groupStatusType;
        self.targetVC = groupListVC;
//        []
    }
    return self;
}

#pragma mark - Network

- (void)getCooperationGroupList
{
    GetCooperationGroupOp *op = [GetCooperationGroupOp operation];
    op.req_status = @(self.status);
    
    @weakify(self)
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        self.targetVC.groupEndTable.hidden = YES;
        self.targetVC.groupBeginTable.hidden = YES;
        self.targetVC.applyBtn.enabled = NO;
        self.targetVC.groupEndBtn.enabled = NO;
        self.targetVC.groupBeginBtn.enabled = NO;
        
        [self.targetVC.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }]subscribeNext:^(GetCooperationGroupOp *op) {
        
        self.targetVC.groupEndTable.hidden = NO;
        self.targetVC.groupBeginTable.hidden = NO;
        self.targetVC.applyBtn.enabled = YES;
        self.targetVC.groupEndBtn.enabled = YES;
        self.targetVC.groupBeginBtn.enabled = YES;
    
        
        [self configDataSourceWithGroupList:op.rsp_groupList];
        [self.tableView reloadData];
        
        [self.targetVC.view stopActivityAnimation];
        
    }error:^(NSError *error) {
        
        @strongify(self)
        [self.targetVC.view stopActivityAnimation];
        
        [self.tableView showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取团列表失败。请点击重试" tapBlock:^{
            @strongify(self)
            [self getCooperationGroupList];
        }];
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *cellList = self.dataSource[section];
    return cellList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID]];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block)
    {
        block(item, cell, indexPath);
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight])
    {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.dataSource.count - 1)
    {
        return 8;
    }
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block)
    {
        block(data, indexPath);
    }
}

#pragma mark - CellData

-(CKDict *)titleCellDataWithDic:(NSDictionary *)dic
{
    @weakify(self)
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"TitleCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 85;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
            UILabel *groupNameLabel = [cell viewWithTag:100];
            groupNameLabel.text = [NSString stringWithFormat:@"%@",dic[@"groupname"]];
        
            UILabel *totalCntLabel = [cell viewWithTag:101];
            NSNumber *totalcnt = dic[@"totalcnt"];
            totalCntLabel.text = [NSString stringWithFormat:@"%ld",(long)totalcnt.integerValue];
        
            UIView *groupTagsView = [cell viewWithTag:102];
            [self configTagView:groupTagsView andTags:dic[@"grouptags"]];
        
    });
    return data;
}

-(CKDict *)detailCellDataWithDic:(NSDictionary *)dic
{
    @weakify(self)
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"DetailCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        NSString *valueStr = [NSString stringWithFormat:@"%@",dic.allValues.firstObject];
        NSString *keyStr = [NSString stringWithFormat:@"%@",dic.allKeys.firstObject];
        CGSize keyStrSize = [keyStr labelSizeWithWidth:100 font:[UIFont systemFontOfSize:13]];
        CGSize valueStrSize = [valueStr labelSizeWithWidth:self.tableView.frame.size.width - 100 font:[UIFont systemFontOfSize:13]];
        
        return MAX(ceil(keyStrSize.height + 10), (valueStrSize.height + 10));
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        UILabel *leftLabel = [cell viewWithTag:100];
        leftLabel.text = [NSString stringWithFormat:@"%@",dic.allKeys.firstObject];
        
        UILabel *rightLabel = [cell viewWithTag:101];
        rightLabel.text = [NSString stringWithFormat:@"%@",dic.allValues.firstObject];
        
    });
    return data;
}

-(CKDict *)blankCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"BlankCell"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 10;
    });
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    return data;
}

#pragma mark - Utility

-(void)configDataSourceWithGroupList:(NSArray *)groupList
{
    
    self.dataSource = [CKList list];
    
    for (NSDictionary *dic in groupList)
    {
        CKList *tempList = [CKList list];
        [tempList addObject:[self titleCellDataWithDic:dic] forKey:nil];
        for (NSDictionary *extendinfo in dic[@"extendinfo"])
        {
            [tempList addObject:[self detailCellDataWithDic:extendinfo] forKey:nil];
        }
        [tempList addObject:[self blankCellData] forKey:nil];
        [self.dataSource addObject:tempList forKey:nil];
    }
}

-(void)configTagView:(UIView *)groupTagsView andTags:(NSArray *)grouptags
{
    UILabel *tagOne = [groupTagsView viewWithTag:10200];
    UILabel *tagTwo = [groupTagsView viewWithTag:10201];
    UILabel *tagThree = [groupTagsView viewWithTag:10202];
    [self addCornerToTagLabel:tagOne];
    [self addCornerToTagLabel:tagTwo];
    [self addCornerToTagLabel:tagThree];
    if (grouptags.count == 0)
    {
        groupTagsView.hidden = YES;
    }
    else
    {
        groupTagsView.hidden = NO;
        switch (grouptags.count)
        {
            case 1:
                tagOne.hidden = NO;
                tagTwo.hidden = YES;
                tagThree.hidden = YES;
                tagOne.text = [NSString stringWithFormat:@"  %@  ",[grouptags safetyObjectAtIndex:0]];
                break;
            case 2:
                tagOne.hidden = NO;
                tagTwo.hidden = NO;
                tagThree.hidden = YES;
                tagOne.text = [NSString stringWithFormat:@"  %@  ",[grouptags safetyObjectAtIndex:0]];
                tagTwo.text = [NSString stringWithFormat:@"  %@  ",[grouptags safetyObjectAtIndex:1]];
                break;
            case 3:
                tagOne.hidden = NO;
                tagTwo.hidden = NO;
                tagThree.hidden = NO;
                tagOne.text = [NSString stringWithFormat:@"  %@  ",[grouptags safetyObjectAtIndex:0]];
                tagTwo.text = [NSString stringWithFormat:@"  %@  ",[grouptags safetyObjectAtIndex:1]];
                tagThree.text = [NSString stringWithFormat:@"  %@  ",[grouptags safetyObjectAtIndex:2]];
                break;
        }
    }
}

-(void)addCornerToTagLabel:(UILabel *)label
{
    label.layer.cornerRadius = 8.5;
    label.layer.borderColor = HEXCOLOR(@"#FF7428").CGColor;
    label.layer.borderWidth = 1;
    label.layer.shouldRasterize = YES;
}

@end
