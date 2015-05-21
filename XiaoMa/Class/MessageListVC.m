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

@interface MessageListVC ()
@property (nonatomic, strong) NSMutableArray *msgList;
@property (nonatomic, assign) long long curMsgTime;
@property (strong, nonatomic) IBOutlet JTTableView *jt_tableView;
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

- (void)setupTableView
{
    [self.jt_tableView setShowBottomLoadingView:YES];
    [self.tableView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
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
        
        if (timetag == 0) {
            [self.jt_tableView.refreshView beginRefreshing];
        }
        else {
            [self.jt_tableView.bottomLoadingView startActivityAnimation];
        }
    }] subscribeNext:^(GetMessageOp *rspOp) {
        [self.jt_tableView.refreshView endRefreshing];
        [self.jt_tableView stopActivityAnimation];
        if (timetag == 0) {
            self.msgList = [NSMutableArray array];
        }
        [self.msgList safetyAddObjectsFromArray:rspOp.rsp_msgs];
        self.curMsgTime = [[self.msgList lastObject] msgtime];
        if (rspOp.rsp_msgs.count < PageAmount) {
            [self.jt_tableView.bottomLoadingView showIndicatorTextWith:@"没有更多消息了"];
            self.isRemain = NO;
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [self.jt_tableView.refreshView endRefreshing];
        [self.jt_tableView.bottomLoadingView stopActivityAnimation];
        @weakify(self);
        [self.jt_tableView.bottomLoadingView showIndicatorTextWith:@"刷新失败了，点击重试" clickBlock:^(UIButton *sender) {
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
                                                   withConstraints:CGSizeMake(self.tableView.frame.size.width - 54, 10000)
                                            limitedToNumberOfLines:0];
    return MAX(size.height+26,65);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
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
    
    label.delegate = (id<TTTAttributedLabelDelegate>)label;
   
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
    if (indexPath.section >= self.msgList.count-1 && self.isRemain) {
        [self loadMoreMessages];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadMoreMessages
{
    if ([self.jt_tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    [self loadDatasourceWithTimetag:self.curMsgTime];
}

#pragma mark - Private
- (NSAttributedString *)attrStrForMessage:(HKMessage *)msg linkRange:(NSRange *)range
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor darkTextColor]};
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:msg.content attributes:attr1];
    [str appendAttributedString:str1];
    (*range).location = [str length];
    
    if (msg.msgtype == 2) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:HEXCOLOR(@"#386fcd")};
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@" 点击分享" attributes:attr2];
        (*range).length = [str2 length];
        [str appendAttributedString:str2];
    }
    return str;
}

@end
