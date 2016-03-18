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
#import "MutualInsPayViewController.h"


@interface MutualInsOrderInfoVC ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet CKLine *bottomLine;

@property (nonatomic,strong)NSArray * datasource;

@property (nonatomic,strong)MutualInsContract * contract;

/**
 *  是否保险公司代购
 */
@property (nonatomic)BOOL isInsProxy;

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

- (void)refreshUI
{
    if (self.contract.status == 1)
    {
        [self.sureBtn setTitle:@"立即支付" forState:UIControlStateNormal & UIControlStateHighlighted];
    }
    else
    {
        [self.sureBtn setTitle:@"联系客服" forState:UIControlStateNormal & UIControlStateHighlighted];
    }
    
    NSString * topTip = self.contract.remindtip;
    if (topTip.length)
    {
        self.topView.hidden = NO;
        self.topLabel.text = topTip;
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
        @weakify(self)
        [[RACObserve(self.tableView,contentOffset) distinctUntilChanged] subscribeNext:^(NSValue * obj) {
            
            @strongify(self)
            @weakify(self)
            CGPoint point = [obj CGPointValue];
            [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                @strongify(self)
                CGFloat offset = MIN(-point.y / 3.0, 0);
                make.top.equalTo(self.view).offset(offset);
            }];
        }];
    }
    else
    {
        self.topView.hidden = YES;
        self.tableView.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark - Utilitly
- (void)nextAction
{
    if (self.contract.status == 1)
    {
        MutualInsPayViewController * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPayViewController"];
        vc.contract = self.contract;
        vc.proxybuy = self.isInsProxy;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"订单查询,小马互助咨询等\n请拨打客服电话: 4007-111-111"];
    }
}

- (void)requestContractDetail
{
    GetCooperationContractDetailOp * op = [[GetCooperationContractDetailOp alloc] init];
    op.req_contractid = self.contractId;
    [[[op rac_postRequest] initially:^{
        
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        self.topView.hidden = YES;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationContractDetailOp * rop) {
        
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view stopActivityAnimation];
        
        self.contract = rop.rsp_contractorder;
        self.isInsProxy = self.contract.insperiod;
        [self setupDateSource];
        
        [self refreshUI];
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        @weakify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        self.topView.hidden = YES;
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
        NSNumber * sum = subIns[@"sum"] ?: @"";
        [array safetyAddObject:@{@"id":@"ItemCell",@"title":insName,@"content":[NSString formatForPrice:[sum floatValue]]}];
    }
    
    if (self.contract.insperiod)
    {
        [array safetyAddObject:@{@"id":@"SwitchCell",@"insSelected":@(self.isInsProxy),@"content":@"保险公司代购"}];
        
        if (self.isInsProxy)
        {
            [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保险公司",@"content":self.contract.inscomp.firstObject ?: @""}];
            [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保险期限",@"content":self.contract.insperiod ?: @""}];
            
            [array safetyAddObject:@{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额"}];
            
            [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"交强险",@"content":[NSString formatForPrice:self.contract.forcefee]}];
            [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"车船税",@"content":[NSString formatForPrice:self.contract.taxshipfee]}];
        }
    }
    
    
    self.datasource = [NSArray arrayWithArray:array];
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
        height = 54;
    }
    else if ([cellId isEqualToString:@"InfoCell"])
    {
        height = 25;
    }
    else if ([cellId isEqualToString:@"ItemHeaderCell"])
    {
        height = 34;
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
    progressView.titleArray = @[@"待支付",@"已支付",@"协议待出",@"协议已出"];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.contract.status - 1];
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
    leftLine.lineColor = middleLine.lineColor = rightLine.lineColor = bottomLine.lineColor  = HEXCOLOR(@"#d3f0e0");
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
    
    @weakify(self)
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        self.isInsProxy = !self.isInsProxy;
        [self setupDateSource];
        [self.tableView reloadData];
    }];
    
    [[[RACObserve(self, isInsProxy) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
       
        checkBtn.selected = [number integerValue];
    }];

    return cell;
}



@end
