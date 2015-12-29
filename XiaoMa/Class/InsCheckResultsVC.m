//
//  InsCheckResultsVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsCheckResultsVC.h"
#import "HKCellData.h"
#import "CKLine.h"
#import "InsCouponView.h"
#import "InsPremium.h"
#import "NSString+Format.h"
#import "NSString+RectSize.h"
#import "GetPremiumByIdOp.h"

#import "InsBuyVC.h"
#import "InsAppointmentVC.h"
#import "InsInputInfoVC.h"
#import "InsAlertVC.h"

@interface InsCheckResultsVC ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) NSString *headerTip;

@end

@implementation InsCheckResultsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.premiumList.count == 0) {
        [self requestPremiums];
    }
    else {
        [self reloadData];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /**
     *  核保结果返回事件
     */
    [MobClick event:@"rp100-1"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadHeaderView
{
    UILabel *titleL = [self.headerView viewWithTag:1001];
    CKLine *line = [self.headerView viewWithTag:1002];
    line.lineAlignment = CKLineAlignmentHorizontalBottom;
    [line layoutIfNeeded];
    titleL.text = self.headerTip.length > 0 ? self.headerTip : @"如有任何疑问，可拨打4007-111-111咨询。";
}

#pragma Datasource
- (void)requestPremiums
{
    GetPremiumByIdOp *op = [GetPremiumByIdOp operation];
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetPremiumByIdOp *op) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.containerView.hidden = NO;
        self.premiumList = op.rsp_premiumlist;
        self.headerTip = op.rsp_tip;
        [self reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:@"获取核保结果失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestPremiums];
        }];
    }];
}

- (void)reloadData
{
    [self reloadHeaderView];
    
    NSMutableArray *datasource = [NSMutableArray array];
    for (int i = 0; i < self.premiumList.count; i++) {
        NSMutableArray *rows = [NSMutableArray array];
        InsPremium *premium = self.premiumList[i];
         if (premium.errmsg.length == 0) {
            HKCellData *cell = [HKCellData dataWithCellID:@"Uppon" tag:nil];
            cell.object = premium;
            [rows addObject:cell];
            if (i == 0) {
                cell.customInfo[@"expand"] = @YES;
                [rows addObject:[self createCouponCellDataWithPremium:premium]];
            }
        }
        else {
            [rows addObject:[self createFailCellDataWithPremium:premium]];
        }

        [datasource addObject:rows];
    }

    self.datasource = datasource;
    [self.tableView reloadData];
}

- (HKCellData *)createCouponCellDataWithPremium:(InsPremium *)premium
{
    HKCellData *data = [HKCellData dataWithCellID:@"Down" tag:nil];
    data.object = premium;
    [data setHeightBlock:^CGFloat(UITableView *tableView) {
        return [InsCouponView heightWithCouponCount:premium.couponlist.count buttonHeight:25]+8;
    }];
    return data;
}

- (HKCellData *)createFailCellDataWithPremium:(InsPremium *)premium
{
    HKCellData *data = [HKCellData dataWithCellID:@"Fail" tag:nil];
    data.object = premium;
    @weakify(data);
    [data setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(data);
        CGSize lbsize = [premium.errmsg labelSizeWithWidth:tableView.frame.size.width-48 font:[UIFont systemFontOfSize:14]];
        CGFloat lbheight = MIN(ceil(lbsize.height), 35);
        BOOL overflow = lbheight >= 35;
        data.customInfo[@"overflow"] = @(overflow);
        data.customInfo[@"lbheight"] = @(lbheight);
        return 94+8+lbheight+(overflow ? 26 : 8);
    }];
    
    return data;
}

