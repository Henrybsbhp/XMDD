//
//  ShopCommentListVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopCommentListVC.h"
#import "GetShopRatesV2Op.h"
#import "HKLoadingHelper.h"
#import "JTShop.h"
#import "JTTableView.h"
#import "ShopCommentCell.h"

@interface ShopCommentListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) JTTableView *tableView;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) HKLoadingHelper *loadingHelper;
@property (nonatomic, assign) NSInteger curPageno;
@end

@implementation ShopCommentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingHelper = [[HKLoadingHelper alloc] init];
    [self setupNavigationBar];
    [self setupTableView];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"评价列表";
}

- (void)setupTableView {
    self.tableView = [[JTTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.showBottomLoadingView = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[ShopCommentCell class] forCellReuseIdentifier:@"comment"];
}

- (void)reloadDatasource {
    self.datasource = [CKList listWithArray:self.commentArray];
    self.curPageno = 1;
    self.loadingHelper.isRemain = self.datasource.count >= self.loadingHelper.pageAmount;
    [self.tableView reloadData];
}

#pragma mark - Request
- (void)requestMoreCommentList {
    GetShopRatesV2Op *op = [GetShopRatesV2Op operation];
    op.req_pageno = self.curPageno+1;
    op.req_serviceTypes = [NSString stringWithInteger:self.serviceType];
    op.req_shopid = self.shopID;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.loadingHelper.isLoading = YES;
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimation];
    }] subscribeNext:^(GetShopRatesV2Op *op) {
        
        @strongify(self);
        [self.tableView.bottomLoadingView stopActivityAnimation];
        self.loadingHelper.isLoading = NO;
        self.curPageno = op.req_pageno;
        if (op.rsp_carwashCommentArray.count < self.loadingHelper.pageAmount) {
            self.loadingHelper.isRemain = NO;
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"到底了"];
        }
        if (op.rsp_carwashCommentArray.count > 0) {
            [self.datasource addObjectsFromArray:op.rsp_carwashCommentArray];
            [self.tableView reloadData];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        self.loadingHelper.isLoading = NO;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"加载失败，点击重试" clickBlock:^(UIButton *sender) {
            
            @strongify(self);
            [self.tableView.bottomLoadingView hideIndicatorText];
            [self requestMoreCommentList];
        }];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JTShopComment *comment = self.datasource[indexPath.row];
    return [ShopCommentCell cellHeightWithComment:comment.comment andBoundsWidth:ScreenWidth];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    JTShopComment *comment = self.datasource[indexPath.row];
    ShopCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comment" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.logoView setImageByUrl:comment.avatarUrl withType:ImageURLTypeThumbnail
                                    defImage:@"avatar_default" errorImage:@"avatar_default"];
    cell.titleLabel.text = comment.nickname.length ? comment.nickname : @"无昵称用户";
    cell.timeLabel.text = [comment.time dateFormatForYYMMdd2];
    cell.ratingView.ratingValue = comment.rate;
    cell.serviceLabel.text = [NSString stringWithFormat:@"服务项目：%@", comment.serviceName];
    cell.commentLabel.text = comment.comment;
    
    if (indexPath.row == 0) {
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
    }
    else {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.loadingHelper canLoadMoreForDatasource:self.datasource atRow:indexPath.row]) {
        [self requestMoreCommentList];
    }
}

@end
