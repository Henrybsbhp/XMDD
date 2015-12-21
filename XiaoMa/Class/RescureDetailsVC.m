//
//  RescureDetailsVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescureDetailsVC.h"
#import "GetRescureDetailOp.h"
#import "HKRescureDetail.h"
#import "RescueCouponViewController.h"
#import "GetSystemPromotionOp.h"
#import "RescueApplyOp.h"
#import "ADViewController.h"
#import "NSString+RectSize.h"
#import "RescurecCommentsVC.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface RescureDetailsVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView        * headerView;
@property (nonatomic, strong) UIImageView   * advertisingImg;
@property (nonatomic, strong) UIView        * footerView;
@property (nonatomic, strong) UIButton      * helperBtn;
@property (nonatomic, strong) UIButton      * freeBtn;
@property (nonatomic, copy)   NSString      * testStr;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
@end

@implementation RescureDetailsVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescureDetailsVC dealloc");
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self actionFirstEnter];
    [self.view addSubview:self.helperBtn];
    self.tableView.tableFooterView = self.footerView;
    [self setupADView];
    self.navigationItem.title = self.titleStr;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.freeBtn];
    
}

#pragma mark - Action

- (void)actionRescueHistory {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        [MobClick event:@"rp101-5"];
        RescueCouponViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueCouponViewController"];
        vc.type = self.type;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionFirstEnter {
    GetRescureDetailOp *op = [GetRescureDetailOp operation];
    op.rescueid = self.type;
    op.type = [NSNumber numberWithInteger:2];
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescureDetailOp *op) {
        NSString *lastStr;
        for (NSString *testStr in op.rescueDetailArray) {
            lastStr = [testStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [self.dataSourceArray addObject:lastStr];
        }
        NSString *string = [NSString stringWithFormat:@"● %@", [op.rescueDetailArray safetyObjectAtIndex:0]];
        lastStr = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
        self.dataSourceArray[0] = lastStr;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (self.dataSourceArray.count == 0) {
            [self.view showDefaultEmptyViewWithText:@"获取失败, 再试试吧" tapBlock:^{
                [self actionFirstEnter];
            }];
        }
    }] ;
}

- (void)actionPhoneHelper{
    [MobClick event:@"rp128"];
    if (gAppMgr.myUser != nil) {
        RescueApplyOp *op = [RescueApplyOp operation];
        op.longitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.longitude];
        op.latitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.latitude];
        [[[[op rac_postRequest] initially:^{
        }] finally:^{
            
        }] subscribeNext:^(RescueApplyOp *op) {
            
        } error:^(NSError *error) {
            
        }] ;
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
        
    }else{
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }
}

#pragma mark - AD
- (void)setupADView
{
    if (self.type == 1) {
        self.adctrl = [ADViewController vcWithADType:AdvertisementTrailer boundsWidth:self.view.bounds.size.width targetVC:self mobBaseEvent:@"rp102-6"];
        [self.adctrl reloadDataForTableView:self.tableView];
    }else if (self.type == 2){
        self.adctrl = [ADViewController vcWithADType:AdvertisementTrailerPumpPower boundsWidth:self.view.bounds.size.width targetVC:self mobBaseEvent:@"rp102-6"];
        [self.adctrl reloadDataForTableView:self.tableView];
    }else if (self.type == 3){
        self.adctrl = [ADViewController vcWithADType:AdvertisementTrailerPumpPowerChangeTheTire boundsWidth:self.view.bounds.size.width targetVC:self mobBaseEvent:@"rp102-6"];
        [self.adctrl reloadDataForTableView:self.tableView];
    }
}

#pragma mark - spacing
- (NSAttributedString *)attributedStringforHeight:(NSString *)str {
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:2];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [str length])];
    return attributedString1;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureDetailsVC" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLb = (UILabel *)[cell searchViewWithTag:1000];
    UILabel *detailLb = (UILabel *)[cell searchViewWithTag:1001];
    NSString * string = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    [detailLb setAttributedText:[self attributedStringforHeight:string]];
    
    if (indexPath.row == 0) {
        titleLb.text = @"服务对象";
    }else if (indexPath.row == 1){
        titleLb.text = @"收费标准";
    }else if (indexPath.row == 2){
        titleLb.text = @"服务项目";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    
    CGFloat width = kWidth - 30;
    CGSize size = [str labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
    CGFloat height;
    height = size.height + 63;
    return height;
}


#pragma mark - lazyLoading
- (UIView *)headerView {
    if (!_headerView) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.31 * kWidth)];
    }
    return _headerView;
}
- (UIImageView *)advertisingImg {
    if (!_advertisingImg) {
        self.advertisingImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.31 * kWidth)];
    }
    return _advertisingImg;
}
- (UIView *)footerView {
    if (!_footerView) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.375 * kWidth)];
    }
    return _footerView;
}
- (NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        self.dataSourceArray = [@[] mutableCopy];
    }
    return _dataSourceArray;
}


- (UIButton *)helperBtn {
    if (!_helperBtn) {
        self.helperBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _helperBtn.frame = CGRectMake(10, self.view.bounds.size.height - (kWidth- 20) * 0.13 - 7 - 64 , kWidth  - 20, (kWidth- 20) * 0.13);
        [_helperBtn setTitle:@"申请救援" forState:UIControlStateNormal];
        [_helperBtn addTarget:self action:@selector(actionPhoneHelper) forControlEvents:UIControlEventTouchUpInside];
        [_helperBtn setTintColor:[UIColor whiteColor]];
        _helperBtn.backgroundColor = [UIColor colorWithHex:@"#fe4a00" alpha:1];
        _helperBtn.cornerRadius = 4;
        _helperBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    }
    return _helperBtn;
}

- (UIButton *)freeBtn {
    if (!_freeBtn) {
        self.freeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _freeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _freeBtn.frame = CGRectMake(0, 0, 44, 50);
        [_freeBtn setTitle:@"免费券" forState:UIControlStateNormal];
        [_freeBtn addTarget:self action:@selector(actionRescueHistory) forControlEvents:UIControlEventTouchUpInside];
    }
    return _freeBtn;
}

@end
