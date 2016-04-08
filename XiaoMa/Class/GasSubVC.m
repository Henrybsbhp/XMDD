//
//  GasSubVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasSubVC.h"

@interface GasSubVC ()
@property (nonatomic, strong) CKList *loadingDatasource;
@property (nonatomic, strong) CKList *curDatasource;

@end

@implementation GasSubVC

- (instancetype)initWithTargetVC:(UIViewController *)vc tableView:(UITableView *)table
                    bottomButton:(UIButton *)btn bottomView:(UIView *)bottomView
{
    self = [super init];
    if (self) {
        _tableView = table;
        _bottomBtn = btn;
        _targetVC = vc;
        _bottomView = bottomView;
        [self setupLoadingDatasource];
    }
    return self;
}

#pragma mark - Override
- (void)reloadData {
    
}

- (void)actionPay {
    
}

- (void)reloadBottomButton {
    
}

- (BOOL)reloadDataIfNeeded {
    return YES;
}

#pragma mark - Public
- (void)refreshViewWithForce:(BOOL)force {
    if (![self isEqual:self.tableView.delegate]) {
        return;
    }
    CKList *oldDatasource = self.curDatasource;
    CKDict *loadingItem = self.loadingDatasource[0][@"Loading"];
    BOOL loading = [loadingItem[@"loading"] boolValue];
    BOOL hasError = [loadingItem[@"error"] boolValue];
    if (loading || hasError) {
        self.curDatasource = self.loadingDatasource;
    }
    else {
        self.curDatasource = self.datasource;
    }
    if (force || ![oldDatasource isEqual:self.curDatasource]) {
        [self.tableView reloadData];
    }

    if (loading) {
        [self.tableView setContentOffset:CGPointZero];
    }
    self.tableView.scrollEnabled = !loading;
    self.bottomView.hidden = loading || hasError;
    [self reloadBottomButton];
}

- (void)reloadFromSignal:(RACSignal *)signal
{
    CKDict *loadingItem = self.loadingDatasource[0][@"Loading"];
    __block BOOL triggered = NO;
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        //如果没在刷新
        if (![loadingItem[@"loading"] boolValue]) {
            loadingItem[@"loading"] = @YES;
            [self refreshViewWithForce:NO];
        }
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        triggered = YES;
        if ([self reloadDataIfNeeded]) {
            //如果需要重新加载，停止刷新
            loadingItem[@"loading"] = @NO;
            loadingItem[@"error"] = @NO;
            loadingItem.forceReload = !loadingItem.forceReload;
            [self refreshViewWithForce:NO];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        triggered = YES;
        loadingItem[@"loading"] = @NO;
        loadingItem[@"error"] = @YES;
        loadingItem.forceReload = !loadingItem.forceReload;
        [self refreshViewWithForce:YES];
    } completed:^{
        
        @strongify(self);
        //如果没有触发任何事件，表示该信号需要被忽略
        if (!triggered && [self reloadDataIfNeeded]) {
            //如果需要重新加载，停止刷新
            loadingItem[@"loading"] = @NO;
            loadingItem[@"error"] = @NO;
            loadingItem.forceReload = !loadingItem.forceReload;
            [self refreshViewWithForce:NO];
        }
    }];
}

- (NSString *)recentlyUsedGasCardKey
{
    if (!gAppMgr.myUser) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@.%@", gAppMgr.myUser.userID, @"recentlyUsedGasCard"];
}

#pragma mark - Private
- (void)setupLoadingDatasource {
    self.loadingDatasource = $($([self loadingItem]));
}

#pragma mark - CellItem
///空白刷新（包括刷新失败）
- (CKDict *)loadingItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Loading"}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        return [self heightForLoadingCell];
    });
    
    item[kCKCellWillDisplay] = CKCellWillDisplay(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        if ([data[@"loading"] boolValue]) {
            [cell.contentView hideDefaultEmptyView];
            CGPoint position = CGPointMake(self.tableView.frame.size.width/2, [self heightForLoadingCell]/2);
            [cell.contentView startActivityAnimationWithType:GifActivityIndicatorType atPositon:position];
        }
        if ([data[@"error"] boolValue]) {
            [cell.contentView stopActivityAnimation];
            [cell.contentView showDefaultEmptyViewWithText:@"刷新失败，点击重试" tapBlock:^{
                [self reloadData];
            }];
        }
    });
    
    return item;
}

- (CGFloat)heightForLoadingCell
{
    return self.tableView.frame.size.height - self.tableView.tableHeaderView.frame.size.height + self.bottomBtn.superview.frame.size.height;
}

#pragma mark - RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [MobClick event:@"rp501_8"];
    [gAppMgr.navModel pushToViewControllerByUrl:[url absoluteString]];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.curDatasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.curDatasource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.curDatasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight]) {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.curDatasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKItemKey]];
    if (item[kCKCellPrepare]) {
        ((CKCellPrepareBlock)item[kCKCellPrepare])(item, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.curDatasource[indexPath.section][indexPath.row];
    if (item[kCKCellWillDisplay]) {
        ((CKCellWillDisplayBlock)item[kCKCellWillDisplay])(item, cell, indexPath);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.curDatasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}

@end
