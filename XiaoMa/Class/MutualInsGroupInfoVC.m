//
//  MutualInsGroupInfoVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsGroupInfoVC.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "CarListVC.h"
#import "MutualInsPicUpdateVC.h"
#import "HKImageAlertVC.h"
#import "EditCarVC.h"

@interface MutualInsGroupInfoVC ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@end

@implementation MutualInsGroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    [self setupBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBottomView
{
    UIButton *confirmButton = (UIButton *)[self.bottomView viewWithTag:106];
    
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.clipsToBounds = YES;
}

- (IBAction)confirmButtonClicked:(id)sender
{
    CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
    vc.title = @"选择爱车";
    vc.model.allowAutoChangeSelectedCar = YES;
    vc.model.disableEditingCar = YES; //不可修改
    vc.canJoin = YES; //用于控制爱车页面底部view
    vc.model.originVC = self;
    [vc setFinishPickActionForMutualIns:^(MyCarListVModel *carModel, UIView * loadingView) {
        
        //爱车页面入团按钮委托实现
        [self requestApplyJoinGroup:self.groupId andCarModel:carModel andLoadingView:loadingView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)requestApplyJoinGroup:(NSNumber *)groupId andCarModel:(MyCarListVModel *)carModel andLoadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carModel.selectedCar.carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = rop.req_groupid;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        if (error.code == 6115804) {
            [gToast dismissInView:view];
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = error.domain;
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
                [alertVC dismiss];
            }];
            @weakify(self);
            HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                [alertVC dismiss];
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                carModel.originVC = nil;  //设置为nil，返回爱车列表；或者用[UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
                vc.originCar = carModel.selectedCar;
                vc.model = carModel;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            alert.actionItems = @[cancel, improve];
            [alert show];
        }
        else {
            [gToast showError:error.domain inView:view];
        }
    }];
}



#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 2;
        
    } else if (section == 1) {
        
        return 1;
        
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 10;
        
    } else if (section == 1) {
        
        return CGFLOAT_MIN;
        
    }
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        
        return UITableViewAutomaticDimension;
        
    }
    
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadBannerCellAtIndexPath:indexPath];
            
        } else if (indexPath.row == 1) {
            
            cell = [self loadInfoCellAtIndexPath:indexPath];
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadJoinGroupFlowAtIndexPath:indexPath];
            
        }
        
    }
    
    return cell;
}

- (UITableViewCell *)loadBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BannerCell"];
    
    return cell;
}

- (UITableViewCell *)loadInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    
    UILabel *groupNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *nicknameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *cipherLabel = (UILabel *)[cell.contentView viewWithTag:102];
    
    groupNameLabel.text = self.groupName;
    nicknameLabel.text = self.groupCreateName;
    cipherLabel.text = self.cipher;
    return cell;
}

- (UITableViewCell *)loadJoinGroupFlowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"JoinGroupFlowCell"];
    
    UILabel *tips1Label = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *tips2Label = (UILabel *)[cell.contentView viewWithTag:104];
    UILabel *tips3Label = (UILabel *)[cell.contentView viewWithTag:105];
    
    [tips1Label setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 99];
    [tips2Label setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 99];
    [tips3Label setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 99];
    tips1Label.attributedText = [self generateAttributedStringWithLineSpacing:@"1、确认本团信息，选择车辆后即可入团。"];
    tips2Label.attributedText = [self generateAttributedStringWithLineSpacing:@"2、完善资料，填写信息后我们将对您的信息进行审核。"];
    tips3Label.attributedText = [self generateAttributedStringWithLineSpacing:@"3、选择购买的服务种类，方便我们为您精准报价。"];
    
    return cell;
}

- (NSAttributedString *)generateAttributedStringWithLineSpacing:(NSString *)string
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 4.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}

@end
