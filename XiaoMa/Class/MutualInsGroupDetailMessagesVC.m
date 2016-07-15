//
//  MutualInsGroupDetailDynamicVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailMessagesVC.h"
#import "MutualInsConstants.h"
#import "MutualInsGrouponMsgCell.h"

@implementation MutualInsGroupDetailMessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    [self subscribeReloadSignal];
    [self subscribeLoadMoreSignal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupTableView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    bottomView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = bottomView;
}

#pragma mark - Subscribe
- (void)subscribeReloadSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, reloadMessagesInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
           
            @strongify(self);
            [self.tableView setHidden:YES animated:NO];
            CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
        }] subscribeNext:^(GetCooperationGroupMessageListOp *op) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            if (self.viewModel.messagesInfo.rsp_list.count == 0) {
                [self.view showImageEmptyViewWithImageName:@"def_noGroupMessages" text:@"暂无任何成员动态" tapBlock:^{
                    @strongify(self);
                    [self.view hideDefaultEmptyView];
                    [self.viewModel fetchMessagesInfoForce:YES];
                }];
            }
            else {
                [self.tableView setHidden:NO animated:YES];
                self.datasource = [CKList listWithArray:[self itemsForMessageList:op.rsp_list]];
                [self.tableView reloadData];
            }
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:error.domain tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self.viewModel fetchMessagesInfoForce:YES];
            }];
            
        }];
    }];
}

- (void)subscribeLoadMoreSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, loadMoreMessagesInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.tableView.tableFooterView startActivityAnimationWithType:UIActivityIndicatorType];
        }] subscribeNext:^(GetCooperationGroupMessageListOp *op) {
            
            @strongify(self);
            [self.tableView.tableFooterView stopActivityAnimation];
            [self.datasource addObjectsFromArray:[self itemsForMessageList:op.rsp_list]];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.tableView.tableFooterView stopActivityAnimation];
            [self.tableView.tableFooterView showIndicatorTextWith:@"加载更多动态失败，点击重试" clickBlock:^(UIButton *sender) {
                @strongify(self);
                [self.viewModel fetchMoreMessagesInfo];
            }];
        }];
    }];
}
#pragma mark - Datasource
- (NSArray *)itemsForMessageList:(NSArray *)msglist {
    return [msglist arrayByMappingOperator:^id(id obj) {
        return [self itemForMessage:obj];
    }];
}

- (CKDict *)itemForMessage:(MutualInsMessage *)msg {
    BOOL rightSide = [msg.memberid isEqual:self.router.userInfo[kMutInsMemberID]];
    CKDict *item = [CKDict dictWith:@{kCKCellID:[NSString stringWithFormat:@"Message_%d", rightSide], @"content":msg.content,
                                      @"right":@(rightSide), @"title":msg.licensenumber, @"memberID":msg.memberid, @"time":msg.time}];
    item[@"avatar"] = msg.carlogourl ? msg.carlogourl : @"mins_def";
    return item;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *data = self.datasource[indexPath.row];
    CGFloat height;
    if (data[@"height"]) {
        height = [data[@"height"] floatValue];
    }
    else {
        height = [MutualInsGrouponMsgCell heightWithBoundsWidth:ScreenWidth message:data[@"content"]];
        data[@"height"] = @(height);
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *data = self.datasource[indexPath.row];
    MutualInsGrouponMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID]];
    if (!cell) {
        cell = [[MutualInsGrouponMsgCell alloc] initWithAtRightSide:[data[@"right"] boolValue] reuseIdentifier:data[kCKCellID]];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.timeLabel.text = data[@"time"];
    cell.titleLabel.text = data[@"title"];
    [cell.logoView setImageByUrl:data[@"avatar"] withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
    cell.message = data[@"content"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = self.datasource.count;
    if (!self.viewModel.loadMoreMessagesInfoSignal && count > 0 &&
        count % kFetchPageAmount == 0 && indexPath.row == count - 1) {
        [self.viewModel fetchMoreMessagesInfo];
    }
}

@end
