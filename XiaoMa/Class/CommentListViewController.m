//
//  CommentListViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-5.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CommentListViewController.h"
#import "JTShop.h"
#import "JTRatingView.h"
#import "GetShopRatesOp.h"
#import "JTTableView.h"

@interface CommentListViewController ()

@property (strong, nonatomic) IBOutlet JTTableView *tableView;

/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;
///列表下面是否还有商品
@property (nonatomic, assign) BOOL isRemain;
///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.commentArray.count >= PageAmount)
    {
        self.isRemain = YES;
    }
    else
    {
        self.isRemain = NO;
        self.tableView.showBottomLoadingView = YES;
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"到底了"];
    }
    
    self.pageAmount = PageAmount;
    self.currentPageIndex = 1;
    
//    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

#pragma mark - Action
- (void)requestMoreShopComments
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    
    GetShopRatesOp * op = [GetShopRatesOp operation];
    op.shopId = self.shopid;
    op.pageno = self.currentPageIndex + 1;
    [[[op rac_postRequest] initially:^{
        
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        
    }]  subscribeNext:^(GetShopRatesOp * op) {
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
        if (op.rsp_shopCommentArray.count >= self.pageAmount)
        {
            self.isRemain = YES;
        }
        else
        {
            self.isRemain = NO;
        }
        if (!self.isRemain)
        {
            self.tableView.showBottomLoadingView = YES;
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
        }

        
        NSMutableArray * tArray = [NSMutableArray arrayWithArray:self.commentArray];
        [tArray addObjectsFromArray:op.rsp_shopCommentArray];
        self.commentArray = [NSArray arrayWithArray:tArray];
        [self.tableView reloadData];
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = self.commentArray.count;
    
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self shopCommentCellAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
    
    if (self.commentArray.count-1 <= indexPath.row && self.isRemain)
    {
        [self requestMoreShopComments];
    }
}


- (UITableViewCell *)shopCommentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    UIImageView *avatarV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *nameL = (UILabel*)[cell.contentView viewWithTag:1002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:1003];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1004];
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:1005];
    avatarV.cornerRadius = 17.5f;
    avatarV.layer.masksToBounds = YES;
    
    JTShopComment *comment = [self.commentArray safetyObjectAtIndex:indexPath.row];
    nameL.text = comment.nickname.length ? comment.nickname : @"无昵称用户";
    timeL.text = [comment.time dateFormatForYYMMdd2];
    ratingV.ratingValue = comment.rate;
    contentL.text = comment.comment;
    
    [[gMediaMgr rac_getPictureForUrl:comment.avatarUrl withType:ImageURLTypeThumbnail defaultPic:@"avatar_default" errorPic:@"avatar_default"] subscribeNext:^(id x) {
        
        avatarV.image = x;
    }];
    
    return cell;
}


@end
