//
//  CarwashOrderCommentVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarwashOrderCommentVC.h"
#import "JTRatingView.h"
#import "SubmitCommentOp.h"

@interface CarwashOrderCommentVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SubmitCommentOp *commentOp;
@end

@implementation CarwashOrderCommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.commentOp = [SubmitCommentOp new];
    self.commentOp.req_rating = 5;
    self.commentOp.req_orderid = self.order.orderid;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action
- (IBAction)actionComment:(id)sender
{
    @weakify(self);
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell) {
        JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:2001];
        UIAPlaceholderTextView *textV = (UIAPlaceholderTextView *)[cell.contentView viewWithTag:3001];
        self.commentOp.req_comment = textV.text;
        self.commentOp.req_rating = ratingV.ratingValue;
    }
    [[[self.commentOp rac_postRequest] initially:^{
        [gToast showingWithText:@"Loading..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        if (self.customActionBlock) {
            self.customActionBlock();
        }
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *nameL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *serviceL = (UILabel *)[cell.contentView viewWithTag:1003];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:2001];
    UIAPlaceholderTextView *textV = (UIAPlaceholderTextView *)[cell.contentView viewWithTag:3001];
    
    [[[gAppMgr.mediaMgr rac_getPictureForUrl:[self.order.shop.picArray safetyObjectAtIndex:0] withDefaultPic:@"cm_shop"] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        logoV.image = x;
    }];
    
    nameL.text = self.order.shop.shopName;
    
    JTShopService *service = [self.order currentService];
    serviceL.text = [NSString stringWithFormat:@"我享受的服务：%@", service.serviceName ? service.serviceName : @""];

    ratingV.imgWidth = 20;
    ratingV.imgHeight = 19;
    ratingV.imgSpacing = 10;
    ratingV.normalImageName = @"me_star2";
    ratingV.highlightImageName = @"me_star1";
    ratingV.ratingValue = self.commentOp.req_rating;

    textV.placeholderString = @"请您对本次服务给出客观评价";
    textV.text = self.commentOp.req_comment;
    
    @weakify(self);
    [[cell rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.commentOp.req_rating = self.commentOp.req_rating;
        self.commentOp.req_comment = self.commentOp.req_comment;
    }];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:2001];
    [ratingV resetImageViewFrames];
}
@end
