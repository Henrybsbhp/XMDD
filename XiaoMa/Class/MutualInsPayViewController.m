//
//  MutualInsPayViewController.m
//  XiaoMa
//
//  Created by jt on 16/3/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPayViewController.h"
#import "TTTAttributedLabel.h"
#import "HKCellData.h"
#import "HKCoupon.h"
#import "PayCooperationContractOrderOp.h"
#import "GetCooperationResourcesOp.h"
#import "ChooseCouponVC.h"

@interface MutualInsPayViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (nonatomic,strong)PayCooperationContractOrderOp * payOp;
@property (nonatomic,strong)NSArray * datasource;

@property (nonatomic)BOOL isLoadingResourse;
///最多抵扣金额
@property (nonatomic)CGFloat maxCouponAmt;
@property (nonatomic,strong)NSArray * cashCoupouArray;
@property (nonatomic,strong)NSMutableArray * selectCashCoupouArray;

///协议数据源
@property (nonatomic,strong)HKCellData *licenseData;

@end

@implementation MutualInsPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupDateSource];
    [self.tableView reloadData];
    
    [self requestMutualResources];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupNavigationBar
{
    self.navigationItem.title = @"支付确认";
}

- (void)setupUI
{
    
}


- (void)setupDateSource
{
    NSArray * section1 = @[[self celldataFor0_0],[self celldataFor0_1],[self celldataFor0_2],[self celldataFor0_3]];
    
    NSMutableArray * section2 = [NSMutableArray arrayWithArray:@[[self celldataFor1_0],[self celldataFor1_1]]];
    if (self.contract.couponlist.count)
    {
        [section2 safetyAddObject:[self celldataFor1_2]];
    }
    
    NSArray * section3 = @[[self celldataFor2_0],
                           [self celldataFor2_1],
                           [self celldataFor2_2],
                           [self celldataFor2_3],
                           [self celldataFor2_4]];
    
    self.datasource = @[section1,section2,section3];
}

#pragma mark - Request
- (void)requestMutualResources
{
    GetCooperationResourcesOp * op = [GetCooperationResourcesOp operation];
    [[[op rac_postRequest] initially:^{
        
        self.isLoadingResourse = YES;
    }] subscribeNext:^(GetCooperationResourcesOp * rop) {
        
        self.isLoadingResourse = NO;
        self.cashCoupouArray = rop.rsp_couponArray;
        self.maxCouponAmt = rop.rsp_maxcouponamt;
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
    }];
}

#pragma mark - Utilitly

///获取优惠劵title（12元代金劵）
- (NSString *)calcCouponTitle:(NSArray *)couponArray
{
    if (couponArray.count == 0)
    {
        return @"";
    }
    else if (couponArray.count == 1)
    {
        HKCoupon * coupon = [couponArray safetyObjectAtIndex:0];
        return coupon.couponName;
    }
    else
    {
        CGFloat totalAmount = 0.0;
        for (HKCoupon * c in couponArray)
        {
            totalAmount = totalAmount + c.couponAmount;
        }
        NSString * string =  [NSString stringWithFormat:@"%lu代金劵(共%@元)",(unsigned long)couponArray.count,[NSString formatForPrice:totalAmount]];
        return string;
    }
}


///获取优惠劵的两头时间
- (NSString *)calcCouponValidDateString:(NSArray *)couponArray
{
    NSDate * earlierDate;
    NSDate * laterDate;
    for (HKCoupon * c in couponArray)
    {
        earlierDate = [c.validsince earlierDate:earlierDate];
        laterDate = [c.validthrough laterDate:laterDate];
    }
    NSString * string = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
    
    return string;
}

