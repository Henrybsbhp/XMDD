//
//  MutInsSystemGroupListVM.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsSystemGroupListVM.h"
#import "GetCooperationGroupOp.h"
#import "MutualInsConstants.h"

@interface MutInsSystemGroupListVM()<UITableViewDelegate,UITableViewDataSource>

@property (assign, nonatomic) GroupStatusType status;
@property (weak, nonatomic) MutInsSystemGroupListVC *targetVC;

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;

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
        if (self.status == GroupStatusTypeEnd)
        {
            self.targetVC.groupEndTable.hidden = YES;
        }
        else
        {
            self.targetVC.groupBeginTable.hidden = YES;
        }
        
        [self.targetVC.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }]subscribeNext:^(GetCooperationGroupOp *op) {
        
        @strongify(self)
        if (self.status == GroupStatusTypeEnd)
        {
            self.targetVC.groupEndTable.hidden = NO;
        }
        else
        {
            self.targetVC.groupBeginTable.hidden = NO;
        }
        [self.targetVC.view stopActivityAnimation];
        
        self.dataSource = op.rsp_groupList;
        [self.tableView reloadData];
        
    }error:^(NSError *error) {
        
        @strongify(self)
        [self.targetVC.view stopActivityAnimation];
        
        @weakify(self)
        [self.targetVC.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取团列表失败。请点击重试" tapBlock:^{
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
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *data = [self.dataSource safetyObjectAtIndex:indexPath.section];
    
    UILabel *groupNameLabel = [cell viewWithTag:100];
    groupNameLabel.text = [NSString stringWithFormat:@"%@",data[@"groupname"]];
    
    UILabel *totalCntLabel = [cell viewWithTag:101];
    NSNumber *totalcnt = data[@"totalcnt"];
    totalCntLabel.text = [NSString stringWithFormat:@"%ld",(long)totalcnt.integerValue];
    
    UIView *groupTagsView = [cell viewWithTag:102];
    [self configTagView:groupTagsView andTags:data[@"grouptags"]];
    
    UIView *groupDetailView = [cell viewWithTag:103];
    [self configDetailView:groupDetailView WithExtendinfo:data[@"extendinfo"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self.dataSource safetyObjectAtIndex:indexPath.section];
    NSArray *grouptags = data[@"grouptags"];
    NSArray *extendinfo = data[@"extendinfo"];
    CGFloat height = 30 + (grouptags.count == 0 ? 0 : 40) + 30 * extendinfo.count;
    return height;
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
    NSDictionary *data = [self.dataSource safetyObjectAtIndex:indexPath.section];
    NSNumber *showDetailFlag = data[@"showdetailflag"];
    if (showDetailFlag.integerValue == 1)
    {
        [self actionGotoGroupDetailVC:data[@"groupid"] andGroupName:data[@"groupname"]];
    }
    
}

#pragma mark - Utility

-(void)configDetailView:(UIView *)detailView WithExtendinfo:(NSArray *)extendinfo
{
    [detailView removeSubviews];
    NSLayoutConstraint *constraint = detailView.constraints.firstObject;
    constraint.constant = extendinfo.count * 17 + (extendinfo.count - 1) * 10;
    CGFloat height = 0;
    for (NSDictionary *dic in extendinfo)
    {
        UILabel *leftLabel = [[UILabel alloc]init];
        UILabel *rightLabel = [[UILabel alloc]init];
        
        leftLabel.numberOfLines = 0;
        rightLabel.numberOfLines = 0;
        
        [detailView addSubview:leftLabel];
        [detailView addSubview:rightLabel];
        
        leftLabel.font = [UIFont systemFontOfSize:13];
        leftLabel.textColor = HEXCOLOR(@"#888888");
        rightLabel.font = [UIFont systemFontOfSize:13];
        rightLabel.textColor = HEXCOLOR(@"#888888");
        
        leftLabel.text = [NSString stringWithFormat:@"%@",dic.allKeys.firstObject];
        rightLabel.text = [NSString stringWithFormat:@"%@",dic.allValues.firstObject];
        
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height);
            make.left.mas_equalTo(15);
        }];
        
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height);
            make.right.mas_equalTo(-15);
        }];
        
        height += 25;
        
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
}


- (void)actionGotoGroupDetailVC:(NSNumber *)groupID andGroupName:(NSString *)groupName
{
    CKRouter *router = [CKRouter routerWithViewControllerName:@"MutualInsGroupDetailVC"];
    router.userInfo = [[CKDict alloc] init];
    router.userInfo[kMutInsGroupID] = groupID;
    router.userInfo[kMutInsGroupName] = groupName;
    [self.targetVC.router.navigationController pushRouter:router animated:YES];
}

@end
