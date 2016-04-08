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
#import "HKLoadingModel.h"

@interface MessageListVC ()<UITableViewDataSource, UITableViewDelegate, HKLoadingModelDelegate>
@property (nonatomic, assign) long long curMsgTime;
@property (strong, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;

@end

@implementation MessageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MessageListVC dealloc!");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)setupTableView
{
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    self.loadingModel.isSectionLoadMore = YES;
    [self.loadingModel loadDataForTheFirstTime];
    [self.tableView setShowBottomLoadingView:YES];
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无消息",@"image":@"def_nomessage"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取消息失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        self.curMsgTime = 0;
    }
    
    GetMessageOp * op = [GetMessageOp operation];
    op.req_msgtime = self.curMsgTime;
    return [[op rac_postRequest] map:^id(GetMessageOp *rspOp) {
        if (rspOp.req_msgtime == 0) {
            gAppMgr.myUser.hasNewMsg = NO;
        }
        return rspOp.rsp_msgs;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    self.curMsgTime = [[model.datasource lastObject] msgtime];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKMessage *msg = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
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
    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    HKMessage *msg = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
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
//    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
    
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nestItemCount:1 promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp324_1"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HKMessage *msg = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    if (msg.url.length > 0) {
        [gAppMgr.navModel pushToViewControllerByUrl:msg.url];
    }
}

#pragma mark - Private
- (NSAttributedString *)attrStrForMessage:(HKMessage *)msg linkRange:(NSRange *)range
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 5;
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor darkTextColor],
                           NSParagraphStyleAttributeName:paragraph};
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:msg.content attributes:attr];
    [str appendAttributedString:str1];
    (*range).location = [str length];

//    if (msg.msgtype == 2) {
//        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:HEXCOLOR(@"#386fcd")};
//        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@" 点击分享" attributes:attr];
//        (*range).length = [str2 length];
//        [str appendAttributedString:str2];
//    }
    return str;
}

@end