#pragma mark - TableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray * rowArray = [self.datasource safetyObjectAtIndex:section];
    NSInteger num = rowArray.count;
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0)
    {
        return 10;
    }
    return  CGFLOAT_MIN;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"TitleCell" tag:nil]) {
        [self titleCell:cell withCellDate:data];
    }
    else if ([data equalByCellID:@"InfoItemCell" tag:nil]) {
        [self infoItemCell:cell withCellDate:data];
    }
    else if ([data equalByCellID:@"DiscountInfoCell" tag:nil]) {
        [self discountInfoCell:cell withCellDate:data];
    }
    else if ([data equalByCellID:@"CouponCell" tag:nil]) {
        [self couponCell:cell withCellDate:data];
    }
    else if ([data equalByCellID:@"ActiveCell" tag:nil]) {
        [self activeCell:cell withCellDate:data];
    }
    else if ([data equalByCellID:@"PayPlatformCell" tag:nil]) {
        [self payPlatformCell:cell withCellDate:data];
    }
    else{
        [self license:cell withCellDate:data];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData * data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if ([data equalByCellID:@"ActiveCell" tag:nil])
    {
        
    }
    else if ([data equalByCellID:@"PayPlatformCell" tag:nil])
    {
        self.payOp.req_paychannel = data.customTag;
    }
    else if ([data equalByCellID:@"CouponCell" tag:nil])
    {
        ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
        vc.type = CouponTypeCarWash;
        vc.selectedCouponArray = self.selectCashCoupouArray;
        vc.couponArray = self.cashCoupouArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - About Cell
- (void)titleCell:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UIImageView * imageView = [cell.contentView viewWithTag:101];
    UILabel *descL = (UILabel *)[cell.contentView viewWithTag:102];
    
    [imageView setImageByUrl:data.tag
                withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    descL.text = data.object;
}

- (void)infoItemCell:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *contentLb = (UILabel *)[cell.contentView viewWithTag:102];
    
    titleLb.text = data.object;
    contentLb.text = data.tag;
}

- (void)discountInfoCell:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:102];
    
    [[[RACObserve(self, isLoadingResourse) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal] ] subscribeNext:^(NSNumber * number) {
        
        BOOL isloading = [number boolValue];
        indicator.animating = isloading;
        indicator.hidden = !isloading;
    }];
}

- (void)couponCell:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UILabel *couponLb = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:103];

    if (self.selectCashCoupouArray.count)
    {
        couponLb.hidden = NO;
        dateLb.hidden = NO;
        couponLb.text = [self calcCouponTitle:self.selectCashCoupouArray];
        dateLb.text = [self calcCouponValidDateString:self.selectCashCoupouArray];
    }
    else
    {
        couponLb.hidden = YES;
        dateLb.hidden = YES;
    }
}
- (void)activeCell:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UILabel *tipLb = (UILabel *)[cell.contentView viewWithTag:102];
    tipLb.text = data.tag;
}


- (void)payPlatformCell:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UIImageView *iconImgV,*tickImgV;
    UILabel *titleLb,*recommendLB;
    
    iconImgV = (UIImageView *)[cell searchViewWithTag:101];
    titleLb = (UILabel *)[cell searchViewWithTag:102];
    tickImgV = (UIImageView *)[cell searchViewWithTag:103];
    recommendLB = (UILabel *)[cell searchViewWithTag:104];
    recommendLB.cornerRadius = 3.0f;
    recommendLB.layer.masksToBounds = YES;
    recommendLB.hidden = ![data.customInfo[@"recommand"] integerValue];
    
    iconImgV.image = [UIImage imageNamed:data.tag];
    titleLb.text = data.object;
    
    [[RACObserve(self.payOp, req_paychannel) takeUntilForCell:cell] subscribeNext:^(id x) {
        
        tickImgV.hidden = data.customTag != self.payOp.req_paychannel;
    }];
}


- (void)license:(UITableViewCell *)cell withCellDate:(HKCellData *)data
{
    UIButton *checkB = [cell viewWithTag:101];
    TTTAttributedLabel *richL = [cell viewWithTag:102];
    
    //选择框
    @weakify(checkB);
    [[[checkB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(checkB);
         BOOL checked = ![data.customInfo[@"check"] boolValue];
         data.customInfo[@"check"] = @(checked);
         checkB.selected = checked;
         self.payBtn.enabled = checked;
     }];
    
    //文字和协议链接
    if (!data.customInfo[@"setup"]) {
        data.customInfo[@"setup"] = @YES;
        richL.delegate = self;
        richL.attributedText = data.object;
        [richL setLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                   NSForegroundColorAttributeName: HEXCOLOR(@"#007aff")}];
        [richL setActiveLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                         NSForegroundColorAttributeName: HEXCOLOR(@"#888888")}];
        [richL addLinkToURL:data.customInfo[@"url1"] withRange:[data.customInfo[@"range1"] rangeValue]];
    }
}