#pragma mark - Action
///重新核保
- (IBAction)actionReUnderwrite:(id)sender
{
    /**
     * 重新核保点击事件
     */
    [MobClick event:@"1004-2"];
    InsInputInfoVC *infoVC = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
    infoVC.insModel = self.insModel;
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (void)showErrorDetail:(NSString *)errmsg
{
    CGFloat lbh = ceil([errmsg labelSizeWithWidth:280 font:[UIFont systemFontOfSize:14]].height);
    CGSize size = CGSizeMake(300, MAX(50, lbh+20));
    
    UIViewController *vc = [[UIViewController alloc] init];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleFade;
    sheet.shouldDismissOnBackgroundViewTap = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = floor((self.view.frame.size.height - size.height) / 2);
    
    [sheet presentAnimated:YES completionHandler:nil];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, lbh)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = HEXCOLOR(@"#888888");
    label.text = errmsg;
    [vc.view addSubview:label];
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
    return 145;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Uppon" tag:nil]) {
        [self resetUpponCell:cell forData:data atIndexPath:indexPath];
    }
    else if ([data equalByCellID:@"Down" tag:nil]){
        [self resetDownCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Fail" tag:nil]) {
        [self resetFailCell:cell forData:data];
    }
    return cell;
}

- (void)resetUpponCell:(UITableViewCell *)cell forData:(HKCellData *)data atIndexPath:(NSIndexPath *)indexPath
{
    CKLine *line1 = [cell viewWithTag:10001];
    CKLine *line2 = [cell viewWithTag:10002];
    CKLine *line3 = [cell viewWithTag:10003];
    CKLine *line4 = [cell viewWithTag:10004];
    CKLine *line5 = [cell viewWithTag:10005];
    CKLine *line6 = [cell viewWithTag:10006];
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    UIButton *buyB = [cell viewWithTag:1004];
    UIButton *arrowB = [cell viewWithTag:1005];
    UIButton *bgB = [cell viewWithTag:2001];
    
    InsPremium *premium = data.object;
    BOOL buyable = premium.ordertype == 2;
    BOOL expand = [data.customInfo[@"expand"] boolValue];
    
    //边线
    line1.lineAlignment = CKLineAlignmentHorizontalTop;
    line2.lineAlignment = CKLineAlignmentVerticalLeft;
    line3.lineAlignment = CKLineAlignmentVerticalRight;
    line4.lineAlignment = CKLineAlignmentHorizontalBottom;
    line5.lineAlignment = CKLineAlignmentHorizontalBottom;
    line5.lineOptions = CKLineOptionDash;
    line5.dashLengths = @[@3, @2];
    line6.lineAlignment = CKLineAlignmentHorizontalBottom;
    line6.hidden = expand;
    
    [arrowB setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, expand ? M_PI : 0)];
    [logoV setImageByUrl:premium.inslogo withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    titleL.text = premium.couponname;

    //price
    NSMutableAttributedString *text = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:28], NSForegroundColorAttributeName:HEXCOLOR(@"#ffb20c")};
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:HEXCOLOR(@"#e1e1e1"),
                            NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSString *strPrice = [NSString stringWithFormat:@"%@ ", [NSString formatForRoundPrice:premium.price]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:strPrice attributes:attr1]];
    if (floor(premium.originprice) > floor(premium.price)) {
        NSString *strOrgPrice = [NSString stringWithFormat:@"原价:%@", [NSString formatForRoundPrice:premium.originprice]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:strOrgPrice attributes:attr2]];
    }
    priceL.attributedText = text;

    //购买按钮
    [buyB setTitle:buyable ? @"在线购买" : @"预约购买" forState:UIControlStateNormal];
    @weakify(self);
    [[[buyB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        InsuranceVM *insModel = self.insModel;
        insModel = self.insModel;
        insModel.inscomp = premium.inscomp;
        insModel.inscompname = premium.inscompname;
        if (buyable) {
            
            InsBuyVC *vc = [UIStoryboard vcWithId:@"InsBuyVC" inStoryboard:@"Insurance"];
            vc.insModel = insModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            
            InsAppointmentVC *vc = [UIStoryboard vcWithId:@"InsAppointmentVC" inStoryboard:@"Insurance"];
            [self.navigationController pushViewController:vc animated:YES];
        }

    }];
    
    //背景按钮
    [[[bgB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        BOOL expand = ![data.customInfo[@"expand"] boolValue];
        data.customInfo[@"expand"] = @(expand);
        NSMutableArray *rows = [self.datasource safetyObjectAtIndex:indexPath.section];
        if (expand && rows.count < 2) {
            [rows safetyInsertObject:[self createCouponCellDataWithPremium:premium] atIndex:1];
            [line6 setHidden:YES];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [arrowB setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:indexPath.section]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        else if (!expand && rows.count > 1) {
            [rows safetyRemoveObjectAtIndex:1];
            CKAfter(0.2, ^{
                [line6 setHidden:[data.customInfo[@"expand"] boolValue]];
            });
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [arrowB setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 0)];
            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:indexPath.section]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }];
}

- (void)resetDownCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    CKLine *line1 = [cell viewWithTag:10001];
    CKLine *line2 = [cell viewWithTag:10002];
    CKLine *line3 = [cell viewWithTag:10003];
    InsCouponView *couponV = [cell viewWithTag:1001];

    InsPremium *premium = data.object;
    
    line1.lineAlignment = CKLineAlignmentVerticalLeft;
    line2.lineAlignment = CKLineAlignmentVerticalRight;
    line3.lineAlignment = CKLineAlignmentHorizontalBottom;
    couponV.buttonHeight = 25;
    couponV.coupons = [premium.couponlist arrayByMapFilteringOperator:^id(NSDictionary *dict) {
        NSString *name = dict[@"name"];
        NSString *desc = dict[@"desc"];
        name.customObject = desc;
        return name;
    }];
    
    @weakify(self);
    [couponV setButtonClickBlock:^(NSString *name) {
        @strongify(self);
        [InsAlertVC showInView:self.navigationController.view withMessage:name.customObject];
    }];
}

