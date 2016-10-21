//
//  GeneralTableViewVM.m
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GeneralTableViewVM.h"

@interface GeneralTableViewVM ()

@end

@implementation GeneralTableViewVM

#pragma mark - UITableViewDelegate & UITableViewDataSource
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight]) {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    id cellid = item[kCKCellID] ? item[kCKCellID] : item[kCKItemKey];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (item[kCKCellPrepare]) {
        ((CKCellPrepareBlock)item[kCKCellPrepare])(item, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    if (item[kCKCellWillDisplay]) {
        ((CKCellWillDisplayBlock)item[kCKCellWillDisplay])(item, cell, indexPath);
    }
}

@end
