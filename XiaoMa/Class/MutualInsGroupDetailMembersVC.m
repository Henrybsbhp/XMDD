//
//  MutualInsGroupDetailMemberVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailMembersVC.h"
#import "MutualInsGroupMemberCell.h"
#import "MutualInsGroupMemberSectionCell.h"
#import "CMarkupTransformer.h"

@interface MutualInsGroupDetailMembersVC ()
@property (nonatomic, assign) long long curTimetag;
@end

@implementation MutualInsGroupDetailMembersVC

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
    
    [self.tableView registerClass:[MutualInsGroupMemberCell class] forCellReuseIdentifier:@"Member"];
    [self.tableView registerClass:[MutualInsGroupMemberSectionCell class] forCellReuseIdentifier:@"Section"];
}


#pragma mark - Subscribe
- (void)subscribeReloadSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, reloadMembersInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.tableView setHidden:YES animated:NO];
            CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
        }] subscribeNext:^(GetCooperationGroupMembersOp *op) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            if (self.viewModel.membersInfo.rsp_memberlist.count == 0) {
                [self.view showImageEmptyViewWithImageName:@"def_noGroupMembers" text:@"暂无任何成员加入" tapBlock:^{
                    @strongify(self);
                    [self.view hideDefaultEmptyView];
                    [self.viewModel fetchMembersInfoForce:YES];
                }];
            }
            else {
                [self.tableView setHidden:NO animated:YES];
                [self reloadDataWithMembers:op.rsp_memberlist];
            }
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:error.domain tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self.viewModel fetchMembersInfoForce:YES];
            }];
            
        }];
    }];
}

- (void)subscribeLoadMoreSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, loadMoreMembersInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.tableView.tableFooterView startActivityAnimationWithType:UIActivityIndicatorType];
        }] subscribeNext:^(GetCooperationGroupMembersOp *op) {
            
            @strongify(self);
            [self.tableView.tableFooterView stopActivityAnimation];
            [(CKList *)self.datasource[@"members"] addObjectsFromArray:[self itemsForMemberList:op.rsp_memberlist]];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.tableView.tableFooterView stopActivityAnimation];
            [self.tableView.tableFooterView showIndicatorTextWith:@"加载更多动态失败，点击重试" clickBlock:^(UIButton *sender) {
                @strongify(self);
                [self.viewModel fetchMoreMembersInfo];
            }];
        }];
    }];
}
#pragma mark - Datasource
- (void)reloadDataWithMembers:(NSArray *)members {
    NSArray *items = [self itemsForMemberList:members];
    self.datasource = $([$([self itemForSection]) setKey:@"sections"], [[CKList listWithArray:items] setKey:@"members"]);
    [self.tableView reloadData];
}

- (NSArray *)itemsForMemberList:(NSArray *)list {
    return [list arrayByMappingOperator:^id(id obj) {
        return [self itemForMember:obj];
    }];
}

#pragma mark - Item
- (CKDict *)itemForSection {
    NSString *title = [NSString stringWithFormat:@"当前团员共%d人", (int)self.viewModel.membersInfo.rsp_membercnt];
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"Section", @"title": title}];
    item[@"tip"] = self.viewModel.membersInfo.rsp_toptip;

    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 42;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMemberSectionCell *cell, NSIndexPath *indexPath) {
        
        cell.titleLabel.text = data[@"title"];
        NSString *tip = data[@"tip"];
        if (tip.length > 0) {
            cell.tipButton.hidden = NO;
            [cell.tipButton setTitle:tip forState:UIControlStateNormal];
        }
        else {
            cell.tipButton.hidden = YES;
        }
    });
    
    return item;
}

- (CKDict *)itemForMember:(MutualInsMemberInfo2 *)member {
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"Member", @"object":member}];
    item[@"extends"] = [member.extendinfo arrayByMappingOperator:^id(NSDictionary *dict) {
        NSString *key = dict.allKeys[0];
        NSString *text = dict[key];
        return RACTuplePack(key, text);
    }];
    
    
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        MutualInsMemberInfo2 *info = data[@"object"];
        return [MutualInsGroupMemberCell heightWithExtendInfoCount:info.extendinfo.count];
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMemberCell *cell, NSIndexPath *indexPath) {
        
        MutualInsMemberInfo2 *info = data[@"object"];
        [cell.logoView setImageByUrl:info.carlogourl withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
        cell.titleLabel.text = info.licensenumber;
        cell.extendInfoList = item[@"extends"];
        if (info.statusdesc.length > 0) {
            cell.tipButton.hidden = NO;
            [cell.tipButton setTitle:info.statusdesc forState:UIControlStateNormal];
        }
        else {
            cell.tipButton.hidden = YES;
        }
    });
    
    return item;
}

#pragma mark - TableView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = [self.datasource[@"members"] count];
    if (!self.viewModel.loadMoreMembersInfoSignal && count > 0 &&
        count % kFetchPageAmount == 0 && indexPath.row == count - 1) {
        [self.viewModel fetchMoreMembersInfo];
    }
}

@end
