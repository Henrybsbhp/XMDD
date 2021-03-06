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
#import "MutualInsPayResultVC.h"
#import "GetShareButtonOpV2.h"
#import "SocialShareViewController.h"


@interface MutualInsOrderInfoVC ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
@property (weak, nonatomic) IBOutlet CKLine *bottomLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sureBtnLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@property (nonatomic,strong)NSArray * datasource;

@property (nonatomic,strong)MutualInsContract * contract;

///是否保险公司代购
@property (nonatomic)BOOL isInsProxy;
///保险公司代购是否展开
@property (nonatomic)BOOL isInsProxyExpand;
///代购保险公司
@property (nonatomic,strong)NSString * proxyInsCompany;

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
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"联系客服" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionCallService:)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
    
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupUI
{
    @weakify(self)
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        @strongify(self);
        [self actionNext];
    }];
    
    [[self.addressBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        [self actionJumpToFinishAddressVC];
    }];
}

- (void)refreshBottomView
{
    if (self.contract.status == 1)
    {
        if (self.contract.paybtnflag)
        {
            self.sureBtn.enabled = YES;
            [self.sureBtn setBackgroundColor:kOrangeColor];
            [self.sureBtn setTitle:@"立即支付" forState:UIControlStateNormal & UIControlStateHighlighted];
        }
        else
        {
            self.sureBtn.enabled = NO;
            [self.sureBtn setBackgroundColor:kLightTextColor];
            [self.sureBtn setTitle:@"订单已过期，无法支付" forState:UIControlStateNormal & UIControlStateHighlighted];
        }
    }
    else
    {
        self.sureBtn.enabled = YES;
        [self.sureBtn setBackgroundColor:kOrangeColor];
        [self.sureBtn setTitle:@"晒单炫耀" forState:UIControlStateNormal & UIControlStateHighlighted];
    }
    
    
    if (self.contract.status == 2 && !self.contract.finishaddress)
    {
        CGFloat btnWidth = (gAppMgr.deviceInfo.screenSize.width - 10 * 3) / 2;
        self.sureBtnLeadingConstraint.constant = btnWidth + (10 * 2);
        
        self.addressBtn.hidden = NO;
        [self.addressBtn setTitle:@"寄送地址" forState:UIControlStateNormal & UIControlStateHighlighted];

    }
    else
    {
        self.sureBtnLeadingConstraint.constant = 10;
        self.addressBtn.hidden = YES;
    }
}

- (void)refreshUI
{
    [self refreshBottomView];
    
    NSString * topTip = self.contract.remindtip;
    if (topTip.length)
    {
        CGSize size = [topTip labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 38 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 24;
        self.topView.hidden = NO;
        self.topLabel.text = topTip;
        self.topLabel.numberOfLines = 0;
        self.tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
        self.topViewHeightConstraint.constant = height;
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
- (void)actionBack:(id)sender
{
    [MobClick event:@"hzdingdan" attributes:@{@"navi":@"back"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionNext
{
    if (self.contract.status == 1)
    {
        [MobClick event:@"hzdingdan" attributes:@{@"dibu":@"zhifu"}];
        
        MutualInsPayViewController * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPayViewController"];
        vc.contract = self.contract;
        vc.proxybuy = self.isInsProxy;
        vc.proxyInsCompany = self.isInsProxy ? self.proxyInsCompany : @"";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [MobClick event:@"hzdingdan" attributes:@{@"dibu":@"fenxiang"}];
        [self actionShare];
    }
}

- (void)actionJumpToFinishAddressVC
{
    [MobClick event:@"hzdingdan" attributes:@{@"dibu":@"wanshandizhi"}];
    
    MutualInsPayResultVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPayResultVC"];
    vc.contract = self.contract;
    vc.isFromOrderInfoVC = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCallService:(id)sender {
    
    [MobClick event:@"hzdingdan" attributes:@{@"navi":@"kefu"}];
    
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客户电话\n 4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (void)actionShare
{
    
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneShowXmddIns;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"分享信息拉取中..."];
    }] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneShowXmddIns;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        vc.mobBaseValue = @"hzdingdan";
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        [MobClick event:@"fenxiangyemian" attributes:@{@"chuxian":@"hzdingdan"}];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [MobClick event:@"fenxiangyemian" attributes:@{@"quxiao":@"hzdingdan"}];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
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
        [self.view hideDefaultEmptyView];
    }] subscribeNext:^(GetCooperationContractDetailOp * rop) {
        
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view stopActivityAnimation];
        [self.view hideDefaultEmptyView];
        
        self.contract = rop.rsp_contractorder;
        
        /// 交强险存在。如果待支付，用户可选择；交强险默认勾选
        if (self.contract.insperiod.length)
        {
            if (self.contract.status == 1)
            {
                self.isInsProxy = YES;
            }
        }
        [self setupDateSource];
        
        [self refreshUI];
        [self setupNavigationBar];
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        @weakify(self)
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        self.topView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:[NSString stringWithFormat:@"%@ \n点击再试一次",error.domain] tapBlock:^{
            @strongify(self)
            [self requestContractDetail];
        }];
    }];
}



