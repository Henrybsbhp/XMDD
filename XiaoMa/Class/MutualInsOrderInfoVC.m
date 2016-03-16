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
#import "GetCooperationContractDetailOp.h"
#import "MutualInsContract.h"


@interface MutualInsOrderInfoVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet CKLine *bottomLine;

@property (nonatomic,strong)NSArray * datasource;

@property (nonatomic,strong)MutualInsContract * contract;

@end

@implementation MutualInsOrderInfoVC

- (void)dealloc
{
    DebugLog(@"MutualInsOrderInfoVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupUI];
    
    [self requestContractDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup
- (void)setupNavigationBar
{
    self.navigationItem.title = @"订单详情";
}

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

- (void)requestContractDetail
{
    GetCooperationContractDetailOp * op = [[GetCooperationContractDetailOp alloc] init];
    op.req_contractid = self.contractId;
    [[[op rac_postRequest] initially:^{
        
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationContractDetailOp * rop) {
        
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view stopActivityAnimation];
        
        self.contract = rop.rsp_contractorder;
        [self setupDateSource];
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        @weakify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:[NSString stringWithFormat:@"%@ \n点击再试一次",error.domain] tapBlock:^{
            
            @strongify(self)
            [self requestContractDetail];
        }];
    }];
}

- (void)setupDateSource
{
    NSMutableArray * array = [NSMutableArray array];
    
    [array safetyAddObject:@{@"id":@"ProgressCell"}];
    
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"互助团员",@"content":self.contract.insurancedname ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"互助期限",@"content":self.contract.contractperiod ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"证件号码",@"content":self.contract.idno ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"互助车辆",@"content":self.contract.licencenumber ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"共计费用",@"content":[NSString formatForPrice:self.contract.total],@"tag":self.contract.couponmoney ? [NSString stringWithFormat:@"优惠￥%@",[NSString formatForPrice:self.contract.couponmoney]] : @""}];
    [array safetyAddObject:@{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额"}];
    
    for (NSDictionary * subIns in self.contract.inslist)
    {
        NSString * insName = subIns[@"insname"] ?: @"";
        NSString * sum = subIns[@"sum"] ?: @"";
        [array safetyAddObject:@{@"id":@"ItemCell",@"title":insName,@"content":sum}];
    }
    
    if (self.contract.insperiod)
    {
        [array safetyAddObject:@{@"id":@"SwitchCell",@"insSelected":@(1),@"content":@"保险公司代购"}];
        
        [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保险公司",@"content":self.contract.inscomp.firstObject ?: @""}];
        [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保险期限",@"content":self.contract.insperiod ?: @""}];
        
        [array safetyAddObject:@{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额"}];
        
        [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"交强险",@"content":[NSString formatForPrice:self.contract.forcefee]}];
        [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"车船税",@"content":[NSString formatForPrice:self.contract.taxshipfee]}];
    }
    
    self.datasource = [NSArray arrayWithArray:array];
//    self.datasource = @[@{@"id":@"ProgressCell"},
//                        @{@"id":@"InfoCell",@"title":@"互助团员",@"content":self.contract.insurancedname ?: @""},
//                        @{@"id":@"InfoCell",@"title":@"互助期限",@"content":self.contract.contractperiod ?: @""},
//                        @{@"id":@"InfoCell",@"title":@"证件号码",@"content":self.contract.idno ?: @""},
//                        @{@"id":@"InfoCell",@"title":@"互助车辆",@"content":self.contract.licencenumber ?: @""},
//                        @{@"id":@"InfoCell",@"title":@"共计费用",@"content":[NSString formatForPrice:self.contract.total],@"tag":self.contract.couponmoney ? [NSString stringWithFormat:@"优惠￥%@",[NSString formatForPrice:self.contract.couponmoney]] : @""},
//                        @{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额"},
//                        @{@"id":@"ItemCell",@"title":@"机动车损失险",@"content":@"1230,000.00"},
//                        @{@"id":@"ItemCell",@"title":@"车上人员座位险(机动车交通强制保险第第三者)",@"content":@"5000,000.00/每座"},
//                        @{@"id":@"ItemCell",@"title":@"第三者责任险",@"content":@"5000,000.00"},
//                        @{@"id":@"SwitchCell",@"insSelected":@(1),@"content":@"保险公司代购"},
//                        @{@"id":@"ItemHeaderCell",@"title":@"保险内容",@"content":@"保险金额"},
//                        @{@"id":@"ItemCell",@"title":@"交强险",@"content":@"950.00"},
//                        @{@"id":@"ItemCell",@"title":@"车船税",@"content":@"550.00"}];

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
        height = 25;
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
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
    progressView.selectedIndexSet = set;
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
    
    @weakify(checkBtn)
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(checkBtn)
        checkBtn.selected = !checkBtn.selected;
    }];
    
    [[RACObserve(checkBtn, selected) takeUntilForCell:cell] subscribeNext:^(NSNumber * number) {
        
        if ([number integerValue])
        {
        }
        else
        {
        }
    }];
    
    return cell;
}



@end
