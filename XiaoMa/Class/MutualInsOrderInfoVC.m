//
//  MutualInsOrderInfoVC.m
//  XiaoMa
//
//  Created by jt on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsOrderInfoVC.h"
#import "HKProgressView.h"
#import "HKArrowView.h"
#import "CKLine.h"
#import "NSString+RectSize.h"


@interface MutualInsOrderInfoVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet CKLine *bottomLine;

@property (nonatomic,strong)NSArray * datasource;

@end

@implementation MutualInsOrderInfoVC

- (void)dealloc
{
    DebugLog(@"MutualInsOrderInfoVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datasource = @[@{@"id":@"ProgressCell"},
  @{@"id":@"InfoCell",@"title":@"协议受益人",@"content":@"傅琦"},
  @{@"id":@"InfoCell",@"title":@"投保车辆",@"content":@"浙AY617V",@"tag":@"原价$1000,优惠￥100"},
  @{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额"},
  @{@"id":@"ItemCell",@"title":@"机动车损失险",@"content":@"1230,000.00"},
  @{@"id":@"ItemCell",@"title":@"车上人员座位险(机动车交通强制保险第第三者)",@"content":@"5000,000.00/每座"},
  @{@"id":@"ItemCell",@"title":@"第三者责任险",@"content":@"5000,000.00"},
  @{@"id":@"SwitchCell",@"insSelected":@(1),@"content":@"保险公司代购"},
  @{@"id":@"ItemHeaderCell",@"title":@"保险内容",@"content":@"保险金额"},
  @{@"id":@"ItemCell",@"title":@"交强险",@"content":@"950.00"},
  @{@"id":@"ItemCell",@"title":@"车船税",@"content":@"550.00"}];
    
    [self setupNavigationBar];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup
- (void)setupNavigationBar
{}

- (void)setupUI
{
    @weakify(self)
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        @strongify(self);
        [self nextAction];
    }];
}

#pragma mark - Utilitly
- (void)nextAction
{
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger num = self.datasource.count;
    return num;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * cellId = [dict objectForKey:@"id"];
    if ([cellId isEqualToString:@"ProgressCell"])
    {
        height = 45;
    }
    else if ([cellId isEqualToString:@"InfoCell"])
    {
        height = 27;
    }
    else if ([cellId isEqualToString:@"ItemHeaderCell"])
    {
        height = 30;
    }
    else if ([cellId isEqualToString:@"ItemCell"])
    {
        NSString * title = [dict objectForKey:@"title"];
        NSString * content = [dict objectForKey:@"content"];
        CGFloat width = gAppMgr.deviceInfo.screenSize.width;
        CGFloat lbWidth = width / 2 - 8 - 10 - 10 - 10;
        CGSize size1 = [title labelSizeWithWidth:lbWidth font:[UIFont systemFontOfSize:13]];
        CGSize size2 = [content labelSizeWithWidth:lbWidth font:[UIFont systemFontOfSize:13]];
        // 20 = 10 + 10 文字和上下边界的距离
        height = MAX(MAX(size1.height + 20, size2.height + 20),30);
    }
    else
    {
        height = 40;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell;
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * cellId = [dict objectForKey:@"id"];
    if ([cellId isEqualToString:@"ProgressCell"])
    {
        cell = [self tableView:tableView progressCellForRowAtIndexPath:indexPath];
    }
    else if ([cellId isEqualToString:@"InfoCell"])
    {
        cell = [self tableView:tableView infoCellForRowAtIndexPath:indexPath];
    }
    else if ([cellId isEqualToString:@"ItemHeaderCell"])
    {
        cell = [self tableView:tableView itemHeaderCellForRowAtIndexPath:indexPath];
    }
    else if ([cellId isEqualToString:@"ItemCell"])
    {
        cell = [self tableView:tableView itemCellForRowAtIndexPath:indexPath];
    }
    else
    {
        cell = [self tableView:tableView switchCellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView progressCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
    HKProgressView * progressView = (HKProgressView *)[cell searchViewWithTag:101];
    progressView.titleArray = @[@"待支付",@"已支付",@"保单已出"];
    progressView.selectedIndex = 0;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView infoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * title = [dict objectForKey:@"title"];
    NSString * content = [dict objectForKey:@"content"];
    NSString * tag = [dict objectForKey:@"tag"];
    
    UILabel * lb1 = (UILabel *)[cell searchViewWithTag:101];
    UILabel * lb2 = (UILabel *)[cell searchViewWithTag:102];
    HKArrowView * arrowView = (HKArrowView *)[cell searchViewWithTag:103];
    UILabel * tagLb = (UILabel *)[cell searchViewWithTag:20301];
    
    lb1.text = title;
    lb2.text = content;
    arrowView.hidden = !tag.length;
    arrowView.bgColor = HEXCOLOR(@"#ff7428");
    arrowView.cornerRadius = 2.0f;
    tagLb.text = tag;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView itemHeaderCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ItemHeaderCell"];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * title = [dict objectForKey:@"title"];
    NSString * content = [dict objectForKey:@"content"];
    
    UILabel * lb1 = (UILabel *)[cell searchViewWithTag:101];
    UILabel * lb2 = (UILabel *)[cell searchViewWithTag:102];
    
    lb1.text = title;
    lb2.text = content;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView itemCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    CKLine * leftLine = (CKLine *)[cell searchViewWithTag:20101];
    CKLine * middleLine = (CKLine *)[cell searchViewWithTag:20102];
    CKLine * rightLine = (CKLine *)[cell searchViewWithTag:20103];
    CKLine * bottomLine = (CKLine *)[cell searchViewWithTag:20104];
    leftLine.lineColor = middleLine.lineColor = rightLine.lineColor = bottomLine.lineColor  = HEXCOLOR(@"#18d06a");
    leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
    middleLine.lineAlignment = CKLineAlignmentVerticalLeft;
    rightLine.lineAlignment = CKLineAlignmentVerticalRight;
    bottomLine.lineAlignment = CKLineAlignmentHorizontalBottom;

    UILabel * lb1 = (UILabel *)[cell searchViewWithTag:102];
    UILabel * lb2 = (UILabel *)[cell searchViewWithTag:103];
    
    
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * title = [dict objectForKey:@"title"];
    NSString * content = [dict objectForKey:@"content"];
    
    
    lb1.text = title;
    lb2.text = content;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView switchCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    UIButton * checkBtn = (UIButton *)[cell searchViewWithTag:101];
    UILabel * lb = (UILabel *)[cell searchViewWithTag:102];
    
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSNumber * insSelected = [dict objectForKey:@"insSelected"];
    NSString * content = [dict objectForKey:@"content"];
    
    checkBtn.selected = [insSelected boolValue];
    lb.text = content;
    
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
    }];
    
    return cell;
}



@end
