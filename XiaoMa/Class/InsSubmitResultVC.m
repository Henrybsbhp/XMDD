//
//  InsSubmitResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsSubmitResultVC.h"
#import "HKCellData.h"
#import "CKLine.h"
#import "InsCouponView.h"
#import "GetShareButtonOp.h"

#import "InsuranceOrderVC.h"
#import "SocialShareViewController.h"
#import "ShareResponeManager.h"

@interface InsSubmitResultVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsSubmitResultVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsSubmitResultVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp1009"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp1009"];
}

#pragma mark - Datasource
- (void)reloadData {
    HKCellData *headerCell = [HKCellData dataWithCellID:@"Header" tag:nil];
    [headerCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 66;
    }];
    HKCellData *titleCell = [HKCellData dataWithCellID:@"Title" tag:nil];
    [titleCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 35;
    }];
    HKCellData *couponsCell = [HKCellData dataWithCellID:@"Coupon" tag:nil];
    couponsCell.object = self.couponList;
    @weakify(self);
    [couponsCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(self);
        return [InsCouponView heightWithCouponCount:[self.couponList count] buttonHeight:30];
    }];
    HKCellData *bottomCell = [HKCellData dataWithCellID:@"Bottom" tag:nil];
    [bottomCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 55;
    }];
    self.datasource = @[headerCell, titleCell, couponsCell, bottomCell];
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1009-1"];
    if (self.insModel.originVC) {
        [self.navigationController popToViewController:self.insModel.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)actionOrder:(id)sender {
    
    [MobClick event:@"rp1009-3"];
    InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
    vc.orderID = self.insOrderID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionShare:(id)sender {
    
    [MobClick event:@"rp1009-2"];
    GetShareButtonOp * op = [GetShareButtonOp operation];
    op.pagePosition = ShareSceneInsurance;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOp * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneInsurance;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
            
        }];
        [[ShareResponeManagerForQQ init] setFinishAction:^(NSString * code, ShareResponseType type){
            
        }];
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];

}


#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Coupon" tag:nil]) {
        [self setupCouponCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Title" tag:nil]) {
        [self setupTitleCell:cell forData:nil];
    }
    return cell;
}

- (void)setupTitleCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    CKLine *line1 = [cell viewWithTag:1001];
    CKLine *line2 = [cell viewWithTag:1003];
    
    line1.lineColor = HEXCOLOR(@"#20ab2a");
    line2.lineColor = HEXCOLOR(@"#20ab2a");
}

- (void)setupCouponCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    InsCouponView *couponV = [cell viewWithTag:1001];
    
    couponV.buttonHeight = 30;
    couponV.buttonTitleColor = HEXCOLOR(@"#20ab2a");
    couponV.buttonBorderColor = HEXCOLOR(@"#20ab2a");
    couponV.coupons = data.object;
}

@end
