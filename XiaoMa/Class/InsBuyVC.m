//
//  InsBuyVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsBuyVC.h"
#import "CKLine.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "InsuranceVM.h"
#import "GetPremiumDetailOp.h"
#import "NSString+RectSize.h"
#import "PayForPremiumOp.h"
#import "NSString+Format.h"
#import "NSDate+DateForText.h"
#import "HKTableViewCell.h"
#import "IQKeyboardManager.h"
#import "InsuranceStore.h"

#import "DatePickerVC.h"
#import "PayForInsuranceVC.h"
#import "InsPayResultVC.h"

@interface InsBuyVC ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) GetPremiumDetailOp *premiumDetail;
@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, strong) PayForPremiumOp *paymentInfo;
@property (nonatomic, assign) BOOL isOwnernameDifferent;

@end

@implementation InsBuyVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsBuyVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.insModel.inscompname;
    [self setupDatePicker];
    [self setupBottomView];
    CKAsyncMainQueue(^{
        [self requestDetailPremium];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp1005"];
    [IQKeyboardManager sharedManager].disableSpecialCaseForScrollView = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp1005"];
    [IQKeyboardManager sharedManager].disableSpecialCaseForScrollView = NO;
}
//设置日期选择控件（主要是为了事先加载，优化性能）
- (void)setupDatePicker {
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}

- (void)setupBottomView {
    @weakify(self);
    [[RACObserve(self, isOwnernameDifferent) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.bottomButton.enabled = ![x boolValue];
    }];
}

#pragma Datasource
- (void)reloadData
{
    [self reloadHeaderView];
    self.paymentInfo = [PayForPremiumOp operation];
    self.paymentInfo.req_ownername = self.premiumDetail.rsp_ownername ? self.premiumDetail.rsp_ownername : self.insModel.realName;
    self.paymentInfo.req_carpremiumid = self.premiumDetail.req_carpremiumid;
    self.paymentInfo.req_startdate = self.premiumDetail.rsp_startdate;
    self.paymentInfo.req_forcestartdate = self.premiumDetail.rsp_fstartdate;
    self.paymentInfo.req_inscomp = self.premiumDetail.req_inscomp;
    self.paymentInfo.req_location = self.premiumDetail.rsp_location;
    self.paymentInfo.req_ownerphone = gAppMgr.myUser.userID;

    NSMutableArray *datasource = [NSMutableArray array];
    HKCellData *info = [HKCellData dataWithCellID:@"Info" tag:nil];
    [info setHeightBlock:^CGFloat(UITableView *tableView) {
        return 120;
    }];
    
    HKCellData *date = [HKCellData dataWithCellID:@"Date" tag:nil];
    HKCellData *name = [HKCellData dataWithCellID:@"Field2" tag:nil];
    HKCellData *idcard = [HKCellData dataWithCellID:@"Field" tag:nil];
    HKCellData *addr = [HKCellData dataWithCellID:@"Address" tag:nil];
    [addr setHeightBlock:^CGFloat(UITableView *tableView) {
        return 142;
    }];
    [datasource addObject:@[info,date,name,idcard,addr]];

    HKCellData *sectionCell = [HKCellData dataWithCellID:@"Section" tag:nil];
    [sectionCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 33;
    }];
    
    NSMutableArray *section1 = [NSMutableArray array];
    [section1 addObject:sectionCell];
    for (InsCoveragePrice *cp in self.premiumDetail.rsp_inslist) {
        HKCellData *coverage = [HKCellData dataWithCellID:@"Coverage" tag:nil];
        [coverage setHeightBlock:^CGFloat(UITableView *tableView) {
            return 40;
        }];
        coverage.object = cp;
        [section1 addObject:coverage];
    }
    [datasource addObject:section1];
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

- (void)reloadHeaderView
{
    UILabel *titleL = [self.headerView viewWithTag:1001];
    CKLine *line = [self.headerView viewWithTag:1002];
    
    line.lineAlignment = CKLineAlignmentHorizontalBottom;
    [line setNeedsDisplay];

    titleL.text = self.premiumDetail.rsp_tip;
    CGFloat height = 0;
    if (self.premiumDetail.rsp_tip.length > 0) {
        CGSize size = [self.premiumDetail.rsp_tip labelSizeWithWidth:CGRectGetWidth(self.view.frame)-48
                                                                font:[UIFont systemFontOfSize:13]];
        height = ceil(size.height + 16);
    }

    [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {

        make.height.mas_equalTo(height);
    }];
}

#pragma mark - Action
- (IBAction)actionBuy:(id)sender
{
    [MobClick event:@"rp1005-7"];

    if (self.paymentInfo.req_ownername.length  == 0) {
        [gToast showText:@"车主姓名不能为空"];
    }
    else if (self.paymentInfo.req_ownerphone.length == 0) {
        [gToast showText:@"联系方式不能为空"];
    }
    else if (self.paymentInfo.req_idno.length == 0) {
        [gToast showText:@"身份证位数必须为18位"];
    }
    else if (self.paymentInfo.req_owneraddress.length == 0) {
        [gToast showText:@"详细地址不能为空"];
    }
    else {
        [self requestPayForPremium];
    }
}

- (IBAction)actionCall:(id)sender
{
    [MobClick event:@"rp1005-2"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"咨询电话：4007-111-111"];
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1005-1"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Request
- (void)requestDetailPremium
{
    GetPremiumDetailOp *op = [GetPremiumDetailOp operation];
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    op.req_inscomp = self.insModel.inscomp;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.containerView.hidden = NO;
        self.premiumDetail = x;
        [self reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:@"获取详情失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestDetailPremium];
        }];
    }];
}