- (void)resetFailCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    CKLine *line1 = [cell viewWithTag:10001];
    CKLine *line2 = [cell viewWithTag:10002];
    CKLine *line3 = [cell viewWithTag:10003];
    CKLine *line4 = [cell viewWithTag:10004];
    CKLine *line5 = [cell viewWithTag:10005];
    CKLine *line6 = [cell viewWithTag:10006];
    UIImageView *logoV = [cell viewWithTag:1001];
    UIButton *callB = [cell viewWithTag:2002];
    UILabel *errorL = [cell viewWithTag:3001];
    UIButton *bgB = [cell viewWithTag:3002];
    UILabel *detailL = [cell viewWithTag:3003];

    InsPremium *premium = data.object;
    
    //边线
    line1.lineAlignment = CKLineAlignmentHorizontalTop;
    line2.lineAlignment = CKLineAlignmentVerticalLeft;
    line3.lineAlignment = CKLineAlignmentVerticalRight;
    line4.lineAlignment = CKLineAlignmentHorizontalBottom;
    line5.lineAlignment = CKLineAlignmentHorizontalBottom;
    line5.lineOptions = CKLineOptionDash;
    line5.dashLengths = @[@3, @2];
    line6.lineAlignment = CKLineAlignmentHorizontalBottom;
    
    [logoV setImageByUrl:premium.inslogo withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    
    [[[callB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
        [gPhoneHelper makePhone:@"4007111111" andInfo:@"客服电话: 4007-111-111"];
    }];

    BOOL overflow = [data.customInfo[@"overflow"] boolValue];
    detailL.hidden = !overflow;
    errorL.text = premium.errmsg;
    [errorL mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat height = [data.customInfo[@"lbheight"] floatValue];
        make.height.mas_equalTo(height);
    }];

    @weakify(self);
    [[[bgB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(self);
         if (overflow) {
             [InsAlertVC showInView:self.navigationController.view withMessage:premium.errmsg];
         }
    }];
}

@end
