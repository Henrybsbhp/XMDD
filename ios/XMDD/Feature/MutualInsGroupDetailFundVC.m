//
//  MutualInsGroupDetailFundVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailFundVC.h"
#import "MutualInsGroupFundCell.h"

@implementation MutualInsGroupDetailFundVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    [self subscribeReloadSignal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    [self.tableView registerClass:[MutualInsGroupFundCell class] forCellReuseIdentifier:@"Fund"];
}

- (void)subscribeReloadSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, reloadFundInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.tableView setHidden:YES animated:NO];
            CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
        }] subscribeNext:^(GetCooperationGroupMembersOp *op) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.tableView setHidden:NO animated:YES];
            [self reloadDatasource];
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:error.domain tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self.viewModel fetchFundInfoForce:YES];
            }];
            
        }];
    }];
}

- (void)reloadDatasource {
    CKList *datasource = self.datasource;
    if (!datasource) {
        datasource = $($(@{kCKItemKey: @"Fund", kCKCellID: @"Fund"}));
    }
    GetCooperationGroupSharemoneyOp *info = self.viewModel.fundInfo;
    CKList *tuples = $(info.rsp_insstarttime.length == 0 ? CKNULL : RACTuplePack(@"互助开始时间", info.rsp_insstarttime),
                       info.rsp_insendtime.length == 0 ? CKNULL : RACTuplePack(@"互助结束时间", info.rsp_insendtime));
    CKDict *item = datasource[0][@"Fund"];
    item[@"tuples"] = [tuples allObjects];
    item[@"desc"] = info.rsp_tip;
    item[@"percent"] = info.rsp_presentpoolpresent;
    item[@"remain"] = info.rsp_presentpoolamt;
    item[@"total"] = info.rsp_totalpoolamt;
    
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return [MutualInsGroupFundCell heightWithTupleInfoCount:[data[@"tuples"] count] andDesc:data[@"desc"]];
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupFundCell *cell, NSIndexPath *indexPath) {
        
        cell.tupleInfoList = item[@"tuples"];
        cell.descLabel.text = item[@"desc"];
        cell.progressView.totalpoolamt = item[@"total"];
        cell.progressView.presentpoolamt = item[@"remain"];
        [cell.progressView setPercent:item[@"percent"] animate:YES];
    });
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

@end
