//
//  MutualInsGrouponSubMsgVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponSubMsgVC.h"
#import "CKDatasource.h"
#import "MutualInsMemberInfo.h"

#import "MutualInsGrouponMsgCell.h"

@interface MutualInsGrouponSubMsgVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKList *datasource;
@end

@implementation MutualInsGrouponSubMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reload
- (void)reloadData
{
    @weakify(self);
    NSArray *items = [self.groupMembers arrayByMappingOperator:^id(MutualInsMemberInfo *info) {
        @strongify(self);
        return [self messageItemWithInfo:info];
    }];
    self.datasource = [CKList listWithArray:items];
    [self.tableView reloadData];
}

#pragma mark - CellItem
- (CKDict *)messageItemWithInfo:(MutualInsMemberInfo *)info {
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Message", @"left":@(![info.memberid isEqual:self.group.memberId]),
                                      @"img":info.brandurl, @"title":info.licensenumber, @"msg":info.statusdesc}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CGFloat height;
        if (data[@"height"]) {
            height = [data[@"height"] floatValue];
        }
        else {
            height = [MutualInsGrouponMsgCell heightWithBoundsWidth:self.view.frame.size.width message:data[@"msg"]];
            data[@"height"] = @(height);
        }
        return height;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        MutualInsGrouponMsgCell *msgcell = (MutualInsGrouponMsgCell *)cell;
        msgcell.atRightSide = ![data[@"left"] boolValue];
        msgcell.titleLabel.text = data[@"title"];
        [msgcell.logoView setImageByUrl:data[@"img"] withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
        msgcell.message = data[@"msg"];
        [msgcell setNeedsUpdateConstraints];
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