#pragma mark - Lazy
- (NSMutableArray *)selectCashCoupouArray
{
    if (!_selectCashCoupouArray)
        _selectCashCoupouArray = [NSMutableArray array];
    return _selectCashCoupouArray;
}

- (PayCooperationContractOrderOp *)payOp
{
    if (!_payOp){
        _payOp = [PayCooperationContractOrderOp operation];
        _payOp.req_paychannel = PaymentChannelAlipay;
    }
    return _payOp;
}

- (HKCellData *)celldataFor0_0
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"TitleCell" tag:nil];
    celldata.object = self.contract.xmddname;
    celldata.tag = self.contract.xmddlogo;
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 78;
    }];
    return celldata;
}

- (HKCellData *)celldataFor0_1
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"InfoItemCell" tag:nil];
    celldata.object = @"互助车辆";
    celldata.tag = self.contract.licencenumber;
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 27;
    }];
    return celldata;
}

- (HKCellData *)celldataFor0_2
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"InfoItemCell" tag:nil];
    celldata.object = @"互助期限";
    celldata.tag = self.contract.contractperiod;
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 27;
    }];
    return celldata;
}

- (HKCellData *)celldataFor0_3
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"InfoItemCell" tag:nil];
    celldata.object = @"共计费用";
    celldata.tag = [NSString formatForPrice:self.contract.total];
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 27;
    }];
    return celldata;
}

- (HKCellData *)celldataFor1_0
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"DiscountInfoCell" tag:nil];
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 40;
    }];
    return celldata;
}

- (HKCellData *)celldataFor1_1
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"CouponCell" tag:nil];
    celldata.object = self.selectCashCoupouArray;
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 42;
    }];
    return celldata;
}

- (HKCellData *)celldataFor1_2
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"ActiveCell" tag:nil];
    celldata.object = self.contract.couponlist;
    celldata.tag = self.contract.couponname;
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 42;
    }];
    return celldata;
}

- (HKCellData *)celldataFor2_0
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"OtherInfoCell" tag:nil];
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 40;
    }];
    return celldata;
}

- (HKCellData *)celldataFor2_1
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"PayPlatformCell" tag:nil];
    celldata.object = @"支付宝支付";
    celldata.tag = @"alipay_logo_66";
    celldata.customTag = PaymentChannelAlipay;
    celldata.customInfo[@"recommand"] = @(YES);
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 50;
    }];
    return celldata;
}

- (HKCellData *)celldataFor2_2
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"PayPlatformCell" tag:nil];
    celldata.object = @"微信支付";
    celldata.tag = @"wechat_logo_66";
    celldata.customTag = PaymentChannelWechat;
    celldata.customInfo[@"recommand"] = @(NO);
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 50;
    }];
    return celldata;
}

- (HKCellData *)celldataFor2_3
{
    HKCellData *celldata = [HKCellData dataWithCellID:@"PayPlatformCell" tag:nil];
    celldata.object = @"银联支付";
    celldata.tag = @"uppay_logo_66";
    celldata.customTag = PaymentChannelUPpay;
    celldata.customInfo[@"recommand"] = @(NO);
    [celldata setHeightBlock:^CGFloat(UITableView *tableView) {
        return 50;
    }];
    return celldata;
}

- (HKCellData *)celldataFor2_4
{
    self.licenseData = [HKCellData dataWithCellID:@"LicenseCell" tag:nil];
    self.licenseData.customInfo[@"check"] = @YES;
    
    NSMutableString *license = [NSMutableString stringWithString:@"我已阅读并同意小马达达《保险服务协议》"];
    
    self.licenseData.customInfo[@"range1"] = [NSValue valueWithRange:NSMakeRange(license.length - 8, 8)];
    self.licenseData.customInfo[@"url1"] = [NSURL URLWithString:kInsuranceLicenseUrl];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 5;
    NSAttributedString *attstr = [[NSAttributedString alloc] initWithString:license
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                              NSForegroundColorAttributeName: HEXCOLOR(@"#9a9a9a"),
                                                                              NSParagraphStyleAttributeName: ps}];
    self.licenseData.object = attstr;
    
    [self.licenseData setHeightBlock:^CGFloat(UITableView *tableView) {
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attstr
                                                       withConstraints:CGSizeMake(tableView.frame.size.width-60, 10000)
                                                limitedToNumberOfLines:0];
        return MAX(40, ceil(size.height+24));
    }];
    
    return self.licenseData;
}

@end