- (void)requestPayForPremium
{
    @weakify(self);
    [[[self.paymentInfo rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在生成保险订单"];
    }] subscribeNext:^(PayForPremiumOp *op) {
        
        @strongify(self);
        [gToast dismiss];
        PayForInsuranceVC *vc = [UIStoryboard vcWithId:@"PayForInsuranceVC" inStoryboard:@"Insurance"];
        vc.insModel = [self.insModel copy];
        vc.insOrder = op.rsp_order;
        [self.navigationController pushViewController:vc animated:YES];
        //刷新保险列表
        [[[InsuranceStore fetchExistsStore] getInsSimpleCars] sendAndIgnoreError];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.premiumDetail.rsp_tip.length == 0) {
        return CGFLOAT_MIN;
    }
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource safetyObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    HKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Info" tag:nil]) {
        [self resetBaseInfoCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Date" tag:nil]) {
        [self resetDateCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Field2" tag:nil]) {
        [self resetField2Cell:cell forData:data];
    }
    else if ([data equalByCellID:@"Field" tag:nil]) {
        [self resetFieldCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Address" tag:nil]) {
        [self resetAddressCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Coverage" tag:nil]){
        [self resetCoverageCell:cell forData:data];
    }
    if ([cell isKindOfClass:[HKTableViewCell class]]) {
        cell.customSeparatorInset = UIEdgeInsetsZero;
        [cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
    return cell;
}

- (void)resetBaseInfoCell:(HKTableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    
    [logoV setImageByUrl:self.premiumDetail.rsp_inslogo withType:ImageURLTypeOrigin
                defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    titleL.text = self.premiumDetail.rsp_inscompname;
    
    NSMutableAttributedString *text = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:33], NSForegroundColorAttributeName:HEXCOLOR(@"#ffb20c")};
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:HEXCOLOR(@"#e1e1e1"),
                            NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSString *price = [NSString stringWithFormat:@"%@ ", [NSString formatForRoundPrice:self.premiumDetail.rsp_price]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:price attributes:attr1]];
    if (floor(self.premiumDetail.rsp_originprice) > floor(self.premiumDetail.rsp_price)) {
        NSString *orgPrice = [NSString stringWithFormat:@"原价:%@",[NSString formatForRoundPrice:self.premiumDetail.rsp_originprice]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:orgPrice attributes:attr2]];
    }
    priceL.attributedText = text;
}

- (void)resetDateCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    //商业启保日
    HKSubscriptInputField *dateLF = [cell viewWithTag:10012];
    UIButton *dateLB = [cell viewWithTag:10013];
    //交强险起保日
    HKSubscriptInputField *dateRF = [cell viewWithTag:10022];
    UIButton *dateRB = [cell viewWithTag:10023];

    dateLF.inputField.placeholder = @"商业险日期";
    dateLF.inputField.text = self.paymentInfo.req_startdate;
    dateLF.subscriptImageName = @"ins_arrow_time";
    dateLB.userInteractionEnabled = NO;
    @weakify(self);
    [[[[dateLB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
      flattenMap:^RACStream *(id value) {
          
          @strongify(self);
          [MobClick event:@"rp1005-3"];
          [self.view endEditing:YES];
          return [self rac_pickDateWithNow:self.paymentInfo.req_startdate];
      }] subscribeNext:^(NSString *datetext) {
          
          @strongify(self);
          self.paymentInfo.req_startdate = datetext;
          dateLF.inputField.text = datetext;
      }];
    
    dateRF.inputField.placeholder = @"交强险日期";
    dateRF.inputField.text = self.paymentInfo.req_forcestartdate;
    dateRF.subscriptImageName = @"ins_arrow_time";
    dateRB.userInteractionEnabled = NO;
    [[[[dateRB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
      flattenMap:^RACStream *(id value) {
          
          @strongify(self);
          [MobClick event:@"rp1005-4"];
          [self.view endEditing:YES];
          return [self rac_pickDateWithNow:self.paymentInfo.req_forcestartdate];
      }] subscribeNext:^(NSString *datetext) {
          
          @strongify(self);
          self.paymentInfo.req_forcestartdate = datetext;
          dateRF.inputField.text = datetext;
      }];
}

- (void)resetField2Cell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *nameF = [cell viewWithTag:1002];
    HKSubscriptInputField *phoneF = [cell viewWithTag:1004];
    
    nameF.inputField.placeholder = @"输入姓名";
    nameF.inputField.textLimit = 20;
    nameF.inputField.text = self.paymentInfo.req_ownername;
    [nameF.inputField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:@"rp1005-5"];
    }];
    @weakify(self);
    [nameF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        
        @strongify(self);
        self.paymentInfo.req_ownername = field.text;
    }];
    
    phoneF.inputField.placeholder = @"输入手机号码";
    phoneF.inputField.textLimit = 11;
    phoneF.inputField.text = self.paymentInfo.req_ownerphone;
    phoneF.inputField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        
        @strongify(self);
        self.paymentInfo.req_ownerphone = field.text;
    }];
}