- (void)setupDateSource
{
    if (!self.proxyInsCompany)
        self.proxyInsCompany = self.contract.inscomp.firstObject ?: @"";
    NSMutableArray * array = [NSMutableArray array];
    
    [array safetyAddObject:@{@"id":@"ProgressCell"}];
    
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"互助团员",@"content":self.contract.insurancedname ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保障开始",@"content":self.contract.contractperiodbegin ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保障结束",@"content":self.contract.contractperiodend ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"证件号码",@"content":self.contract.idno ?: @""}];
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"被保障车辆",@"content":self.contract.licencenumber ?: @""}];
    
    CGFloat price = self.contract.total - self.contract.couponmoney;
    NSString * tag = self.contract.couponmoney ? [NSString stringWithFormat:@"原价￥%@ 优惠￥%@",[NSString formatForPriceWithFloat:self.contract.total],[NSString formatForPriceWithFloat:self.contract.couponmoney]] : @"";
    [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"合计费用",@"content":[NSString stringWithFormat:@"￥%@",[NSString formatForPriceWithFloat:price]],@"tag":tag}];
    [array safetyAddObject:@{@"id":@"ItemHeaderCell",@"title":@"项目",@"content":@"金额(元)"}];
    
    for (NSDictionary * subIns in self.contract.inslist)
    {
        NSString * insName = subIns[@"insname"] ?: @"";
        NSNumber * sum = subIns[@"sum"] ?: @"";
        [array safetyAddObject:@{@"id":@"ItemCell",@"title":insName,@"content":[NSString formatForPriceWithFloat:[sum floatValue]]}];
    }
    
    for (NSDictionary * subinsnote in self.contract.insnotes)
    {
        NSString * insNoteTitle = subinsnote[@"title"] ?: @"";
        NSString * insNote = subinsnote[@"note"] ?: @"";
        [array safetyAddObject:@{@"id":@"ItemContentCell",@"title":insNoteTitle,@"content":insNote}];
    }
    if (self.contract.insnotes.count)
    {
        [array safetyAddObject:@{@"id":@"ItemContentBottomCell"}];
    }
    
    /// 交强险存在。如果待支付，用户可选择；如果已支付，说明用户选择了交强险代买
    if (self.contract.insperiod.length)
    {
        if (self.contract.status == 1)
        {
            [array safetyAddObject:@{@"id":@"SwitchCell",@"insSelected":@(self.isInsProxy),@"content":@"保险公司代购"}];
            
            if (self.isInsProxy)
            {
                [array safetyAddObject:@{@"id":@"InsCompanyCell",@"title":@"保险公司",@"content":self.proxyInsCompany}];
                
                if (self.isInsProxyExpand && self.contract.inscomp.count)
                {
                    [array safetyAddObject:@{@"id":@"InsExpandCell",@"title":@"保险公司",@"content":self.contract.inscomp}];
                }
                [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保险期限",@"content":self.contract.insperiod ?: @""}];
                
                [array safetyAddObject:@{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额(元)"}];
                
                [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"交强险",@"content":[NSString formatForPriceWithFloat:self.contract.forcefee]}];
                [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"车船税",@"content":[NSString formatForPriceWithFloat:self.contract.taxshipfee]}];
            }
        }
        else
        {
            [array safetyAddObject:@{@"id":@"BlankCell",@"height":@(10)}];
            [array safetyAddObject:@{@"id":@"InsCompanyCell",@"title":@"保险公司",@"content":self.proxyInsCompany}];
            [array safetyAddObject:@{@"id":@"InfoCell",@"title":@"保险期限",@"content":self.contract.insperiod ?: @""}];
            
            [array safetyAddObject:@{@"id":@"ItemHeaderCell",@"title":@"服务项目",@"content":@"保险金额(元)"}];
            
            [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"交强险",@"content":[NSString formatForPriceWithFloat:self.contract.forcefee]}];
            [array safetyAddObject:@{@"id":@"ItemCell",@"title":@"车船税",@"content":[NSString formatForPriceWithFloat:self.contract.taxshipfee]}];
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
    else if ([cellId isEqualToString:@"ItemContentCell"])
    {
        NSString * title = [dict objectForKey:@"title"];
        NSString * content = [dict objectForKey:@"content"];
        CGFloat width = gAppMgr.deviceInfo.screenSize.width;
        CGFloat lbWidth = width - (10+10+6)*2;
        CGSize size1 = [title labelSizeWithWidth:lbWidth font:[UIFont systemFontOfSize:13]];
        CGSize size2 = [content labelSizeWithWidth:lbWidth font:[UIFont systemFontOfSize:13]];
        height = 10 + size1.height + 8 + size2.height;
    }
    else if ([cellId isEqualToString:@"ItemContentBottomCell"])
    {
        height = 10;
    }
    else if ([cellId isEqualToString:@"InsCompanyCell"])
    {
        height = 25;
    }
    else if ([cellId isEqualToString:@"InsExpandCell"])
    {
        NSInteger num = self.contract.inscomp.count / 2 + self.contract.inscomp.count % 2;
        height = 5 + 6 + 27 * num + 9 * (num + 1);
    }
    else if ([cellId isEqualToString:@"SwitchCell"])
    {
        height = 40;
    }
    else
    {
        NSNumber * h = [dict objectForKey:@"height"];
        height = [h integerValue];
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
    else if ([cellId isEqualToString:@"ItemContentCell"])
    {
        cell = [self tableView:tableView itemContentCellForRowAtIndexPath:indexPath];
    }
    else if ([cellId isEqualToString:@"ItemContentBottomCell"])
    {
        cell = [self tableView:tableView itemContentBottomCellForRowAtIndexPath:indexPath];
    }
    else if ([cellId isEqualToString:@"InsCompanyCell"])
    {
        cell = [self tableView:tableView insCompanyCellForRowAtIndexPath:indexPath];
    }
    else if ([cellId isEqualToString:@"SwitchCell"])
    {
        cell = [self tableView:tableView switchCellForRowAtIndexPath:indexPath];
    }
    else
    {
        cell = [self tableView:tableView blankCellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * cellId = [dict objectForKey:@"id"];
    
    if ([cellId isEqualToString:@"SwitchCell"])
    {
        [MobClick event:@"hzdingdan" attributes:@{@"huzhudingdan":@"jiaoqiangxiankaiguan"}];
        self.isInsProxy = !self.isInsProxy;
        [self setupDateSource];
        [self.tableView reloadData];
    }
}



#pragma mark - About Cell
- (UITableViewCell *)tableView:(UITableView *)tableView progressCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
    HKProgressView * progressView = (HKProgressView *)[cell searchViewWithTag:101];
    progressView.titleArray = @[@"待支付",@"已支付",@"协议已寄送"];
    NSInteger status = self.contract.status == 4 ? 3 : self.contract.status;
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, status)];
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
    lb2.textColor = tag.length ? kOrangeColor : kDarkTextColor;
    arrowView.hidden = !tag.length;
    arrowView.bgColor = kOrangeColor;
    arrowView.cornerRadius = 2.0f;
    tagLb.text = tag;
    
    /// 需要重新绘制
    [arrowView setNeedsDisplay];
    
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
    
    lb1.numberOfLines = 0;
    lb2.numberOfLines = 0;

    
    
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * title = [dict objectForKey:@"title"];
    NSString * content = [dict objectForKey:@"content"];
    
    
    lb1.text = title;
    lb2.text = content;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView itemContentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ItemContentCell"];
    
    CKLine * leftLine = (CKLine *)[cell searchViewWithTag:20101];
    CKLine * rightLine = (CKLine *)[cell searchViewWithTag:20103];
    leftLine.lineColor = rightLine.lineColor = HEXCOLOR(@"#d3f0e0");
    leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
    rightLine.lineAlignment = CKLineAlignmentVerticalRight;
    
    UILabel * lb1 = (UILabel *)[cell searchViewWithTag:102];
    UILabel * lb2 = (UILabel *)[cell searchViewWithTag:103];
    
    lb2.numberOfLines = 0;
    
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * title = [dict objectForKey:@"title"];
    NSString * content = [dict objectForKey:@"content"];
    
    
    lb1.text = title;
    lb2.text = content;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView itemContentBottomCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ItemContentBottomCell"];
    CKLine * leftLine = (CKLine *)[cell searchViewWithTag:20101];
    CKLine * rightLine = (CKLine *)[cell searchViewWithTag:20103];
    CKLine * bottomLine = (CKLine *)[cell searchViewWithTag:20104];
    leftLine.lineColor =  rightLine.lineColor = bottomLine.lineColor  = HEXCOLOR(@"#d3f0e0");
    leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
    rightLine.lineAlignment = CKLineAlignmentVerticalRight;
    bottomLine.lineAlignment = CKLineAlignmentHorizontalBottom;
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
        
        [MobClick event:@"hzdingdan" attributes:@{@"huzhudingdan":@"jiaoqiangxiankaiguan"}];
        self.isInsProxy = !self.isInsProxy;
        [self setupDateSource];
        [self.tableView reloadData];
    }];
    
    [[[RACObserve(self, isInsProxy) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
       
        checkBtn.selected = [number integerValue];
    }];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView insCompanyCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"InsCompanyCell"];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    NSString * title = [dict objectForKey:@"title"];
    NSString * content = [dict objectForKey:@"content"];
    
    UILabel * lb1 = (UILabel *)[cell searchViewWithTag:101];
    UILabel * lb2 = (UILabel *)[cell searchViewWithTag:102];
    UIImageView * upIcon = (UIImageView *)[cell searchViewWithTag:103];
    
    lb1.text = title;
    lb2.text = content;
    upIcon.hidden = YES;
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView blankCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BlankCell"];
    return cell;
}

@end
