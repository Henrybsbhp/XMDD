//
//  MessageListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MessageListVC.h"
#import "GetMessageOp.h"
#import "TTTAttributedLabel.h"

@interface MessageListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *msgList;
@property (nonatomic, assign) long long curMsgTime;
@property (strong, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, assign) BOOL isRemain;
@end

@implementation MessageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp324"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp324"];
}

- (void)setupTableView
{
    [self.tableView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    [self.tableView setShowBottomLoadingView:YES];
}

- (void)reloadDatasource
{
    self.isRemain = YES;
    [self loadDatasourceWithTimetag:0];
}

- (void)loadDatasourceWithTimetag:(long long)timetag
{
    GetMessageOp *op = [GetMessageOp new];
    op.req_msgtime = timetag;
    [[[op rac_postRequest] initially:^{

        [self.tableView.bottomLoadingView hideIndicatorText];
        if (timetag == 0) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            [self.tableView.bottomLoadingView startActivityAnimation];
        }
    }] subscribeNext:^(GetMessageOp *rspOp) {
        
        [self.tableView.refreshView endRefreshing];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        if (timetag == 0) {
            self.msgList = [NSMutableArray array];
            gAppMgr.myUser.hasNewMsg = NO;
        }
        [self.msgList safetyAddObjectsFromArray:rspOp.rsp_msgs];
        self.curMsgTime = [[self.msgList lastObject] msgtime];
        if (rspOp.rsp_msgs.count < PageAmount) {
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"没有更多消息了"];
            self.isRemain = NO;
        }
        else {
            self.isRemain = YES;
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [self.tableView.refreshView endRefreshing];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        @weakify(self);
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"刷新失败了，点击重试" clickBlock:^(UIButton *sender) {
            @strongify(self);
            [self loadDatasourceWithTimetag:timetag];
        }];
    }];
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKMessage *msg = [self.msgList safetyObjectAtIndex:indexPath.section];
    NSRange range = NSMakeRange(0, 0);
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:[self attrStrForMessage:msg linkRange:&range]
                                                   withConstraints:CGSizeMake(self.tableView.frame.size.width-54, 10000)
                                            limitedToNumberOfLines:0];
    return MAX(85, size.height+46);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.msgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    HKMessage *msg = [self.msgList safetyObjectAtIndex:indexPath.section];
    TTTAttributedLabel *label = (TTTAttributedLabel *)[cell.contentView viewWithTag:1001];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:2001];
    
    timeL.text = [[NSDate dateWithTimeIntervalSince1970:msg.msgtime/1000] textForDate];
    label.text = msg.content;
    label.delegate = (id<TTTAttributedLabelDelegate>)label;
    label.linkAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                             NSForegroundColorAttributeName:HEXCOLOR(@"#386fcd")};
   
    NSRange range = NSMakeRange(0, 0);
    NSAttributedString *str = [self attrStrForMessage:msg linkRange:&range];
    label.attributedText = str;
    if (range.length > 0) {
        [label addLinkToURL:[NSURL URLWithString:@"share"] withRange:range];
    }
    
    //label的点击事件
    [[[label rac_signalForSelector:@selector(attributedLabel:didSelectLinkWithURL:) fromProtocol:@protocol(TTTAttributedLabelDelegate)] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.msgList.count-1 <= indexPath.section && self.isRemain) {
        [self loadMoreMessages];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp324-1"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadMoreMessages
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    [self loadDatasourceWithTimetag:self.curMsgTime];
}

#pragma mark - Private
- (NSAttributedString *)attrStrForMessage:(HKMessage *)msg linkRange:(NSRange *)range
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor darkTextColor]};
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:msg.content attributes:attr];
    [str appendAttributedString:str1];
    (*range).location = [str length];

    if (msg.msgtype == 2) {
//        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:HEXCOLOR(@"#386fcd")};
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@" 点击分享" attributes:attr];
        (*range).length = [str2 length];
        [str appendAttributedString:str2];
    }
    return str;
}

@end