- (void)resetFieldCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *idF = [cell viewWithTag:1002];
    
    idF.inputField.placeholder = @"输入身份证号码";
    idF.inputField.textLimit = 18;
    idF.inputField.keyboardType = UIKeyboardTypeASCIICapable;
    idF.inputField.text = self.paymentInfo.req_idno;
    [idF.inputField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:@"rp1005-5"];
    }];
    @weakify(self);
    [idF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        
        @strongify(self);
        self.paymentInfo.req_idno = field.text;
    }];
}

- (void)resetAddressCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UITextField *textF = [cell viewWithTag:10011];
    HKSubscriptInputField *addrF = [cell viewWithTag:1002];
    UIButton *checkB = [cell viewWithTag:10031];
    
    textF.text = self.paymentInfo.req_location;
    
    addrF.inputField.placeholder = @"请填写详细地址";
    @weakify(self);
    [addrF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        @strongify(self);
        self.paymentInfo.req_owneraddress = field.text;
    }];
    
    self.paymentInfo.customObject = data;
    [[RACObserve(self, isOwnernameDifferent) takeUntilForCell:cell] subscribeNext:^(id x) {
        @strongify(self);
        checkB.selected = !self.isOwnernameDifferent;
    }];

    [[checkB rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
        @strongify(self);
        self.isOwnernameDifferent = !self.isOwnernameDifferent;
    }];
}

- (void)resetCoverageCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *titleL = [cell viewWithTag:1001];
    UILabel *detailL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    CKLine *vline = [cell viewWithTag:1004];
    
    InsCoveragePrice *cp = data.object;
    
    vline.lineAlignment = CKLineAlignmentVerticalRight;
    titleL.text = cp.coverage;

    //detailLabel
    if (cp.value > 0) {
        detailL.text = [NSString stringWithFormat:@"%@万", [NSString formatForRoundPrice:cp.value]];
    }
    else {
        detailL.text = nil;
    }
    
    priceL.text = [NSString formatForRoundPrice:cp.fee];
}

#pragma mark - Utility
- (RACSignal *)rac_pickDateWithNow:(NSString *)nowtext
{
    NSDate *date = [NSDate dateWithD10Text:nowtext];
    return [[[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:date] ignoreError] map:^id(NSDate *date) {
        return [date dateFormatForD10];
    }];
}

@end
