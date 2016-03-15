//
//  AutoGroupInfoVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "AutoGroupInfoVC.h"
#import "CarListVC.h"
#import "GetCooperationAutoGroupOp.h"
#import "NSMutableDictionary+AddParams.h"
#import "UIView+JTLoadingView.h"
#import "EditInsInfoVC.h"
#import "ApplyCooperationGroupJoinOp.h"

@interface AutoGroupInfoVC ()

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic,strong)NSArray * autoGroupArray;

@end

@implementation AutoGroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestAutoGroupArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

#pragma mark - Utilitly
- (void)requestAutoGroupArray
{
    GetCooperationAutoGroupOp * op = [[GetCooperationAutoGroupOp alloc] init];
    op.city = gMapHelper.addrComponent.city;
    op.province = gMapHelper.addrComponent.province;
    op.district = gMapHelper.addrComponent.district;
    [[[op rac_postRequest] initially:^{
        
        [self.tableView startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationAutoGroupOp * rop) {
        
        [self.tableView stopActivityAnimation];
        self.autoGroupArray = rop.rsp_autoGroupArray;
        if (self.autoGroupArray.count)
        {
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView showDefaultEmptyViewWithText:@"马上推出，敬请期待"];
        }
    } error:^(NSError *error) {
        
        [self.tableView stopActivityAnimation];
        @weakify(self);
        [self.tableView showDefaultEmptyViewWithText:@"请求失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [self requestAutoGroupArray];
        }];
    }];
}


- (void)joinSystemGroup:(NSNumber *)groupid
{
    CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
    vc.title = @"选择爱车";
    vc.model.allowAutoChangeSelectedCar = YES;
    vc.model.disableEditingCar = YES; //不可修改
    vc.model.originVC = self;
    [vc setFinishPickActionForMutualIns:^(HKMyCar *car,UIView * loadingView) {
        
        [self requestApplyJoinGroup:groupid andCarId:car.carId andLoadingView:loadingView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)requestApplyJoinGroup:(NSNumber *)groupId andCarId:(NSNumber *)carId andLoadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        EditInsInfoVC * vc = [UIStoryboard vcWithId:@"EditInsInfoVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain inView:view];
    }];
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.autoGroupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 42;
    }
    else if (indexPath.row == 4) {
        return 50;
    }
    return 23;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self headerCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 4) {
        cell = [self footerCellAtIndexPath:indexPath];
    }
    else {
        cell = [self infoCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
    UILabel * tagLb = (UILabel *)[cell searchViewWithTag:102];
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    
    titleLb.text = groupInfo[@"name"];
    tagLb.text = [NSString stringWithFormat:@"已有%ld入团",[groupInfo integerParamForName:@"membercnt"]];
    
    return cell;
}

- (UITableViewCell *)infoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    UILabel *tagLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    if (indexPath.row == 1)
    {
        tagLabel.text = groupInfo[@"grouprestrict"];
    }
    else if (indexPath.row == 2)
    {
        tagLabel.text = groupInfo[@"memberrestrict"];
    }
    else
    {
        
        tagLabel.text = groupInfo[@"grouprestrict"];
    }
    return cell;
}

- (UITableViewCell *)footerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
    
    UILabel *tagLabel = (UILabel *)[cell.contentView viewWithTag:101];
//    @lyw 大批量的圆角不要用这个。
    [tagLabel setCornerRadius:12];
    [tagLabel setBorderColor:HEXCOLOR(@"#ff7428")];
    [tagLabel setBorderWidth:0.5];
    
    UIButton * btn = [cell.contentView viewWithTag:102];
    
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    NSNumber * groupid = groupInfo[@"groupid"];
    tagLabel.text = groupInfo[@"grouptag"];
    
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [self joinSystemGroup:groupid];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
